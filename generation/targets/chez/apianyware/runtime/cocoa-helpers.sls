;; runtime/cocoa-helpers.sls — chez target heavy Cocoa helpers.
;;
;; Absorbs from racket: cgevent-helpers.rkt, ax-helpers.rkt, spi-helpers.rkt.
;; Split out from `cocoa.sls` because the CGEventTap callback infrastructure
;; and the AX surface together dwarf the core helpers (design spec §2's
;; split-if-unwieldy escape hatch).
;;
;; Deferred to the drawing-canvas port leaf (`.grove/050-chez-target/140`):
;;   - The `define-objc-subclass` macro and its ObjC type-encoding parser.
;;     Drawing-canvas is the only sample app that exercises it; the macro
;;     should be designed against drawing-canvas's actual call sites rather
;;     than the racket version's interface assumed-in-the-abstract.

(library (apianyware runtime cocoa-helpers)
  (export
    ;; CGEvent tap
    make-cgevent-tap cgevent-tap-enable!
    kCGEventTapDisabledByTimeout kCGEventTapDisabledByUserInput
    kCGKeyboardEventKeycode
    ;; Accessibility
    ax-get-attribute/string ax-get-attribute/boolean
    ax-get-attribute/point  ax-get-attribute/size
    ax-get-attribute/raw    ax-get-attribute/array
    ax-set-position! ax-set-size! ax-get-pid
    ;; SPI
    ax-element-get-window)
  (import (chezscheme)
          (apianyware runtime ffi)
          (apianyware runtime objc)
          (apianyware runtime types))

  ;; Load CoreGraphics + ApplicationServices. CoreFoundation is loaded by
  ;; runtime/types at its own invoke.
  (define %frameworks-loaded
    (begin
      (load-shared-object
        "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")
      (load-shared-object
        "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices")
      #t))

  ;; --- CGEvent tap ---------------------------------------------------

  (define %CGEventTapCreate
    (foreign-procedure "CGEventTapCreate"
                       (integer-32 integer-32 integer-32 unsigned-64 void* void*)
                       void*))

  (define %CGEventTapEnable
    (foreign-procedure "CGEventTapEnable" (void* boolean) void))

  (define %CGEventGetIntegerValueField
    (foreign-procedure "CGEventGetIntegerValueField"
                       (void* unsigned-32) integer-64))

  (define %CGEventGetFlags
    (foreign-procedure "CGEventGetFlags" (void*) unsigned-64))

  (define %CFMachPortCreateRunLoopSource
    (foreign-procedure "CFMachPortCreateRunLoopSource"
                       (void* void* integer-64) void*))

  (define %CFRunLoopGetMain
    (foreign-procedure "CFRunLoopGetMain" () void*))

  (define %CFRunLoopAddSource
    (foreign-procedure "CFRunLoopAddSource" (void* void* void*) void))

  ;; kCFRunLoopCommonModes is a CFStringRef *variable* — read the pointer
  ;; value at the symbol's address.
  (define kCFRunLoopCommonModes
    (foreign-ref 'uptr (foreign-entry "kCFRunLoopCommonModes") 0))

  ;; CGEventTapLocation / Placement / Options
  (define kCGHIDEventTap            0)
  (define kCGHeadInsertEventTap     0)
  (define kCGEventTapOptionDefault  0)

  ;; CGEventMask bits
  (define kCGEventKeyDown        10)
  (define kCGEventKeyUp          11)
  (define kCGEventFlagsChanged   12)

  (define (cg-event-mask-bit type) (bitwise-arithmetic-shift-left 1 type))

  (define keyboard-event-mask
    (bitwise-ior (cg-event-mask-bit kCGEventKeyDown)
                 (cg-event-mask-bit kCGEventKeyUp)
                 (cg-event-mask-bit kCGEventFlagsChanged)))

  (define kCGKeyboardEventKeycode 9)
  (define kCGEventTapDisabledByTimeout   #xFFFFFFFE)
  (define kCGEventTapDisabledByUserInput #xFFFFFFFF)

  ;; Module-level state for the (single) active tap. Multiple concurrent
  ;; taps would need a registry keyed by tap pointer; one is fine.
  (define %tap-handler     (box #f))
  (define %tap-on-disabled (box #f))
  (define %tap-pointer     (box 0))

  (define (%handle-tap-disabled type)
    (let ([cb  (unbox %tap-on-disabled)]
          [tap (unbox %tap-pointer)])
      (cond
        [cb
         (guard (c [#t
                    (let ([p (current-error-port)])
                      (display "[chez cocoa] cgevent on-disabled raised: " p)
                      (display-condition c p)
                      (newline p))])
           (cb type tap))]
        [(not (zero? tap)) (%CGEventTapEnable tap #t)])))

  (define %cgevent-callback-code
    (foreign-callable
      (lambda (proxy type event user-info)
        (cond
          [(or (= type kCGEventTapDisabledByTimeout)
               (= type kCGEventTapDisabledByUserInput))
           (%handle-tap-disabled type)
           event]
          [else
           (let ([h (unbox %tap-handler)])
             (cond
               [(not h) event]
               [else
                (let* ([keycode   (%CGEventGetIntegerValueField
                                     event kCGKeyboardEventKeycode)]
                       [modifiers (%CGEventGetFlags event)]
                       [key-down? (= type kCGEventKeyDown)])
                  (guard (c [#t
                             (let ([p (current-error-port)])
                               (display "[chez cocoa] cgevent handler raised: " p)
                               (display-condition c p)
                               (newline p))
                             event])
                    (if (eq? (h keycode modifiers key-down?) 'suppress)
                        0
                        event)))]))]))
      (void* unsigned-32 void* void*)
      void*))

  (define %cgevent-callback-locked
    (begin (lock-object %cgevent-callback-code) #t))

  (define %cgevent-callback-fp
    (foreign-callable-entry-point %cgevent-callback-code))

  ;; (make-cgevent-tap handler [on-disabled]) → (values tap source) or
  ;; (values 0 0) on failure (typically no accessibility permission).
  (define make-cgevent-tap
    (case-lambda
      [(handler) (make-cgevent-tap handler #f)]
      [(handler on-disabled)
       (set-box! %tap-handler handler)
       (set-box! %tap-on-disabled on-disabled)
       (let ([tap (%CGEventTapCreate kCGHIDEventTap
                                     kCGHeadInsertEventTap
                                     kCGEventTapOptionDefault
                                     keyboard-event-mask
                                     %cgevent-callback-fp
                                     0)])
         (cond
           [(or (not tap) (zero? tap))
            (values 0 0)]
           [else
            (set-box! %tap-pointer tap)
            (let* ([source (%CFMachPortCreateRunLoopSource 0 tap 0)]
                   [rl     (%CFRunLoopGetMain)])
              (%CFRunLoopAddSource rl source kCFRunLoopCommonModes)
              (%CGEventTapEnable tap #t)
              (values tap source))]))]))

  (define (cgevent-tap-enable! tap enable?)
    (%CGEventTapEnable tap enable?))

  ;; --- Accessibility -------------------------------------------------

  (define %AXUIElementCopyAttributeValue
    (foreign-procedure "AXUIElementCopyAttributeValue"
                       (void* void* void*) integer-32))

  (define %AXUIElementSetAttributeValue
    (foreign-procedure "AXUIElementSetAttributeValue"
                       (void* void* void*) integer-32))

  (define %AXUIElementGetPid
    (foreign-procedure "AXUIElementGetPid" (void* void*) integer-32))

  (define %AXValueCreate
    (foreign-procedure "AXValueCreate" (integer-32 void*) void*))

  (define %AXValueGetValue
    (foreign-procedure "AXValueGetValue" (void* integer-32 void*) boolean))

  (define kAXValueCGPointType 1)
  (define kAXValueCGSizeType  2)
  (define kAXErrorSuccess     0)

  (define %CFRetain
    (foreign-procedure "CFRetain" (void*) void*))

  ;; Copy a raw CFTypeRef attribute. Returns the CF pointer (+1) or 0.
  (define (%ax-copy-attribute el attr-cfstr)
    (let ([out (foreign-alloc 8)])
      (foreign-set! 'uptr out 0 0)
      (let ([err (%AXUIElementCopyAttributeValue el attr-cfstr out)])
        (let ([val (foreign-ref 'uptr out 0)])
          (foreign-free out)
          (if (= err kAXErrorSuccess) val 0)))))

  (define (ax-get-attribute/string el attr)
    (with-cf-value [attr-cf (string->cfstring attr)]
      (let ([cf-val (%ax-copy-attribute el attr-cf)])
        (cond
          [(zero? cf-val) #f]
          [else
           (let ([s (cfstring->string cf-val)])
             (cf-release cf-val)
             s)]))))

  (define (ax-get-attribute/boolean el attr)
    (with-cf-value [attr-cf (string->cfstring attr)]
      (let ([cf-val (%ax-copy-attribute el attr-cf)])
        (cond
          [(zero? cf-val) #f]
          [else
           (let ([b (cfboolean->boolean cf-val)])
             (cf-release cf-val)
             b)]))))

  (define (%ax-get-attribute/geometry el attr type-tag)
    (with-cf-value [attr-cf (string->cfstring attr)]
      (let ([cf-val (%ax-copy-attribute el attr-cf)])
        (cond
          [(zero? cf-val) (values #f #f)]
          [else
           (let* ([buf (foreign-alloc 16)]
                  [ok  (%AXValueGetValue cf-val type-tag buf)])
             (cf-release cf-val)
             (cond
               [ok
                (let ([a (foreign-ref 'double-float buf 0)]
                      [b (foreign-ref 'double-float buf 8)])
                  (foreign-free buf)
                  (values a b))]
               [else (foreign-free buf) (values #f #f)]))]))))

  (define (ax-get-attribute/point el attr)
    (%ax-get-attribute/geometry el attr kAXValueCGPointType))

  (define (ax-get-attribute/size el attr)
    (%ax-get-attribute/geometry el attr kAXValueCGSizeType))

  (define (ax-get-attribute/raw el attr)
    (with-cf-value [attr-cf (string->cfstring attr)]
      (let ([v (%ax-copy-attribute el attr-cf)])
        (if (zero? v) #f v))))

  (define (ax-get-attribute/array el attr)
    (with-cf-value [attr-cf (string->cfstring attr)]
      (let ([cf-arr (%ax-copy-attribute el attr-cf)])
        (cond
          [(zero? cf-arr) '()]
          [else
           (let ([result (cfarray->list cf-arr %CFRetain)])
             (cf-release cf-arr)
             result)]))))

  (define (%ax-set-geometry! el attr type-tag a b)
    (let ([buf (foreign-alloc 16)])
      (foreign-set! 'double-float buf 0 (if (flonum? a) a (exact->inexact a)))
      (foreign-set! 'double-float buf 8 (if (flonum? b) b (exact->inexact b)))
      (let ([ax-val (%AXValueCreate type-tag buf)])
        (foreign-free buf)
        (when (and ax-val (not (zero? ax-val)))
          (with-cf-value [attr-cf (string->cfstring attr)]
            (%AXUIElementSetAttributeValue el attr-cf ax-val))
          (cf-release ax-val)))))

  (define (ax-set-position! el x y)
    (%ax-set-geometry! el "AXPosition" kAXValueCGPointType x y))

  (define (ax-set-size! el w h)
    (%ax-set-geometry! el "AXSize" kAXValueCGSizeType w h))

  (define (ax-get-pid el)
    (let ([buf (foreign-alloc 4)])
      (let ([err (%AXUIElementGetPid el buf)])
        (let ([pid (foreign-ref 'integer-32 buf 0)])
          (foreign-free buf)
          (if (= err kAXErrorSuccess) pid #f)))))

  ;; --- SPI: _AXUIElementGetWindow ------------------------------------

  (define %ax-get-window-avail
    (foreign-entry? "_AXUIElementGetWindow"))

  (define %ax-get-window
    (if %ax-get-window-avail
        (foreign-procedure "_AXUIElementGetWindow" (void* void*) integer-32)
        #f))

  (define (ax-element-get-window el)
    (cond
      [(not %ax-get-window) #f]
      [else
       (let ([buf (foreign-alloc 4)])
         (let ([err (%ax-get-window el buf)])
           (let ([wid (foreign-ref 'unsigned-32 buf 0)])
             (foreign-free buf)
             (if (= err 0) wid #f))))])))
