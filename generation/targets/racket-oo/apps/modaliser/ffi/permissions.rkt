#lang racket/base
;; permissions.rkt — Accessibility permission check
;;
;; CGEvent tap requires Accessibility permissions. This module provides
;; functions to check the current trust status and prompt the user.
;;
;; Migrated: All ffi/unsafe usage eliminated. Uses generated bindings
;; for AX/CF functions and constants, cf-bridge for dictionary construction.

(require ;; ─── Generated bindings: AX permission functions ───────────
         (only-in "../bindings/generated/oo/applicationservices/functions.rkt"
                  AXIsProcessTrusted
                  AXIsProcessTrustedWithOptions)
         ;; ─── Generated bindings: constants ─────────────────────────
         (only-in "../bindings/generated/oo/applicationservices/constants.rkt"
                  kAXTrustedCheckOptionPrompt)
         (only-in "../bindings/generated/oo/corefoundation/constants.rkt"
                  kCFBooleanTrue)
         ;; ─── Runtime helpers: CF dictionary construction ───────────
         (only-in "../bindings/runtime/cf-bridge.rkt"
                  make-cfdictionary
                  cf-release))

(provide accessibility-trusted?
         request-accessibility!)

;; ─── Public API ─────────────────────────────────────────────────

;; Check if the process has Accessibility access (no prompt).
(define (accessibility-trusted?)
  (AXIsProcessTrusted))

;; Check and prompt for Accessibility access if not yet granted.
;; Shows the system permission dialog on first call.
;; Returns #t if trusted, #f if not.
(define (request-accessibility!)
  (define opts
    (make-cfdictionary (list kAXTrustedCheckOptionPrompt)
                       (list kCFBooleanTrue)))
  (begin0
    (AXIsProcessTrustedWithOptions opts)
    (cf-release opts)))
