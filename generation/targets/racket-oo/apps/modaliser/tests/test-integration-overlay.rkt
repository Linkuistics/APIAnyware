#lang racket/base
;; tests/test-integration-overlay.rkt — Integration test for overlay lifecycle
;;
;; Tests the full modal → overlay flow:
;;   modal enter → overlay shows (after delay) → navigate group →
;;   overlay updates → step back → overlay updates → escape → overlay hides
;;
;; Uses realistic overlay hooks that track open/closed state, verifying
;; the show-vs-update decision and the delay/generation mechanism.
;; Also tests rendering output through the real render-overlay-html.
;;
;; Run:  racket tests/test-integration-overlay.rkt

(require rackunit
         racket/string
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         "../core/event-dispatch.rkt"
         "../ffi/main-thread.rkt"
         "../lib/dsl.rkt"
         "../ui/dom.rkt"
         "../ui/overlay.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

;; ─── Overlay Hook Tracker ───────────────────────────────────────
;; Realistic hooks that track open/closed state (unlike the Phase 3
;; integration test which always returns #f for overlay-open?).
;; This is critical: when overlay IS open, group navigation must
;; call update (incremental JSON push), not show (full HTML reload).

(define overlay-call-log '())
(define overlay-tracking-open? #f)

(define (reset-overlay-tracker!)
  (set! overlay-call-log '())
  (set! overlay-tracking-open? #f))

(define (tracked-show root-node path)
  (set! overlay-tracking-open? #t)
  (set! overlay-call-log
    (append overlay-call-log
      (list (list 'show (node-label root-node) path)))))

(define (tracked-update root-node path)
  (set! overlay-call-log
    (append overlay-call-log
      (list (list 'update (node-label root-node) path)))))

(define (tracked-hide)
  (set! overlay-tracking-open? #f)
  (set! overlay-call-log
    (append overlay-call-log (list (list 'hide)))))

(define (tracked-open?)
  overlay-tracking-open?)

(define (tracked-open-chooser node)
  (set! overlay-call-log
    (append overlay-call-log
      (list (list 'chooser (node-label node))))))

(define (install-tracking-hooks!)
  (set-overlay-hooks!
   #:show tracked-show
   #:update tracked-update
   #:hide tracked-hide
   #:open-chooser tracked-open-chooser
   #:open? tracked-open?))

;; ─── Wire up hooks ──────────────────────────────────────────────

(install-tracking-hooks!)

;; ─── Build test tree via DSL ────────────────────────────────────

(clear-trees!)
(set-overlay-delay! 0)  ;; Zero delay for deterministic testing

(define command-log '())
(define (log-cmd! name) (set! command-log (append command-log (list name))))

(define-tree 'global
  (key "a" "Terminal" (lambda () (log-cmd! 'terminal)))
  (group "w" "Windows"
    (key "c" "Center" (lambda () (log-cmd! 'center)))
    (key "f" "Fullscreen" (lambda () (log-cmd! 'fullscreen)))
    (group "m" "Move"
      (key "h" "Left" (lambda () (log-cmd! 'move-left)))
      (key "l" "Right" (lambda () (log-cmd! 'move-right)))))
  (group "b" "Browser"
    (key "s" "Safari" (lambda () (log-cmd! 'safari)))))

(displayln "Test tree: Global → w(Windows → c,f,m(Move → h,l)), b(Browser → s), a(Terminal)")

;; ─── Test 1: Modal enter shows overlay at root ──────────────────

(test-case "modal enter shows overlay at root"
  (reset-overlay-tracker!)
  (modal-enter (lookup-tree "global") KEY-F17)
  (check-true modal-active?)
  ;; With delay=0, show is called immediately
  (check-equal? (length overlay-call-log) 1)
  (check-equal? (car (car overlay-call-log)) 'show)
  (check-equal? (caddr (car overlay-call-log)) '())  ;; empty path = root
  (check-true (tracked-open?))
  (modal-exit))

;; ─── Test 2: Group navigation uses update when overlay is open ──

(test-case "group navigation uses update (not show) when overlay is open"
  (reset-overlay-tracker!)
  (modal-enter (lookup-tree "global") KEY-F17)
  (check-true (tracked-open?) "overlay should be open after enter")

  ;; Navigate into Windows group
  (void (modal-key-handler (char->keycode "w") 0))
  (check-true modal-active?)
  (check-equal? modal-current-path '("w"))

  ;; Should have: show(root), update(w)
  (check-equal? (length overlay-call-log) 2)
  (define second-call (list-ref overlay-call-log 1))
  (check-equal? (car second-call) 'update
                "should call update, not show, when overlay is already open")
  (check-equal? (caddr second-call) '("w"))
  (modal-exit))

;; ─── Test 3: Deep navigation chain ─────────────────────────────

(test-case "deep navigation: enter → group → subgroup → command"
  (reset-overlay-tracker!)
  (set! command-log '())
  (modal-enter (lookup-tree "global") KEY-F17)

  ;; Navigate: w → m → h (Left)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "m") 0))
  (check-equal? modal-current-path '("w" "m"))

  ;; Verify overlay calls: show(root), update(w), update(w,m)
  (check-equal? (length overlay-call-log) 3)
  (check-equal? (car (list-ref overlay-call-log 0)) 'show)
  (check-equal? (caddr (list-ref overlay-call-log 0)) '())
  (check-equal? (car (list-ref overlay-call-log 1)) 'update)
  (check-equal? (caddr (list-ref overlay-call-log 1)) '("w"))
  (check-equal? (car (list-ref overlay-call-log 2)) 'update)
  (check-equal? (caddr (list-ref overlay-call-log 2)) '("w" "m"))

  ;; Execute command — exits modal and hides overlay
  (void (modal-key-handler (char->keycode "h") 0))
  (check-false modal-active?)
  (check-equal? command-log '(move-left))

  ;; Overlay should have been hidden
  (define hide-calls (filter (lambda (c) (eq? (car c) 'hide)) overlay-call-log))
  (check-equal? (length hide-calls) 1)
  (check-false (tracked-open?)))

;; ─── Test 4: Step back updates overlay ──────────────────────────

(test-case "step back updates overlay with parent path"
  (reset-overlay-tracker!)
  (modal-enter (lookup-tree "global") KEY-F17)

  ;; Navigate into w → m
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "m") 0))
  (check-equal? modal-current-path '("w" "m"))

  ;; Step back (delete key)
  (void (modal-key-handler KEY-DELETE 0))
  (check-equal? modal-current-path '("w"))

  ;; The step-back should have called update with path ("w")
  (define last-call (car (reverse overlay-call-log)))
  (check-equal? (car last-call) 'update)
  (check-equal? (caddr last-call) '("w"))

  ;; Step back again to root
  (void (modal-key-handler KEY-DELETE 0))
  (check-equal? modal-current-path '())
  (define last-call-2 (car (reverse overlay-call-log)))
  (check-equal? (car last-call-2) 'update)
  (check-equal? (caddr last-call-2) '())

  ;; Step back from root → exits modal, hides overlay
  (void (modal-key-handler KEY-DELETE 0))
  (check-false modal-active?)
  (check-false (tracked-open?)))

;; ─── Test 5: Escape hides overlay from nested depth ─────────────

(test-case "escape hides overlay from nested group"
  (reset-overlay-tracker!)
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (void (modal-key-handler (char->keycode "m") 0))
  (check-true (tracked-open?))

  ;; Escape from deep nesting
  (void (modal-key-handler KEY-ESCAPE 0))
  (check-false modal-active?)
  (check-false (tracked-open?))

  ;; Verify exactly one hide call
  (define hide-calls (filter (lambda (c) (eq? (car c) 'hide)) overlay-call-log))
  (check-equal? (length hide-calls) 1))

;; ─── Test 6: Overlay not open → group re-shows (not updates) ───

(test-case "group navigation shows overlay when it's not yet open"
  (reset-overlay-tracker!)
  ;; Override open? to always return false (simulates delay not elapsed)
  (set-overlay-hooks!
   #:show tracked-show
   #:update tracked-update
   #:hide tracked-hide
   #:open-chooser tracked-open-chooser
   #:open? (lambda () #f))

  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))

  ;; Since open? always returns #f, group navigation should call show
  ;; (via modal-show-overlay-delayed), not update
  (define show-calls (filter (lambda (c) (eq? (car c) 'show)) overlay-call-log))
  (check-equal? (length show-calls) 2
                "should have two show calls when overlay reports not open")

  (modal-exit)
  ;; Restore normal tracking hooks
  (install-tracking-hooks!))

;; ─── Test 7: render-overlay-html for DSL-built tree ─────────────

(test-case "render-overlay-html produces valid HTML for DSL-built tree"
  (define tree (lookup-tree "global"))

  ;; Root level
  (define html-root (render-overlay-html tree '()))
  (check-true (string-contains? html-root "<!DOCTYPE html>"))
  (check-true (string-contains? html-root "Global"))
  (check-true (string-contains? html-root "Windows"))
  (check-true (string-contains? html-root "Browser"))
  (check-true (string-contains? html-root "Terminal"))

  ;; Navigate into Windows
  (define html-w (render-overlay-html tree '("w")))
  (check-true (string-contains? html-w "Center"))
  (check-true (string-contains? html-w "Fullscreen"))
  (check-true (string-contains? html-w "Move"))
  ;; Should NOT show root-level entries
  (check-false (string-contains? html-w "Browser"))
  (check-false (string-contains? html-w "Terminal"))

  ;; Navigate into Windows → Move
  (define html-wm (render-overlay-html tree '("w" "m")))
  (check-true (string-contains? html-wm "Left"))
  (check-true (string-contains? html-wm "Right"))
  ;; Breadcrumb should include the full path
  (check-true (string-contains? html-wm "Global"))
  (check-true (string-contains? html-wm "w"))
  (check-true (string-contains? html-wm "m")))

;; ─── Test 8 + 9: Delayed-show scheduling and stale-callback rejection ───
;; The production delay path uses GCD `dispatch_after_f`, which only fires
;; under a running NSApplication run loop. Headless unit tests have no run
;; loop, so we install a recording handler via `set-after-delay-handler!`
;; that captures every scheduled (seconds . thunk) pair for manual
;; invocation. `modal-enter` schedules TWO timers per call — the delayed
;; show (uses `modal-overlay-delay`, sub-second in tests) and the safety
;; watchdog (`modal-safety-timeout = 5`) — so the recorder must keep both
;; and the test picks the one it wants by inspecting the delay.

(define captured-delays '())

(define (recording-after-delay seconds thunk)
  (set! captured-delays (cons (cons seconds thunk) captured-delays)))

(define (find-delayed-show-thunk)
  ;; Sub-second schedules are the overlay show; the 5 s watchdog is filtered out.
  (cond
    [(findf (lambda (pair) (< (car pair) 1.0)) captured-delays) => cdr]
    [else #f]))

(set-after-delay-handler! recording-after-delay)

(test-case "modal-enter schedules a delayed show that fires only when invoked"
  (reset-overlay-tracker!)
  (set! captured-delays '())
  (set-overlay-delay! 0.1)

  (modal-enter (lookup-tree "global") KEY-F17)
  (check-true modal-active?)

  (check-equal? (length overlay-call-log) 0
                "overlay should not show before the delayed callback fires")
  (define show-thunk (find-delayed-show-thunk))
  (check-not-false show-thunk
                   "modal-enter should schedule a sub-second delayed-show callback")

  (show-thunk)

  (check-equal? (length overlay-call-log) 1
                "overlay show should fire when the delayed callback runs")
  (check-equal? (car (car overlay-call-log)) 'show)

  (modal-exit)
  (set-overlay-delay! 0))

(test-case "stale delayed-show callback rejected after modal-exit"
  (reset-overlay-tracker!)
  (set! captured-delays '())
  (set-overlay-delay! 0.1)

  (modal-enter (lookup-tree "global") KEY-F17)
  (define show-thunk (find-delayed-show-thunk))
  (check-not-false show-thunk)

  (modal-exit)
  ;; Generation counter bumped — firing the stale thunk now must no-op.
  (show-thunk)

  (define show-calls (filter (lambda (c) (eq? (car c) 'show)) overlay-call-log))
  (check-equal? (length show-calls) 0
                "stale delayed-show callback must be ignored after exit")

  (set-overlay-delay! 0))

;; Restore the production handler so any subsequent test in this file
;; (or a future addition) sees the real GCD path.
(set-after-delay-handler! call-on-main-thread-after)

;; ─── Test 10: Leader toggle re-entering shows fresh overlay ─────

(test-case "re-entering modal after exit shows fresh overlay"
  (reset-overlay-tracker!)

  ;; First modal session
  (modal-enter (lookup-tree "global") KEY-F17)
  (void (modal-key-handler (char->keycode "w") 0))
  (modal-exit)

  ;; Second modal session — should start at root
  (modal-enter (lookup-tree "global") KEY-F17)
  (check-equal? modal-current-path '() "should start at root on re-enter")

  ;; Last show call should be at root path
  (define show-calls (filter (lambda (c) (eq? (car c) 'show)) overlay-call-log))
  (define last-show (car (reverse show-calls)))
  (check-equal? (caddr last-show) '() "re-enter should show root overlay")

  (modal-exit))

(displayln "test-integration-overlay: all tests passed")
