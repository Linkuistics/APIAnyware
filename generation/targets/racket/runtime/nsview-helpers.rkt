#lang racket/base
;; nsview-helpers.rkt — Helpers for NSView methods inherited by subclasses
;;
;; Generated class wrappers only emit methods declared directly on a class,
;; not inherited ones. This module provides hand-written helpers for commonly
;; needed NSView methods so any NSView subclass (WKWebView, NSTableView, etc.)
;; can use them without raw FFI calls.

(require ffi/unsafe
         ffi/unsafe/objc
         "coerce.rkt")

(provide set-autoresizing-mask!)

;; setAutoresizingMask: takes NSAutoresizingMaskOptions (NSUInteger = uint64).
;; tell rejects non-_id params, so we use a typed objc_msgSend binding.
(define _objc-lib (ffi-lib "libobjc"))
(define _msg-set-autoresizing-mask
  (get-ffi-obj "objc_msgSend" _objc-lib
               (_fun _pointer _pointer _uint64 -> _void)))

;; Set the autoresizing mask on any NSView subclass.
;;
;; view: objc-object? or cpointer? — the NSView (or subclass) to configure
;; mask: exact-nonneg-integer? — bitwise OR of NSAutoresizingMaskOptions
(define (set-autoresizing-mask! view mask)
  (_msg-set-autoresizing-mask
   (coerce-arg view)
   (sel_registerName "setAutoresizingMask:")
   mask))
