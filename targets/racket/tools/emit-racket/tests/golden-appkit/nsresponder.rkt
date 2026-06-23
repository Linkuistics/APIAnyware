#lang racket/base
;; Generated binding for NSResponder (AppKit)
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

;; Threading: this class has main-thread-only methods.

;; --- Class predicates ---
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(provide NSResponder)
(provide/contract
  [make-nsresponder-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [nsresponder-accepts-first-responder (c-> nsresponder? boolean?)]
  [nsresponder-menu (c-> nsresponder? (or/c nsmenu? objc-nil?))]
  [nsresponder-set-menu! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-next-responder (c-> nsresponder? (or/c nsresponder? objc-nil?))]
  [nsresponder-set-next-responder! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-restorable-state-key-paths (c-> any/c)]
  [nsresponder-touch-bar (c-> nsresponder? (or/c nstouchbar? objc-nil?))]
  [nsresponder-set-touch-bar! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-undo-manager (c-> nsresponder? (or/c nsundomanager? objc-nil?))]
  [nsresponder-user-activity (c-> nsresponder? (or/c nsuseractivity? objc-nil?))]
  [nsresponder-set-user-activity! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-become-first-responder (c-> nsresponder? boolean?)]
  [nsresponder-begin-gesture-with-event! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-change-mode-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-context-menu-key-down (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-cursor-update (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-encode-with-coder (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-end-gesture-with-event! (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-flags-changed (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-flush-buffered-key-events (c-> nsresponder? void?)]
  [nsresponder-help-requested (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-interpret-key-events (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-key-down (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-key-up (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-magnify-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-cancelled (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-down (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-dragged (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-entered (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-exited (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-moved (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-mouse-up (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-no-responder-for (c-> nsresponder? string? void?)]
  [nsresponder-other-mouse-down (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-other-mouse-dragged (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-other-mouse-up (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-perform-key-equivalent! (c-> nsresponder? (or/c string? objc-object? #f) boolean?)]
  [nsresponder-pressure-change-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-quick-look-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-resign-first-responder (c-> nsresponder? boolean?)]
  [nsresponder-right-mouse-down (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-right-mouse-dragged (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-right-mouse-up (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-rotate-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-scroll-wheel (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-should-be-treated-as-ink-event (c-> nsresponder? (or/c string? objc-object? #f) boolean?)]
  [nsresponder-show-context-help (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-smart-magnify-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-supplemental-target-for-action-sender (c-> nsresponder? string? (or/c string? objc-object? #f) any/c)]
  [nsresponder-swipe-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-tablet-point (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-tablet-proximity (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-touches-began-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-touches-cancelled-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-touches-ended-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-touches-moved-with-event (c-> nsresponder? (or/c string? objc-object? #f) void?)]
  [nsresponder-try-to-perform-with (c-> nsresponder? string? (or/c string? objc-object? #f) boolean?)]
  [nsresponder-valid-requestor-for-send-type-return-type (c-> nsresponder? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsresponder-wants-forwarded-scroll-events-for-axis (c-> nsresponder? exact-integer? boolean?)]
  [nsresponder-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsresponder? exact-integer? boolean?)]
  )

;; --- Class reference ---
(import-class NSResponder)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))

;; --- Constructors ---
(define (make-nsresponder-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSResponder alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsresponder-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nsresponder-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsresponder-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsresponder-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nsresponder-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsresponder-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSResponder) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nsresponder-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nsresponder-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsresponder-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nsresponder-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nsresponder-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsresponder-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nsresponder-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsresponder-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nsresponder-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nsresponder-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nsresponder-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nsresponder-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nsresponder-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsresponder-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsresponder-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsresponder-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nsresponder-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nsresponder-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nsresponder-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
