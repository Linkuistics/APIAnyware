#lang racket/base
;; cgevent-emitter.rkt — Synthetic keystroke emission via CGEvent
;;
;; Posts keyboard events to the system using CGEventCreateKeyboardEvent
;; and CGEventPost. Used by the DSL's send-keystroke to simulate typing.
;;
;; This is the emission counterpart to cgevent.rkt (which captures events).

(require racket/string
         "../core/keymap.rkt"
         (only-in "../bindings/generated/oo/coregraphics/functions.rkt"
                  CGEventSourceCreate
                  CGEventCreateKeyboardEvent
                  CGEventSetFlags
                  CGEventPost)
         (only-in "../bindings/generated/oo/coregraphics/enums.rkt"
                  kCGEventSourceStateCombinedSessionState
                  kCGHIDEventTap)
         (only-in "../bindings/generated/oo/corefoundation/functions.rkt"
                  CFRelease))

(provide send-keystroke
         char->keycode-or-named
         ;; Re-export modifier constants for convenience
         MOD-CMD MOD-SHIFT MOD-ALT MOD-CTRL)

;; --- Key lookup tables ---
;; Uses hash (equal? comparison) for correct string key lookup.
;; keymap.rkt's char->keycode uses hasheq (eq?), which breaks with
;; dynamically-constructed strings. We build our own equal?-based table.

(define char-keycode-table
  (hash
   "a" 0  "s" 1  "d" 2  "f" 3  "h" 4  "g" 5
   "z" 6  "x" 7  "c" 8  "v" 9  "b" 11
   "q" 12 "w" 13 "e" 14 "r" 15 "y" 16 "t" 17
   "o" 31 "u" 32 "i" 34 "p" 35
   "l" 37 "j" 38 "k" 40
   "n" 45 "m" 46
   "1" 18 "2" 19 "3" 20 "4" 21 "5" 23 "6" 22
   "7" 26 "8" 28 "9" 25 "0" 29
   "=" 24 "-" 27 "]" 30 "[" 33
   "'" 39 ";" 41 "\\" 42 "," 43 "/" 44
   "." 47 "`" 50
   " " 49))

(define named-key-table
  (hash
   "return" KEY-RETURN  "enter"     KEY-RETURN
   "tab"    KEY-TAB     "space"     KEY-SPACE
   "delete" KEY-DELETE  "backspace" KEY-DELETE
   "escape" KEY-ESCAPE  "esc"       KEY-ESCAPE
   "left"   KEY-LEFT    "right"     KEY-RIGHT
   "down"   KEY-DOWN    "up"        KEY-UP
   "f1" KEY-F1  "f2" KEY-F2   "f3" KEY-F3   "f4" KEY-F4
   "f5" KEY-F5  "f6" KEY-F6   "f7" KEY-F7   "f8" KEY-F8
   "f9" KEY-F9  "f10" KEY-F10 "f11" KEY-F11  "f12" KEY-F12
   "f17" KEY-F17  "f18" KEY-F18  "f19" KEY-F19  "f20" KEY-F20))

;; Look up keycode by character or named key (case-insensitive).
;; Returns keycode or #f.
(define (char->keycode-or-named key-string)
  (define lower (string-downcase key-string))
  (or (hash-ref char-keycode-table lower #f)
      (hash-ref named-key-table lower #f)))

;; --- Public API ---

;; Send a synthetic keystroke with optional modifier flags.
;; key-string: character ("t") or named key ("return", "left", "f1")
;; modifiers: bitwise OR of MOD-CMD, MOD-SHIFT, MOD-ALT, MOD-CTRL (default 0)
;; Returns #t on success, #f if key is unknown.
(define (send-keystroke key-string [modifiers 0])
  (define keycode (char->keycode-or-named key-string))
  (cond
    [(not keycode)
     (displayln (format "cgevent-emitter: unknown key ~s" key-string))
     #f]
    [else
     (define source (CGEventSourceCreate kCGEventSourceStateCombinedSessionState))
     (define key-down (CGEventCreateKeyboardEvent source keycode #t))
     (define key-up   (CGEventCreateKeyboardEvent source keycode #f))

     (cond
       [(or (not key-down) (not key-up))
        (displayln "cgevent-emitter: failed to create keyboard event")
        (when key-down (CFRelease key-down))
        (when key-up   (CFRelease key-up))
        (when source   (CFRelease source))
        #f]
       [else
        ;; Set modifier flags on both events
        (unless (zero? modifiers)
          (CGEventSetFlags key-down modifiers)
          (CGEventSetFlags key-up modifiers))

        ;; Post events, ensuring CF objects are released even on exception
        (dynamic-wind
          void
          (lambda ()
            (CGEventPost kCGHIDEventTap key-down)
            (CGEventPost kCGHIDEventTap key-up)
            #t)
          (lambda ()
            (CFRelease key-down)
            (CFRelease key-up)
            (when source (CFRelease source))))])]))

;; --- Helper: parse modifier symbols from a list ---
;; Used by the DSL: (send-keystroke '(cmd shift) "t")

(provide parse-modifier-symbols)

(define (parse-modifier-symbols mod-list)
  (for/fold ([flags 0])
            ([mod (in-list mod-list)])
    (bitwise-ior
     flags
     (case mod
       [(cmd command)  MOD-CMD]
       [(alt option)   MOD-ALT]
       [(shift)        MOD-SHIFT]
       [(ctrl control) MOD-CTRL]
       [else 0]))))
