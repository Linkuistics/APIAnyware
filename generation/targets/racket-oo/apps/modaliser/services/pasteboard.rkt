#lang racket/base
;; pasteboard.rkt — Clipboard read/write via NSPasteboard
;;
;; Provides get-clipboard and set-clipboard! for reading and writing
;; the system clipboard as plain text.

(require "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nspasteboard.rkt")

(provide get-clipboard
         set-clipboard!)

;; NSPasteboardType for plain UTF-8 text (UTI: public.utf8-plain-text)
(define NSPasteboardTypeString "public.utf8-plain-text")

;; --- Public API ---

;; (get-clipboard) → string
;; Returns the current clipboard text, or "" if empty or non-text.
(define (get-clipboard)
  (define pb (nspasteboard-general-pasteboard))
  (define result (nspasteboard-string-for-type pb NSPasteboardTypeString))
  (cond
    [(not result) ""]
    [(objc-nil? result) ""]
    [else
     (define raw (tell #:type _string (coerce-arg result) UTF8String))
     (or raw "")]))

;; (set-clipboard! text) → void
;; Replaces the clipboard contents with the given text string.
(define (set-clipboard! text)
  (define pb (nspasteboard-general-pasteboard))
  (nspasteboard-clear-contents pb)
  (nspasteboard-set-string-for-type! pb text NSPasteboardTypeString)
  (void))

;; objc-nil? is imported from objc-base.rkt via coerce.rkt
