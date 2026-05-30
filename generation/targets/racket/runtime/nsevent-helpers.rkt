#lang racket/base
;; nsevent-helpers.rkt — NSEvent accessors for dynamic-subclass callbacks
;;
;; Dynamic NSView subclass IMPs (mouseDown:, mouseDragged:, mouseUp:,
;; keyDown:, etc.) receive their event argument as a raw cpointer from
;; the ObjC trampoline. `tell` from ffi/unsafe/objc rejects both raw
;; cpointers and our `objc-object?` struct wrappers — it only accepts
;; _id-tagged pointers — so every app that handles mouse or keyboard
;; events would otherwise need a raw-FFI `coerce-arg`/`tell` call in its
;; event plumbing. These helpers encapsulate that plumbing so app code
;; stays FFI-free.
;;
;; Using the generated nsevent.rkt directly is not currently an option:
;; it fails to load because NSEvent has both a class method and an
;; instance method named `modifierFlags`, and the emitter maps them to
;; the same Racket identifier. Filed in the core backlog. When that is
;; fixed, most of this module can be replaced by re-exports.

(require ffi/unsafe
         ffi/unsafe/objc
         "coerce.rkt")

(provide nsevent-location-in-window)

;; Return an NSEvent's locationInWindow as an NSPoint struct value.
;; Accepts both raw cpointers (common in dynamic-subclass callbacks) and
;; objc-object? wrappers.
(define (nsevent-location-in-window event)
  (tell #:type _NSPoint (coerce-arg event) locationInWindow))
