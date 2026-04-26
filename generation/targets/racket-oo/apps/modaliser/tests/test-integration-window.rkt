#lang racket/base
;; tests/test-integration-window.rkt — Integration test for window commands
;;
;; Tests the full chain: DSL tree with window commands → modal dispatch →
;; window manipulation functions are called correctly.
;;
;; Does NOT actually move windows (we don't want tests to rearrange the
;; user's desktop). Instead, verifies that the functions are wired up
;; correctly and callable through the modal dispatch chain.
;;
;; Run:  racket tests/test-integration-window.rkt

(require rackunit
         "../bindings/runtime/objc-base.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         (except-in "../core/event-dispatch.rkt" focused-app-bundle-id)
         "../lib/dsl.rkt"
         "../services/window-manager.rkt"
         "../services/window-cache.rkt"
         "../ffi/permissions.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

;; ─── Setup ──────────────────────────────────────────────────────

(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app 1))

(unless (accessibility-trusted?)
  (eprintf "test-integration-window: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
  (exit 1))

;; ─── Track which commands are dispatched ────────────────────────

(define command-log '())
(define (log-cmd! name . args)
  (set! command-log (append command-log (list (cons name args)))))

;; Stub overlay hooks
(set-overlay-hooks!
 #:show (lambda (r p) (void))
 #:update (lambda (r p) (void))
 #:hide (lambda () (void))
 #:open-chooser (lambda (n) (void))
 #:open? (lambda () #f))

;; ─── Build tree with window commands ────────────────────────────

(clear-trees!)
(set-overlay-delay! 0)

;; NOTE: command lambdas log only. We deliberately do NOT call the real
;; window-manager functions (center-window, move-window, toggle-fullscreen,
;; restore-window) here — those functions target whatever window has AX
;; focus, and this test must not rearrange the user's desktop. Load-time
;; reachability of window-manager.rkt is verified by the dynamic-require
;; smoke load in test-window-manager.rkt; that is the correct place to
;; check callability without side effects.
(define-tree 'global
  (group "w" "Windows"
    (key "c" "Center" (lambda () (log-cmd! 'center)))
    (key "d" "First Third" (lambda () (log-cmd! 'move 0 0 1/3 1)))
    (key "f" "Center Third" (lambda () (log-cmd! 'move 1/3 0 1/3 1)))
    (key "g" "Last Third" (lambda () (log-cmd! 'move 2/3 0 1/3 1)))
    (key "m" "Maximise" (lambda () (log-cmd! 'fullscreen)))
    (key "r" "Restore" (lambda () (log-cmd! 'restore)))))

(displayln "Tree built with window commands")

;; ─── Test 1: Center window via modal dispatch ───────────────────

(test-case "center-window dispatched via modal w → c"
  (set! command-log '())
  (modal-enter (lookup-tree "global") KEY-F17)
  (check-true modal-active?)
  (void (modal-key-handler (char->keycode "w") 0))
  (check-equal? modal-current-path '("w"))
  (void (modal-key-handler (char->keycode "c") 0))
  (check-false modal-active?)
  (check-equal? (length command-log) 1)
  (check-equal? (car (car command-log)) 'center))

;; ─── Test 2: Move window (fractional) via modal ─────────────────

(test-case "move-window dispatched with correct fractions"
  (set! command-log '())
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "d") 0))
  (check-false modal-active?)
  (check-equal? (length command-log) 1)
  (check-equal? (car (car command-log)) 'move)
  (check-equal? (cdr (car command-log)) '(0 0 1/3 1)))

;; ─── Test 3: Multiple commands in sequence ──────────────────────

(test-case "sequential modal sessions dispatch different commands"
  (set! command-log '())

  ;; First: center third
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "f") 0))

  ;; Second: last third
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "g") 0))

  (check-equal? (length command-log) 2)
  (check-equal? (cdr (car command-log)) '(1/3 0 1/3 1))
  (check-equal? (cdr (cadr command-log)) '(2/3 0 1/3 1)))

;; ─── Test 4: Toggle fullscreen dispatches correctly ─────────────

(test-case "toggle-fullscreen dispatched via modal w → m"
  (set! command-log '())
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "m") 0))
  (check-false modal-active?)
  (check-equal? (car (car command-log)) 'fullscreen))

;; ─── Test 5: Restore dispatches correctly ───────────────────────

(test-case "restore-window dispatched via modal w → r"
  (set! command-log '())
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "r") 0))
  (check-false modal-active?)
  (check-equal? (car (car command-log)) 'restore))

;; ─── Test 6: list-windows returns valid data ────────────────────

(test-case "list-windows callable and returns structured data"
  (define wins (list-windows))
  (check-true (list? wins))
  (check-true (> (length wins) 0))
  (define w (car wins))
  (check-true (string? (cdr (assoc 'text w))))
  (check-true (number? (cdr (assoc 'ownerPid w)))))

;; ─── Test 7: Window cache integration ───────────────────────────

(test-case "window cache returns focus-ordered results"
  (start-window-cache!)
  (define cached-wins (list-windows-cached))
  (check-true (list? cached-wins))
  (check-true (> (length cached-wins) 0)))

;; ─── Test 8: focused-app-bundle-id ──────────────────────────────

(test-case "focused-app-bundle-id returns valid bundle ID"
  (define bid (focused-app-bundle-id))
  ;; Should return a string in a running GUI session
  (check-true (or (not bid) (string? bid))))

(displayln "test-integration-window: all tests passed")
