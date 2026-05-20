#lang racket/base
;; Generated binding for NSWindowController (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
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
  [nswindowcontroller-preview-representable-activity-items (c-> nswindowcontroller? any/c)]
  [nswindowcontroller-set-preview-representable-activity-items! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-restorable-state-key-paths (c-> any/c)]
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
  [nswindowcontroller-do-command-by-selector (c-> nswindowcontroller? string? void?)]
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
  [nswindowcontroller-prepare-for-segue-sender (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-pressure-change-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-quick-look-preview-items (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-quick-look-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-resign-first-responder (c-> nswindowcontroller? boolean?)]
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
  [nswindowcontroller-uppercase-word (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-valid-requestor-for-send-type-return-type (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nswindowcontroller-wants-forwarded-scroll-events-for-axis (c-> nswindowcontroller? exact-nonnegative-integer? boolean?)]
  [nswindowcontroller-wants-scroll-events-for-swipe-tracking-on-axis (c-> nswindowcontroller? exact-nonnegative-integer? boolean?)]
  [nswindowcontroller-window-did-load (c-> nswindowcontroller? void?)]
  [nswindowcontroller-window-title-for-document-display-name (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nswindowcontroller-window-will-load (c-> nswindowcontroller? void?)]
  [nswindowcontroller-yank (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  )

;; --- Class reference ---
(import-class NSWindowController)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-2  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-3  ; (_fun _pointer _pointer _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id -> _bool)))
(define _msg-4  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-5  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-6  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-7  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))

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
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nswindowcontroller-content-view-controller self)
  (wrap-objc-object
   (tell (coerce-arg self) contentViewController)))
(define (nswindowcontroller-set-content-view-controller! self value)
  (tell #:type _void (coerce-arg self) setContentViewController: (coerce-arg value)))
(define (nswindowcontroller-document self)
  (wrap-objc-object
   (tell (coerce-arg self) document)))
(define (nswindowcontroller-set-document! self value)
  (tell #:type _void (coerce-arg self) setDocument: (coerce-arg value)))
(define (nswindowcontroller-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nswindowcontroller-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nswindowcontroller-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nswindowcontroller-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nswindowcontroller-owner self)
  (wrap-objc-object
   (tell (coerce-arg self) owner)))
(define (nswindowcontroller-preview-representable-activity-items self)
  (wrap-objc-object
   (tell (coerce-arg self) previewRepresentableActivityItems)))
(define (nswindowcontroller-set-preview-representable-activity-items! self value)
  (tell #:type _void (coerce-arg self) setPreviewRepresentableActivityItems: (coerce-arg value)))
(define (nswindowcontroller-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSWindowController restorableStateKeyPaths)))
(define (nswindowcontroller-should-cascade-windows self)
  (tell #:type _bool (coerce-arg self) shouldCascadeWindows))
(define (nswindowcontroller-set-should-cascade-windows! self value)
  (_msg-1 (coerce-arg self) (sel_registerName "setShouldCascadeWindows:") value))
(define (nswindowcontroller-should-close-document self)
  (tell #:type _bool (coerce-arg self) shouldCloseDocument))
(define (nswindowcontroller-set-should-close-document! self value)
  (_msg-1 (coerce-arg self) (sel_registerName "setShouldCloseDocument:") value))
(define (nswindowcontroller-storyboard self)
  (wrap-objc-object
   (tell (coerce-arg self) storyboard)))
(define (nswindowcontroller-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nswindowcontroller-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nswindowcontroller-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nswindowcontroller-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nswindowcontroller-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nswindowcontroller-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nswindowcontroller-set-window! self value)
  (tell #:type _void (coerce-arg self) setWindow: (coerce-arg value)))
(define (nswindowcontroller-window-frame-autosave-name self)
  (wrap-objc-object
   (tell (coerce-arg self) windowFrameAutosaveName)))
(define (nswindowcontroller-set-window-frame-autosave-name! self value)
  (tell #:type _void (coerce-arg self) setWindowFrameAutosaveName: (coerce-arg value)))
(define (nswindowcontroller-window-loaded self)
  (tell #:type _bool (coerce-arg self) windowLoaded))
(define (nswindowcontroller-window-nib-name self)
  (wrap-objc-object
   (tell (coerce-arg self) windowNibName)))
(define (nswindowcontroller-window-nib-path self)
  (wrap-objc-object
   (tell (coerce-arg self) windowNibPath)))

;; --- Instance methods ---
(define (nswindowcontroller-become-first-responder self)
  (_msg-0 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nswindowcontroller-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nswindowcontroller-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nswindowcontroller-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nswindowcontroller-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nswindowcontroller-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nswindowcontroller-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nswindowcontroller-close! self)
  (tell #:type _void (coerce-arg self) close))
(define (nswindowcontroller-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nswindowcontroller-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nswindowcontroller-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nswindowcontroller-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nswindowcontroller-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nswindowcontroller-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nswindowcontroller-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nswindowcontroller-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nswindowcontroller-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nswindowcontroller-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nswindowcontroller-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nswindowcontroller-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nswindowcontroller-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nswindowcontroller-do-command-by-selector self selector)
  (_msg-5 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nswindowcontroller-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nswindowcontroller-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nswindowcontroller-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nswindowcontroller-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nswindowcontroller-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nswindowcontroller-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nswindowcontroller-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nswindowcontroller-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nswindowcontroller-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nswindowcontroller-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nswindowcontroller-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nswindowcontroller-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nswindowcontroller-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nswindowcontroller-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nswindowcontroller-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nswindowcontroller-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nswindowcontroller-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nswindowcontroller-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nswindowcontroller-is-window-loaded self)
  (_msg-0 (coerce-arg self) (sel_registerName "isWindowLoaded")))
(define (nswindowcontroller-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nswindowcontroller-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nswindowcontroller-load-window self)
  (tell #:type _void (coerce-arg self) loadWindow))
(define (nswindowcontroller-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nswindowcontroller-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nswindowcontroller-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nswindowcontroller-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nswindowcontroller-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nswindowcontroller-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nswindowcontroller-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nswindowcontroller-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nswindowcontroller-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nswindowcontroller-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nswindowcontroller-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nswindowcontroller-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nswindowcontroller-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nswindowcontroller-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nswindowcontroller-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nswindowcontroller-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nswindowcontroller-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nswindowcontroller-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nswindowcontroller-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nswindowcontroller-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nswindowcontroller-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nswindowcontroller-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nswindowcontroller-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nswindowcontroller-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nswindowcontroller-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nswindowcontroller-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nswindowcontroller-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nswindowcontroller-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nswindowcontroller-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nswindowcontroller-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-no-responder-for self event-selector)
  (_msg-5 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nswindowcontroller-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nswindowcontroller-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nswindowcontroller-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nswindowcontroller-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nswindowcontroller-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nswindowcontroller-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nswindowcontroller-perform-key-equivalent! self event)
  (_msg-2 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nswindowcontroller-perform-segue-with-identifier-sender! self identifier sender)
  (tell #:type _void (coerce-arg self) performSegueWithIdentifier: (coerce-arg identifier) sender: (coerce-arg sender)))
(define (nswindowcontroller-prepare-for-segue-sender self segue sender)
  (tell #:type _void (coerce-arg self) prepareForSegue: (coerce-arg segue) sender: (coerce-arg sender)))
(define (nswindowcontroller-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nswindowcontroller-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nswindowcontroller-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nswindowcontroller-resign-first-responder self)
  (_msg-0 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nswindowcontroller-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nswindowcontroller-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nswindowcontroller-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nswindowcontroller-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nswindowcontroller-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nswindowcontroller-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nswindowcontroller-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nswindowcontroller-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nswindowcontroller-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nswindowcontroller-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nswindowcontroller-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nswindowcontroller-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nswindowcontroller-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nswindowcontroller-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nswindowcontroller-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nswindowcontroller-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nswindowcontroller-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nswindowcontroller-set-document-edited! self dirty-flag)
  (_msg-1 (coerce-arg self) (sel_registerName "setDocumentEdited:") dirty-flag))
(define (nswindowcontroller-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nswindowcontroller-should-be-treated-as-ink-event self event)
  (_msg-2 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nswindowcontroller-should-perform-segue-with-identifier-sender self identifier sender)
  (_msg-3 (coerce-arg self) (sel_registerName "shouldPerformSegueWithIdentifier:sender:") (coerce-arg identifier) (coerce-arg sender)))
(define (nswindowcontroller-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nswindowcontroller-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nswindowcontroller-show-window self sender)
  (tell #:type _void (coerce-arg self) showWindow: (coerce-arg sender)))
(define (nswindowcontroller-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nswindowcontroller-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-7 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nswindowcontroller-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nswindowcontroller-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nswindowcontroller-synchronize-window-title-with-document-name self)
  (tell #:type _void (coerce-arg self) synchronizeWindowTitleWithDocumentName))
(define (nswindowcontroller-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nswindowcontroller-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nswindowcontroller-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nswindowcontroller-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nswindowcontroller-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nswindowcontroller-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nswindowcontroller-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nswindowcontroller-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nswindowcontroller-try-to-perform-with self action object)
  (_msg-6 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nswindowcontroller-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nswindowcontroller-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nswindowcontroller-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-4 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nswindowcontroller-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-4 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nswindowcontroller-window-did-load self)
  (tell #:type _void (coerce-arg self) windowDidLoad))
(define (nswindowcontroller-window-title-for-document-display-name self display-name)
  (wrap-objc-object
   (tell (coerce-arg self) windowTitleForDocumentDisplayName: (coerce-arg display-name))))
(define (nswindowcontroller-window-will-load self)
  (tell #:type _void (coerce-arg self) windowWillLoad))
(define (nswindowcontroller-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))
