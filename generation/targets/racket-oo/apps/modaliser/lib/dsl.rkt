#lang racket/base
;; dsl.rkt — User-facing DSL for command tree construction
;;
;; Provides functions that produce alist nodes for the command tree.
;; These are designed to be used in ~/.config/modaliser/config.scm
;; and are intentionally similar to the original LispKit DSL.
;;
;; Example usage:
;;   (define-tree 'global
;;     (key "a" "Terminal" (lambda () (launch-app "Terminal")))
;;     (group "w" "Windows"
;;       (key "h" "Left Half" left-half!)
;;       (key "l" "Right Half" right-half!))
;;     (selector "s" "Search" 'items search-items 'on-select handle-select))

(require "../core/state-machine.rkt"
         "../core/keymap.rkt")

(provide key
         group
         selector
         action
         define-tree
         set-leader!
         set-overlay-delay!
         set-theme!
         ;; Keycode aliases for config.scm compatibility.
         ;; Config uses bare F17, F18, etc. instead of KEY-F17.
         (rename-out [KEY-F1  F1]  [KEY-F2  F2]  [KEY-F3  F3]  [KEY-F4  F4]
                     [KEY-F5  F5]  [KEY-F6  F6]  [KEY-F7  F7]  [KEY-F8  F8]
                     [KEY-F9  F9]  [KEY-F10 F10] [KEY-F11 F11] [KEY-F12 F12]
                     [KEY-F17 F17] [KEY-F18 F18] [KEY-F19 F19] [KEY-F20 F20]
                     [KEY-ESCAPE ESCAPE] [KEY-RETURN RETURN]
                     [KEY-TAB TAB] [KEY-SPACE SPACE] [KEY-DELETE DELETE]))

;; (key k label action-fn) → command node
;; k: string key character (e.g., "a")
;; label: string description shown in overlay
;; action-fn: zero-argument procedure called when selected
(define (key k label action-fn)
  (list (cons 'kind 'command)
        (cons 'key k)
        (cons 'label label)
        (cons 'action action-fn)))

;; (group k label child ...) → group node
;; k: string key character
;; label: string description
;; children: any number of key/group/selector nodes
(define (group k label . children)
  (list (cons 'kind 'group)
        (cons 'key k)
        (cons 'label label)
        (cons 'children children)))

;; (selector k label prop-key prop-val ...) → selector node
;; k: string key character
;; label: string description
;; Additional properties as alternating key/value pairs:
;;   'items list — static items for the chooser
;;   'on-select handler — callback when an item is selected
;;   'dynamic handler — callback for dynamic result generation
(define (selector k label . props)
  (let loop ([rest props]
             [entries (list (cons 'kind 'selector)
                            (cons 'key k)
                            (cons 'label label))])
    (if (or (null? rest) (null? (cdr rest)))
        (reverse entries)
        (loop (cddr rest)
              (cons (cons (car rest) (cadr rest)) entries)))))

;; (action name prop-key prop-val ...) → action descriptor
;; Used within selectors for action panel items.
(define (action name . props)
  (let loop ([rest props]
             [entries (list (cons 'name name))])
    (if (or (null? rest) (null? (cdr rest)))
        (reverse entries)
        (loop (cddr rest)
              (cons (cons (car rest) (cadr rest)) entries)))))

;; (define-tree scope child ...) → registers the tree
;; scope: symbol or string (e.g., 'global, "com.apple.Safari")
(define (define-tree scope . children)
  (apply register-tree! scope children))

;; (set-leader! keycode) or (set-leader! mode keycode)
;; Registers a hotkey that enters modal mode.
;; mode: 'global (always global tree), 'local (app-specific tree only)
;; Single-arg form: global with app-specific fallback
;;
;; Note: this requires event-dispatch.rkt to be initialized.
;; The actual registration happens via the register-hotkey hook.
(define register-hotkey-fn (lambda (kc handler) (void)))
(define make-leader-handler-fn (lambda (kc mode) (lambda () (void))))

(provide set-leader-hooks!)

(define (set-leader-hooks! register-fn make-handler-fn)
  (set! register-hotkey-fn register-fn)
  (set! make-leader-handler-fn make-handler-fn))

(define (set-leader! first . rest)
  (if (null? rest)
      ;; Single arg: keycode only, default behavior
      (register-hotkey-fn first (make-leader-handler-fn first #f))
      ;; Two args: mode + keycode
      (let ([mode first]
            [keycode (car rest)])
        (register-hotkey-fn keycode (make-leader-handler-fn keycode mode)))))

;; (set-theme! ...) → no-op stub for backward compatibility
;; Theming is handled via CSS in Phase 4.
(define (set-theme! . args) (void))
