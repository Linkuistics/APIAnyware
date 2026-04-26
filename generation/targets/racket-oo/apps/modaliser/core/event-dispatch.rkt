#lang racket/base
;; event-dispatch.rkt — Keyboard event dispatch
;;
;; Bridges the CGEvent tap (ffi/cgevent.rkt) to the modal state machine.
;; Manages two handler layers:
;;   1. Catch-all handler — active during modal mode, receives all keys
;;   2. Hotkey handlers — always active, for specific keycodes (leader keys)
;;
;; Dispatch priority: catch-all > hotkey > pass-through

(require racket/string
         "keymap.rkt"
         "state-machine.rkt"
         "../ffi/cgevent.rkt"
         "../lib/dsl.rkt")

(provide start-keyboard-dispatch!
         stop-keyboard-dispatch!
         register-hotkey!
         unregister-hotkey!
         focused-app-bundle-id
         modal-key-handler
         make-leader-handler)

;; ─── Handler Registry ───────────────────────────────────────────

;; Catch-all handler for modal mode.
;; (keycode modifiers) -> bool (true = suppress)
(define catch-all-handler #f)

;; Hotkey handlers: keycode -> zero-argument procedure
(define hotkey-handlers (make-hasheqv))

;; ─── Catch-all Management ───────────────────────────────────────

(define (register-all-keys! handler)
  (set! catch-all-handler handler))

(define (unregister-all-keys!)
  (set! catch-all-handler #f))

;; ─── Hotkey Management ──────────────────────────────────────────

(define (register-hotkey! keycode handler)
  (hash-set! hotkey-handlers keycode handler))

(define (unregister-hotkey! keycode)
  (hash-remove! hotkey-handlers keycode))

;; ─── Focused App (stub — Phase 6 implements via NSWorkspace) ────

(define (focused-app-bundle-id)
  #f)

;; ─── Modal Key Handler ─────────────────────────────────────────
;; The catch-all handler active during modal mode.
;; Receives (keycode modifiers), returns #t to suppress, #f to pass.

(define (modal-key-handler keycode modifiers)
  (cond
    ;; Leader key toggle — exit modal
    [(and modal-leader-keycode (= keycode modal-leader-keycode))
     (modal-exit)
     #t]
    ;; Escape — exit modal
    [(= keycode KEY-ESCAPE)
     (modal-exit)
     #t]
    ;; Delete — step back
    [(= keycode KEY-DELETE)
     (modal-step-back)
     #t]
    ;; Cmd+anything — pass through to system
    [(has-cmd? modifiers)
     #f]
    ;; Regular key — map to character and handle
    [else
     (define char (keycode->char keycode))
     (if char
         (let ([effective (if (has-shift? modifiers)
                              (string-upcase char)
                              char)])
           (modal-handle-key effective)
           #t)
         (begin (modal-exit) #t))]))

;; ─── Leader Handler Factory ────────────────────────────────────
;; Creates a handler for a leader hotkey.
;; mode: 'global, 'local, or #f (global with app fallback)

(define (make-leader-handler leader-kc mode)
  (lambda ()
    (if modal-active?
        (modal-exit)
        (let* ([bundle-id (focused-app-bundle-id)]
               [tree (cond
                       [(eq? mode 'global) (lookup-tree "global")]
                       [(eq? mode 'local)  (and bundle-id (lookup-tree bundle-id))]
                       [else (or (and bundle-id (lookup-tree bundle-id))
                                 (lookup-tree "global"))])])
          (when tree
            (modal-enter tree leader-kc))))))

;; ─── Master Dispatch ────────────────────────────────────────────
;; Called from the CGEvent tap for every key event.
;; Returns 'suppress or 'pass-through.

(define (master-key-handler keycode modifiers key-down?)
  (if (not key-down?)
      ;; Key-up: suppress during modal (non-Cmd), pass through otherwise
      (if (and catch-all-handler (not (has-cmd? modifiers)))
          'suppress
          'pass-through)
      ;; Key-down: run dispatch logic
      (cond
        ;; Catch-all handler (modal mode)
        [catch-all-handler
         (define should-suppress (catch-all-handler keycode modifiers))
         (if should-suppress 'suppress 'pass-through)]
        ;; Hotkey handler
        [(hash-ref hotkey-handlers keycode #f)
         => (lambda (handler) (handler) 'suppress)]
        ;; No handler — pass through
        [else 'pass-through])))

;; ─── Initialization ─────────────────────────────────────────────

;; Wire up hooks in state-machine.rkt
(set-modal-key-handler! modal-key-handler)
(set-keyboard-hooks! register-all-keys! unregister-all-keys!)

;; Wire up hooks in lib/dsl.rkt
(set-leader-hooks! register-hotkey! make-leader-handler)

;; ─── Public API ─────────────────────────────────────────────────

;; Start the keyboard dispatch system.
;; Connects the master handler to the CGEvent tap.
(define (start-keyboard-dispatch!)
  (start-keyboard-capture! master-key-handler))

;; Stop the keyboard dispatch system.
(define (stop-keyboard-dispatch!)
  (stop-keyboard-capture!))
