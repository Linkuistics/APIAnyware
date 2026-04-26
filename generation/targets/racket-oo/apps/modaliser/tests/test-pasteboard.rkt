#lang racket/base
;; test-pasteboard.rkt — Tests for services/pasteboard.rkt
;;
;; Requires AppKit bindings (loads NSPasteboard). Manipulates the real
;; system clipboard — saves and restores original contents.

(require rackunit
         "../services/pasteboard.rkt")

;; Save current clipboard to restore at the end
(define original-clipboard (get-clipboard))

;; --- get-clipboard ---

;; Should return a string (possibly empty)
(check-true (string? (get-clipboard))
            "get-clipboard should return a string")

;; --- set-clipboard! ---

;; Write a known value and read it back
(set-clipboard! "modaliser-test-value-12345")
(check-equal? (get-clipboard) "modaliser-test-value-12345"
              "should read back the value we wrote")

;; Write empty string
(set-clipboard! "")
(check-equal? (get-clipboard) ""
              "should handle empty string")

;; Write a string with special characters
(set-clipboard! "hello\nworld\ttab")
(check-equal? (get-clipboard) "hello\nworld\ttab"
              "should handle newlines and tabs")

;; Write unicode
(set-clipboard! "café ñ 日本語")
(check-equal? (get-clipboard) "café ñ 日本語"
              "should handle unicode")

;; --- Restore original clipboard ---
(set-clipboard! original-clipboard)

(displayln "test-pasteboard: all checks passed")
