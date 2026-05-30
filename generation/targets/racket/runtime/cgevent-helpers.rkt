#lang racket/base
;; cgevent-helpers.rkt — CGEvent tap creation without ffi/unsafe in consumer code
;;
;; Wraps CGEventTapCreate + CFRunLoop integration. The tap callback fires
;; on the main OS thread (CFRunLoopGetMain), so _cprocedure is safe here
;; without #:async-apply.
;;
;; API:
;;   (make-cgevent-tap handler [#:on-disabled cb]) → (values cpointer? cpointer?)
;;     handler: (keycode modifiers key-down? → 'suppress or 'pass-through)
;;     #:on-disabled cb: (event-type tap → any) called when the system
;;       posts kCGEventTapDisabledByTimeout / kCGEventTapDisabledByUserInput.
;;       If omitted (default), the tap is automatically re-enabled — the
;;       documented remedy for timeout events. Provide a callback when you
;;       need to log, telemetrise, or conditionally suppress re-enabling.
;;     Returns: (values tap-mach-port run-loop-source)
;;     Both are #f if tap creation fails (no accessibility permission).
;;
;;   (cgevent-tap-enable! tap enable?) → void
;;     Enable or disable an existing tap. Available to on-disabled callbacks
;;     that need to re-enable explicitly after their own bookkeeping.
;;
;;   kCGEventTapDisabledByTimeout, kCGEventTapDisabledByUserInput
;;     Event-type constants exported so callers can branch on the exact
;;     reason the system disabled the tap.

(require ffi/unsafe)

(provide make-cgevent-tap
         cgevent-tap-enable!
         kCGEventTapDisabledByTimeout
         kCGEventTapDisabledByUserInput)

;; ─── FFI Bindings ────────────────────────────────────────────

(define cg-lib (ffi-lib "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics"))
(define cf-lib (ffi-lib "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))

;; CGEventTapCreate(tap, place, options, eventsOfInterest, callback, userInfo) → CFMachPortRef
(define _CGEventTapCreate
  (get-ffi-obj 'CGEventTapCreate cg-lib
    (_fun _int32       ; CGEventTapLocation
          _int32       ; CGEventTapPlacement
          _int32       ; CGEventTapOptions
          _uint64      ; CGEventMask
          _fpointer    ; CGEventTapCallBack
          _pointer     ; userInfo
          -> _pointer)))

;; CGEventTapEnable(tap, enable)
(define _CGEventTapEnable
  (get-ffi-obj 'CGEventTapEnable cg-lib
    (_fun _pointer _bool -> _void)))

;; CGEventGetIntegerValueField(event, field) → int64
(define _CGEventGetIntegerValueField
  (get-ffi-obj 'CGEventGetIntegerValueField cg-lib
    (_fun _pointer _uint32 -> _int64)))

;; CGEventGetFlags(event) → uint64
(define _CGEventGetFlags
  (get-ffi-obj 'CGEventGetFlags cg-lib
    (_fun _pointer -> _uint64)))

;; CFMachPortCreateRunLoopSource(allocator, port, order) → CFRunLoopSourceRef
(define _CFMachPortCreateRunLoopSource
  (get-ffi-obj 'CFMachPortCreateRunLoopSource cf-lib
    (_fun _pointer _pointer _long -> _pointer)))

;; CFRunLoopGetMain() → CFRunLoopRef
(define _CFRunLoopGetMain
  (get-ffi-obj 'CFRunLoopGetMain cf-lib
    (_fun -> _pointer)))

;; CFRunLoopAddSource(rl, source, mode)
(define _CFRunLoopAddSource
  (get-ffi-obj 'CFRunLoopAddSource cf-lib
    (_fun _pointer _pointer _pointer -> _void)))

;; kCFRunLoopCommonModes — global CFStringRef
(define dlsym
  (get-ffi-obj "dlsym" (ffi-lib #f)
    (_fun _pointer _string -> _pointer)))
(define RTLD_DEFAULT (cast -2 _intptr _pointer))
(define kCFRunLoopCommonModes
  (ptr-ref (dlsym RTLD_DEFAULT "kCFRunLoopCommonModes") _pointer))

;; ─── Constants ──────────────────────────────────────────────

;; CGEventTapLocation
(define kCGHIDEventTap 0)

;; CGEventTapPlacement
(define kCGHeadInsertEventTap 0)

;; CGEventTapOptions
(define kCGEventTapOptionDefault 0)  ; active (can suppress)

;; CGEventMask — keyboard events
(define CGEventMaskBit (lambda (type) (arithmetic-shift 1 type)))
(define kCGEventKeyDown  10)
(define kCGEventKeyUp    11)
(define kCGEventFlagsChanged 12)
(define keyboard-event-mask
  (bitwise-ior (CGEventMaskBit kCGEventKeyDown)
               (CGEventMaskBit kCGEventKeyUp)
               (CGEventMaskBit kCGEventFlagsChanged)))

;; CGEventField
(define kCGKeyboardEventKeycode 9)

;; Synthetic CGEventType values posted by the system when it disables a tap.
;; Decimal forms of the 0xFFFFFFFE / 0xFFFFFFFF unsigned constants, since
;; the trampoline reads `_uint32`.
(define kCGEventTapDisabledByTimeout   #xFFFFFFFE)
(define kCGEventTapDisabledByUserInput #xFFFFFFFF)

;; ─── Callback infrastructure ────────────────────────────────

;; CGEventTapCallBack type:
;;   (proxy, type, event, userInfo) → CGEventRef or NULL
(define _CGEventTapCallBack
  (_cprocedure (list _pointer _uint32 _pointer _pointer) _pointer))

;; Module-level storage for the handler and function-ptr to prevent GC.
;; Only one tap per process is typical; if multiple are needed this could
;; be extended to a registry keyed by tap pointer.
(define current-handler (box #f))
(define current-fptr (box #f))

(define (handle-tap-disabled type tap-box on-disabled)
  (define tap (unbox tap-box))
  (cond
    [on-disabled
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "cgevent-tap on-disabled callback error: ~a\n"
                                 (exn-message e)))])
       (on-disabled type tap))]
    [tap
     ;; Default: re-enable. Apple's documented remedy for the timeout
     ;; case is to call CGEventTapEnable(tap, true).
     (_CGEventTapEnable tap #t)]))

(define (make-tap-callback handler on-disabled tap-box)
  (define proc
    (lambda (proxy type event user-info)
      (cond
        [(or (= type kCGEventTapDisabledByTimeout)
             (= type kCGEventTapDisabledByUserInput))
         (handle-tap-disabled type tap-box on-disabled)
         event]
        [else
         (define keycode (_CGEventGetIntegerValueField event kCGKeyboardEventKeycode))
         (define modifiers (_CGEventGetFlags event))
         (define key-down? (= type kCGEventKeyDown))
         (with-handlers ([exn:fail?
                          (lambda (e)
                            (eprintf "cgevent-tap callback error: ~a\n" (exn-message e))
                            event)])
           (define result (handler keycode modifiers key-down?))
           (if (eq? result 'suppress) #f event))])))
  (set-box! current-handler proc)
  (define fptr (function-ptr proc _CGEventTapCallBack))
  (set-box! current-fptr fptr)
  fptr)

;; ─── Public API ─────────────────────────────────────────────

;; (make-cgevent-tap handler [#:on-disabled cb]) → (values cpointer? cpointer?)
;;
;; handler: (keycode modifiers key-down? → 'suppress or 'pass-through)
;;   keycode    — exact-integer? (virtual keycode)
;;   modifiers  — exact-nonneg-integer? (CGEventFlags bitmask)
;;   key-down?  — boolean? (#t for key-down, #f for key-up/flags-changed)
;;
;; #:on-disabled cb — optional. (event-type tap → any) called when the
;;   system posts kCGEventTapDisabledByTimeout (callback too slow) or
;;   kCGEventTapDisabledByUserInput (user disabled). The callback receives
;;   the raw event-type code (one of the two constants above) and the
;;   tap pointer; it must call cgevent-tap-enable! itself if it wants
;;   the tap to keep running. When omitted, the tap is auto-re-enabled
;;   on every disabled event.
;;
;; Creates a CGEvent tap for keyboard events, installs it on the main
;; CFRunLoop, and enables it. Returns (values tap-port run-loop-source),
;; or (values #f #f) if creation fails (typically no accessibility permission).
(define (make-cgevent-tap handler #:on-disabled [on-disabled #f])
  (define tap-box (box #f))
  (define fptr (make-tap-callback handler on-disabled tap-box))
  (define tap (_CGEventTapCreate kCGHIDEventTap
                                 kCGHeadInsertEventTap
                                 kCGEventTapOptionDefault
                                 keyboard-event-mask
                                 fptr
                                 #f))
  (cond
    [(not tap)
     (values #f #f)]
    [(ptr-equal? tap #f)
     (values #f #f)]
    [else
     (set-box! tap-box tap)
     (define source (_CFMachPortCreateRunLoopSource #f tap 0))
     (define rl (_CFRunLoopGetMain))
     (_CFRunLoopAddSource rl source kCFRunLoopCommonModes)
     (_CGEventTapEnable tap #t)
     (values tap source)]))

;; (cgevent-tap-enable! tap enable?) → void
;; Enable or disable an existing event tap.
(define (cgevent-tap-enable! tap enable?)
  (_CGEventTapEnable tap enable?))
