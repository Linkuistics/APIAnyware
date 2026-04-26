#lang racket/base
;; ffi/accessibility.rkt — AXUIElement and CGWindowList bindings
;;
;; High-level wrappers over generated AX/CF bindings and upstream runtime
;; helpers. Zero ffi/unsafe: all typed attribute access routes through
;; bindings/runtime/ax-helpers.rkt (which owns malloc/ptr-ref internally),
;; and the private _AXUIElementGetWindow SPI is wrapped by spi-helpers.rkt.

(require (only-in "../bindings/generated/oo/applicationservices/functions.rkt"
                  AXUIElementCreateSystemWide
                  AXUIElementCreateApplication
                  AXUIElementSetAttributeValue
                  AXUIElementPerformAction)
         (only-in "../bindings/generated/oo/corefoundation/functions.rkt"
                  CFRelease
                  CFArrayGetCount
                  CFArrayGetValueAtIndex
                  CFDictionaryGetValue)
         (only-in "../bindings/generated/oo/coregraphics/functions.rkt"
                  CGWindowListCopyWindowInfo)
         (only-in "../bindings/generated/oo/corefoundation/constants.rkt"
                  kCFBooleanTrue
                  kCFBooleanFalse)
         (only-in "../bindings/generated/oo/coregraphics/constants.rkt"
                  kCGWindowNumber)
         (only-in "../bindings/generated/oo/applicationservices/enums.rkt"
                  kAXErrorSuccess)
         (only-in "../bindings/generated/oo/coregraphics/enums.rkt"
                  kCGWindowListOptionAll
                  kCGWindowListExcludeDesktopElements)
         (only-in "../bindings/generated/oo/applicationservices/constants.rkt"
                  kAXMainAttribute
                  kAXFocusedAttribute
                  kAXRaiseAction)
         (only-in "../bindings/runtime/cf-bridge.rkt"
                  [racket-string->cfstring cfstring]
                  [cfstring->racket-string cfstring->string]
                  [cf-release cf-release!]
                  [cfnumber->integer cfnumber->int])
         (only-in "../bindings/runtime/ax-helpers.rkt"
                  ax-get-attribute/raw
                  ax-get-attribute/array
                  ax-get-attribute/string
                  ax-get-attribute/boolean
                  ax-get-attribute/point
                  ax-get-attribute/size
                  ax-set-position!
                  ax-set-size!
                  ax-get-pid)
         (only-in "../bindings/runtime/spi-helpers.rkt"
                  ax-element-get-window))

(provide ax-system-wide
         ax-app-element
         ax-get-pid
         ax-set-attribute!
         ax-perform-action!
         ax-get-window-id
         ax-get-position
         ax-set-position!
         ax-get-size
         ax-set-size!
         ax-get-title
         ax-get-subrole
         ax-is-minimized?
         ax-is-fullscreen?
         ax-set-fullscreen!
         ax-raise!
         ax-get-focused-app
         ax-get-focused-window
         ax-get-windows
         cg-window-ordering
         cfstring
         cfstring->string
         cf-release!
         kCFBooleanTrue
         kCFBooleanFalse
         kAXMainAttribute
         kAXFocusedAttribute)

;; ─── Attribute setter / action helpers ──────────────────────────
;; These take CFString attributes (kAX* constants) for compatibility
;; with callers that already hold the CFString. Read paths use string
;; attribute names routed through ax-helpers.

(define (ax-set-attribute! element attribute value)
  (= (AXUIElementSetAttributeValue element attribute value) kAXErrorSuccess))

(define (ax-perform-action! element action)
  (= (AXUIElementPerformAction element action) kAXErrorSuccess))

;; ─── System-Wide / App Elements ─────────────────────────────────

(define system-wide-element (AXUIElementCreateSystemWide))

(define (ax-system-wide) system-wide-element)

(define (ax-app-element pid)
  (AXUIElementCreateApplication pid))

;; ─── Window ID (Private SPI) ────────────────────────────────────

(define (ax-get-window-id element)
  (ax-element-get-window element))

;; ─── Focused App/Window ─────────────────────────────────────────
;; Both return +1 owned CFTypeRef (caller must cf-release!).

(define (ax-get-focused-app)
  (ax-get-attribute/raw system-wide-element "AXFocusedApplication"))

(define (ax-get-focused-window app-element)
  (ax-get-attribute/raw app-element "AXFocusedWindow"))

;; ─── Window List for App ────────────────────────────────────────
;; Each element is +1 retained (caller must cf-release! each).

(define (ax-get-windows app-element)
  (ax-get-attribute/array app-element "AXWindows"))

;; ─── Position/Size ──────────────────────────────────────────────

;; Returns (cons x y) or #f.
(define (ax-get-position element)
  (define-values (x y) (ax-get-attribute/point element "AXPosition"))
  (and x (cons x y)))

;; Returns (cons width height) or #f.
(define (ax-get-size element)
  (define-values (w h) (ax-get-attribute/size element "AXSize"))
  (and w (cons w h)))

;; ─── Title/Subrole ──────────────────────────────────────────────

(define (ax-get-title element)
  (ax-get-attribute/string element "AXTitle"))

(define (ax-get-subrole element)
  (ax-get-attribute/string element "AXSubrole"))

;; ─── Minimized/Fullscreen ───────────────────────────────────────

(define (ax-is-minimized? element)
  (ax-get-attribute/boolean element "AXMinimized"))

(define (ax-is-fullscreen? element)
  (ax-get-attribute/boolean element "AXFullScreen"))

;; kAXFullScreenAttribute is not in generated constants (only the
;; button variant). Create the CFString at module load.
(define kAXFullScreenAttribute (cfstring "AXFullScreen"))

(define (ax-set-fullscreen! element fullscreen?)
  (ax-set-attribute! element kAXFullScreenAttribute
    (if fullscreen? kCFBooleanTrue kCFBooleanFalse)))

;; ─── Raise Window ───────────────────────────────────────────────

(define (ax-raise! element)
  (ax-perform-action! element kAXRaiseAction))

;; ─── CGWindowList Ordering ──────────────────────────────────────
;; Returns a hash of CGWindowID → z-order index (0 = frontmost).

(define kCGNullWindowID 0)  ; CGWindowID typedef, not an enum

(define (cg-window-ordering)
  (define info-list
    (CGWindowListCopyWindowInfo
     (bitwise-ior kCGWindowListOptionAll kCGWindowListExcludeDesktopElements)
     kCGNullWindowID))
  (if info-list
      (let ([count (CFArrayGetCount info-list)]
            [ordering (make-hasheqv)])
        (for ([i (in-range count)])
          (define dict (CFArrayGetValueAtIndex info-list i))
          (define wid-val (CFDictionaryGetValue dict kCGWindowNumber))
          (when wid-val
            (define wid (cfnumber->int wid-val))
            (when wid
              (hash-set! ordering wid i))))
        (CFRelease info-list)
        ordering)
      (make-hasheqv)))
