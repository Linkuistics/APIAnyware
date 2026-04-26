#lang racket/base
;; test-cgevent-emitter.rkt — Tests for ffi/cgevent-emitter.rkt
;;
;; Tests the key lookup and modifier parsing functions.
;; Does NOT test actual keystroke emission (that requires Accessibility
;; permissions and would type into the active window).

(require rackunit
         "../ffi/cgevent-emitter.rkt"
         "../core/keymap.rkt")

;; --- char->keycode-or-named ---

;; Character keys
(check-equal? (char->keycode-or-named "a") 0)
(check-equal? (char->keycode-or-named "t") 17)
(check-equal? (char->keycode-or-named " ") 49)

;; Case-insensitive
(check-equal? (char->keycode-or-named "A") 0)
(check-equal? (char->keycode-or-named "T") 17)

;; Named keys
(check-equal? (char->keycode-or-named "return") KEY-RETURN)
(check-equal? (char->keycode-or-named "enter") KEY-RETURN)
(check-equal? (char->keycode-or-named "tab") KEY-TAB)
(check-equal? (char->keycode-or-named "space") KEY-SPACE)
(check-equal? (char->keycode-or-named "delete") KEY-DELETE)
(check-equal? (char->keycode-or-named "backspace") KEY-DELETE)
(check-equal? (char->keycode-or-named "escape") KEY-ESCAPE)
(check-equal? (char->keycode-or-named "esc") KEY-ESCAPE)

;; Arrow keys
(check-equal? (char->keycode-or-named "left") KEY-LEFT)
(check-equal? (char->keycode-or-named "right") KEY-RIGHT)
(check-equal? (char->keycode-or-named "up") KEY-UP)
(check-equal? (char->keycode-or-named "down") KEY-DOWN)

;; Function keys
(check-equal? (char->keycode-or-named "f1") KEY-F1)
(check-equal? (char->keycode-or-named "f12") KEY-F12)
(check-equal? (char->keycode-or-named "f17") KEY-F17)
(check-equal? (char->keycode-or-named "f18") KEY-F18)

;; Named keys are case-insensitive
(check-equal? (char->keycode-or-named "Return") KEY-RETURN)
(check-equal? (char->keycode-or-named "ESCAPE") KEY-ESCAPE)
(check-equal? (char->keycode-or-named "F1") KEY-F1)

;; Unknown key returns #f
(check-false (char->keycode-or-named "unknown_key"))

;; --- parse-modifier-symbols ---

(check-equal? (parse-modifier-symbols '()) 0
              "empty list = no modifiers")

(check-equal? (parse-modifier-symbols '(cmd)) MOD-CMD)
(check-equal? (parse-modifier-symbols '(command)) MOD-CMD)
(check-equal? (parse-modifier-symbols '(alt)) MOD-ALT)
(check-equal? (parse-modifier-symbols '(option)) MOD-ALT)
(check-equal? (parse-modifier-symbols '(shift)) MOD-SHIFT)
(check-equal? (parse-modifier-symbols '(ctrl)) MOD-CTRL)
(check-equal? (parse-modifier-symbols '(control)) MOD-CTRL)

;; Combined modifiers
(check-equal? (parse-modifier-symbols '(cmd shift))
              (bitwise-ior MOD-CMD MOD-SHIFT))

(check-equal? (parse-modifier-symbols '(cmd alt shift ctrl))
              (bitwise-ior MOD-CMD (bitwise-ior MOD-ALT (bitwise-ior MOD-SHIFT MOD-CTRL))))

;; Unknown modifier symbols are ignored
(check-equal? (parse-modifier-symbols '(cmd foo bar)) MOD-CMD
              "unknown modifiers should be ignored")

(displayln "test-cgevent-emitter: all checks passed")
