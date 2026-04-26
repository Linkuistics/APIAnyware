#lang racket/base
;; test-keymap.rkt — Tests for core/keymap.rkt

(require rackunit
         "../core/keymap.rkt")

;; --- keycode->char ---

;; Letter keys (QWERTY layout)
(check-equal? (keycode->char 0) "a")
(check-equal? (keycode->char 1) "s")
(check-equal? (keycode->char 2) "d")
(check-equal? (keycode->char 3) "f")
(check-equal? (keycode->char 12) "q")
(check-equal? (keycode->char 13) "w")
(check-equal? (keycode->char 14) "e")
(check-equal? (keycode->char 15) "r")
(check-equal? (keycode->char 38) "j")
(check-equal? (keycode->char 40) "k")

;; Number keys
(check-equal? (keycode->char 18) "1")
(check-equal? (keycode->char 19) "2")
(check-equal? (keycode->char 29) "0")

;; Special characters
(check-equal? (keycode->char 49) " " "space")
(check-equal? (keycode->char 43) "," "comma")
(check-equal? (keycode->char 47) "." "period")
(check-equal? (keycode->char 24) "=" "equals")
(check-equal? (keycode->char 27) "-" "minus")
(check-equal? (keycode->char 33) "[" "left bracket")
(check-equal? (keycode->char 30) "]" "right bracket")

;; Unknown/non-printable keycodes return #f
(check-false (keycode->char 999))
(check-false (keycode->char KEY-ESCAPE))
(check-false (keycode->char KEY-RETURN))
(check-false (keycode->char KEY-DELETE))
(check-false (keycode->char KEY-F1))

;; --- char->keycode ---

(check-equal? (char->keycode "a") 0)
(check-equal? (char->keycode "j") 38)
(check-equal? (char->keycode " ") 49)
(check-false (char->keycode "A"))  ;; uppercase not in table

;; --- Modifier helpers ---

(check-true  (has-cmd? MOD-CMD))
(check-false (has-cmd? MOD-SHIFT))
(check-true  (has-cmd? (bitwise-ior MOD-CMD MOD-SHIFT)))
(check-true  (has-shift? (bitwise-ior MOD-CMD MOD-SHIFT)))
(check-false (has-alt? MOD-CMD))
(check-true  (has-alt? MOD-ALT))
(check-true  (has-ctrl? MOD-CTRL))
(check-false (has-ctrl? 0))

;; --- Named key constants ---

(check-equal? KEY-ESCAPE 53)
(check-equal? KEY-DELETE 51)
(check-equal? KEY-RETURN 36)
(check-equal? KEY-SPACE 49)
(check-equal? KEY-TAB 48)
(check-equal? KEY-F17 64)
(check-equal? KEY-UP 126)
(check-equal? KEY-DOWN 125)
(check-equal? KEY-LEFT 123)
(check-equal? KEY-RIGHT 124)

(displayln "test-keymap: all checks passed")
