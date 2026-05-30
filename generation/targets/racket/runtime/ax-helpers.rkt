#lang racket/base
;; ax-helpers.rkt — Typed Accessibility attribute access
;;
;; Wraps AXUIElementCopyAttributeValue / AXUIElementSetAttributeValue and
;; AXValue geometry packing so consumer code never touches ffi/unsafe.
;;
;; API:
;;   (ax-get-attribute/string el attr)   → string? or #f
;;   (ax-get-attribute/boolean el attr)  → boolean?
;;   (ax-get-attribute/point el attr)    → (values real? real?) or (values #f #f)
;;   (ax-get-attribute/size el attr)     → (values real? real?) or (values #f #f)
;;   (ax-get-attribute/raw el attr)      → cpointer? or #f       (+1 ownership)
;;   (ax-get-attribute/array el attr)    → list?                  (each elt +1 retained)
;;   (ax-set-position! el x y)           → void
;;   (ax-set-size! el w h)               → void
;;   (ax-get-pid el)                     → exact-integer? or #f

(require ffi/unsafe
         "cf-bridge.rkt")

(provide ax-get-attribute/string
         ax-get-attribute/boolean
         ax-get-attribute/point
         ax-get-attribute/size
         ax-get-attribute/raw
         ax-get-attribute/array
         ax-set-position!
         ax-set-size!
         ax-get-pid)

;; ─── FFI Bindings ────────────────────────────────────────────

(define ax-lib (ffi-lib "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices"))
(define cf-lib (ffi-lib "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))

(define _AXUIElementCopyAttributeValue
  (get-ffi-obj 'AXUIElementCopyAttributeValue ax-lib
    (_fun _pointer _pointer _pointer -> _int32)))

(define _AXUIElementSetAttributeValue
  (get-ffi-obj 'AXUIElementSetAttributeValue ax-lib
    (_fun _pointer _pointer _pointer -> _int32)))

(define _AXUIElementGetPid
  (get-ffi-obj 'AXUIElementGetPid ax-lib
    (_fun _pointer _pointer -> _int32)))

(define _AXValueCreate
  (get-ffi-obj 'AXValueCreate ax-lib
    (_fun _int32 _pointer -> _pointer)))

(define _AXValueGetValue
  (get-ffi-obj 'AXValueGetValue ax-lib
    (_fun _pointer _int32 _pointer -> _bool)))

(define _CFRelease
  (get-ffi-obj 'CFRelease cf-lib
    (_fun _pointer -> _void)))

(define _CFRetain
  (get-ffi-obj 'CFRetain cf-lib
    (_fun _pointer -> _pointer)))

(define _CFBooleanGetValue
  (get-ffi-obj 'CFBooleanGetValue cf-lib
    (_fun _pointer -> _bool)))

;; AXValue type constants (from AXValue.h)
(define kAXValueCGPointType 1)
(define kAXValueCGSizeType  2)

;; AXError success
(define kAXErrorSuccess 0)

;; ─── Internal Helpers ───────────────────────────────────────

;; Copy a raw CFTypeRef attribute value from an AXUIElement.
;; Returns the CFTypeRef pointer (+1 ownership) or #f on failure.
(define (ax-copy-attribute el attr-cfstr)
  (define out (malloc _pointer))
  (ptr-set! out _pointer #f)
  (define err (_AXUIElementCopyAttributeValue el attr-cfstr out))
  (define val (ptr-ref out _pointer))
  (if (= err kAXErrorSuccess)
      val
      #f))

;; ─── Public API ─────────────────────────────────────────────

;; (ax-get-attribute/string el attr) → string? or #f
;; Returns the string value of an accessibility attribute, or #f on failure.
;; el: cpointer? — AXUIElementRef
;; attr: string? — attribute name (e.g. "AXTitle")
(define (ax-get-attribute/string el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (define cf-val (ax-copy-attribute el attr-cf))
    (if cf-val
        (begin0
          (cfstring->racket-string cf-val)
          (_CFRelease cf-val))
        #f)))

;; (ax-get-attribute/boolean el attr) → boolean?
;; Returns the boolean value of an accessibility attribute, or #f on failure.
(define (ax-get-attribute/boolean el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (define cf-val (ax-copy-attribute el attr-cf))
    (if cf-val
        (begin0
          (_CFBooleanGetValue cf-val)
          (_CFRelease cf-val))
        #f)))

;; (ax-get-attribute/point el attr) → (values real? real?) or (values #f #f)
;; Extracts a CGPoint-valued attribute (e.g. "AXPosition").
(define (ax-get-attribute/point el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (define cf-val (ax-copy-attribute el attr-cf))
    (if cf-val
        (let ([buf (malloc _double 2)])
          (define ok (_AXValueGetValue cf-val kAXValueCGPointType buf))
          (_CFRelease cf-val)
          (if ok
              (values (ptr-ref buf _double 0) (ptr-ref buf _double 1))
              (values #f #f)))
        (values #f #f))))

;; (ax-get-attribute/size el attr) → (values real? real?) or (values #f #f)
;; Extracts a CGSize-valued attribute (e.g. "AXSize").
(define (ax-get-attribute/size el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (define cf-val (ax-copy-attribute el attr-cf))
    (if cf-val
        (let ([buf (malloc _double 2)])
          (define ok (_AXValueGetValue cf-val kAXValueCGSizeType buf))
          (_CFRelease cf-val)
          (if ok
              (values (ptr-ref buf _double 0) (ptr-ref buf _double 1))
              (values #f #f)))
        (values #f #f))))

;; (ax-set-position! el x y) → void
;; Sets the AXPosition attribute to (x, y).
(define (ax-set-position! el x y)
  (define buf (malloc _double 2))
  (ptr-set! buf _double 0 (exact->inexact x))
  (ptr-set! buf _double 1 (exact->inexact y))
  (define ax-val (_AXValueCreate kAXValueCGPointType buf))
  (when ax-val
    (with-cf-value [attr-cf (racket-string->cfstring "AXPosition")]
      (_AXUIElementSetAttributeValue el attr-cf ax-val))
    (_CFRelease ax-val)))

;; (ax-set-size! el w h) → void
;; Sets the AXSize attribute to (w, h).
(define (ax-set-size! el w h)
  (define buf (malloc _double 2))
  (ptr-set! buf _double 0 (exact->inexact w))
  (ptr-set! buf _double 1 (exact->inexact h))
  (define ax-val (_AXValueCreate kAXValueCGSizeType buf))
  (when ax-val
    (with-cf-value [attr-cf (racket-string->cfstring "AXSize")]
      (_AXUIElementSetAttributeValue el attr-cf ax-val))
    (_CFRelease ax-val)))

;; (ax-get-attribute/raw el attr) → cpointer? or #f
;; Returns the raw CFTypeRef value of an accessibility attribute, with +1
;; ownership — caller must `cf-release` (or hand to `with-cf-value`) when
;; done. Returns #f on failure (no such attribute, AX error).
;;
;; Use for attribute kinds that don't fit the typed variants — element-typed
;; attributes (focused application, focused window) and any CFTypeRef the
;; caller wants to inspect with the cf-bridge primitives.
(define (ax-get-attribute/raw el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (ax-copy-attribute el attr-cf)))

;; (ax-get-attribute/array el attr) → list?
;; Returns a Racket list of cpointer elements from a CFArray-valued
;; attribute (e.g. "AXWindows", "AXChildren"). Each element pointer is
;; CFRetained so its lifetime is independent of the underlying array;
;; the array itself is released before return. Each element is +1
;; owned — caller must `cf-release` each when done.
;;
;; Returns '() on failure or non-array result.
(define (ax-get-attribute/array el attr)
  (with-cf-value [attr-cf (racket-string->cfstring attr)]
    (define cf-arr (ax-copy-attribute el attr-cf))
    (cond
      [(not cf-arr) '()]
      [else
       (begin0
         (cfarray->list cf-arr _CFRetain)
         (_CFRelease cf-arr))])))

;; (ax-get-pid el) → exact-integer? or #f
;; Returns the PID of the application owning the AXUIElement.
(define (ax-get-pid el)
  (define buf (malloc _int32))
  (define err (_AXUIElementGetPid el buf))
  (define pid (ptr-ref buf _int32))
  (if (= err kAXErrorSuccess) pid #f))
