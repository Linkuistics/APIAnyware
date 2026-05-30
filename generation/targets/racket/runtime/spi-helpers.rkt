#lang racket/base
;; spi-helpers.rkt — Private SPI wrappers with graceful fallback
;;
;; Wraps private system APIs that will never be auto-generated from
;; public headers. Each binding uses get-ffi-obj with a fallback so
;; consumers avoid carrying their own raw FFI boilerplate, and the
;; app degrades gracefully if the SPI is removed in a future macOS.
;;
;; API:
;;   (ax-element-get-window el) → exact-nonneg-integer? or #f
;;     Returns the CGWindowID for an AXUIElement, or #f if the SPI
;;     is unavailable or the call fails.

(require ffi/unsafe)

(provide ax-element-get-window)

;; ─── FFI Bindings ────────────────────────────────────────────

;; _AXUIElementGetWindow(element, *windowID) → AXError
;; Private SPI in ApplicationServices — not in public headers.
;; Returns kAXErrorSuccess (0) on success.
(define _AXUIElementGetWindow-or-false
  (with-handlers ([exn:fail? (lambda (e) #f)])
    (get-ffi-obj '_AXUIElementGetWindow
      (ffi-lib "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices")
      (_fun _pointer _pointer -> _int32))))

;; ─── Public API ─────────────────────────────────────────────

;; (ax-element-get-window el) → exact-nonneg-integer? or #f
;; Returns the CGWindowID associated with the given AXUIElementRef,
;; or #f if the private SPI is unavailable or the call fails.
(define (ax-element-get-window el)
  (cond
    [_AXUIElementGetWindow-or-false
     ;; malloc with no mode flag returns GC-tracked memory; never call free.
     (define buf (malloc _uint32))
     (define err (_AXUIElementGetWindow-or-false el buf))
     (define wid (ptr-ref buf _uint32))
     (if (= err 0) wid #f)]
    [else #f]))
