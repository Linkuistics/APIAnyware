#lang racket/base
;; keymap.rkt — Keycode ↔ character mapping (US ANSI layout)
;;
;; macOS HID key codes map to physical key positions, not characters.
;; Key code 0 is always the "A" position regardless of keyboard layout.
;;
;; This module provides the mapping table, named key constants,
;; modifier flag constants, and helper functions.

(provide keycode->char
         char->keycode
         ;; Named key constants
         KEY-ESCAPE KEY-DELETE KEY-RETURN KEY-SPACE KEY-TAB
         KEY-F1 KEY-F2 KEY-F3 KEY-F4 KEY-F5 KEY-F6
         KEY-F7 KEY-F8 KEY-F9 KEY-F10 KEY-F11 KEY-F12
         KEY-F17 KEY-F18 KEY-F19 KEY-F20
         KEY-UP KEY-DOWN KEY-LEFT KEY-RIGHT
         ;; Modifier masks (CGEventFlags bit positions)
         MOD-CMD MOD-SHIFT MOD-ALT MOD-CTRL
         ;; Modifier helpers
         has-cmd? has-shift? has-alt? has-ctrl?)

;; --- Named key constants (macOS HID key codes) ---

(define KEY-ESCAPE 53)
(define KEY-DELETE 51)
(define KEY-RETURN 36)
(define KEY-SPACE  49)
(define KEY-TAB    48)

;; Function keys
(define KEY-F1  122)
(define KEY-F2  120)
(define KEY-F3   99)
(define KEY-F4  118)
(define KEY-F5   96)
(define KEY-F6   97)
(define KEY-F7   98)
(define KEY-F8  100)
(define KEY-F9  101)
(define KEY-F10 109)
(define KEY-F11 103)
(define KEY-F12 111)
(define KEY-F17  64)
(define KEY-F18  79)
(define KEY-F19  80)
(define KEY-F20  90)

;; Arrow keys
(define KEY-UP    126)
(define KEY-DOWN  125)
(define KEY-LEFT  123)
(define KEY-RIGHT 124)

;; --- Modifier masks (CGEventFlags raw values) ---

(define MOD-CMD    #x100000)  ;; bit 20 — Command
(define MOD-SHIFT  #x020000)  ;; bit 17 — Shift
(define MOD-ALT    #x080000)  ;; bit 19 — Option/Alt
(define MOD-CTRL   #x040000)  ;; bit 18 — Control

;; --- Modifier helpers ---

(define (has-cmd? mods)   (not (zero? (bitwise-and mods MOD-CMD))))
(define (has-shift? mods) (not (zero? (bitwise-and mods MOD-SHIFT))))
(define (has-alt? mods)   (not (zero? (bitwise-and mods MOD-ALT))))
(define (has-ctrl? mods)  (not (zero? (bitwise-and mods MOD-CTRL))))

;; --- US ANSI keycode → character table ---

(define keycode-table
  (hasheqv
   0 "a"  1 "s"  2 "d"  3 "f"  4 "h"  5 "g"
   6 "z"  7 "x"  8 "c"  9 "v"  11 "b"
   12 "q" 13 "w" 14 "e" 15 "r" 16 "y" 17 "t"
   31 "o" 32 "u" 34 "i" 35 "p"
   37 "l" 38 "j" 40 "k"
   45 "n" 46 "m"
   18 "1" 19 "2" 20 "3" 21 "4" 22 "6" 23 "5"
   25 "9" 26 "7" 28 "8" 29 "0"
   24 "=" 27 "-" 30 "]" 33 "["
   39 "'" 41 ";" 42 "\\" 43 "," 44 "/"
   47 "." 50 "`"
   49 " "))

;; Reverse table: character → keycode
(define char-table
  (for/hash ([(kc ch) (in-hash keycode-table)])
    (values ch kc)))

;; --- Public API ---

;; Convert a keycode to its character string, or #f if not a printable key.
(define (keycode->char keycode)
  (hash-ref keycode-table keycode #f))

;; Convert a character string to its keycode, or #f if unknown.
(define (char->keycode char)
  (hash-ref char-table char #f))
