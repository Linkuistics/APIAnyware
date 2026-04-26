#lang racket/base
;; test-integration-services.rkt — Integration test for Phase 6 services
;;
;; Verifies that DSL tree commands can trigger Phase 6 services:
;; - run-shell (shell command execution)
;; - send-keystroke (synthetic keystroke emission)
;; - get-clipboard / set-clipboard! (clipboard access)
;; - scan-installed-apps (app discovery)
;; - http-get-sync (HTTP requests)
;;
;; This test builds a command tree with actions that use these services,
;; then dispatches through the modal state machine to verify end-to-end wiring.
;;
;; Note: send-keystroke is tested structurally (via parse-modifier-symbols
;; and char->keycode-or-named) rather than actually posting events, as
;; posting would type into the active window during testing.

(require rackunit
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         "../core/event-dispatch.rkt"
         "../lib/dsl.rkt"
         "../services/shell.rkt"
         "../services/pasteboard.rkt"
         "../services/app-scanner.rkt"
         "../services/http.rkt"
         "../ffi/cgevent-emitter.rkt"
         "../ffi/permissions.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

;; ─── Setup NSApplication ────────────────────────────────────────

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

;; Start keyboard dispatch
(unless (accessibility-trusted?)
  (eprintf "test-integration-services: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
  (exit 1))

(unless (start-keyboard-dispatch!)
  (eprintf "test-integration-services: start-keyboard-dispatch! returned #f — CGEvent tap install failed\n")
  (exit 1))

;; ─── Build a test tree that uses Phase 6 services ───────────────

(clear-trees!)
(set-overlay-delay! 0)

;; Result capture
(define results (make-hash))

;; Stub overlay hooks
(set-overlay-hooks!
 #:show (lambda (r p) (void))
 #:update (lambda (r p) (void))
 #:hide (lambda () (void))
 #:open-chooser (lambda (n) (void))
 #:open? (lambda () #f))

;; Build tree with service-calling actions
(define-tree 'global
  ;; Shell command
  (key "s" "Shell Echo"
    (lambda ()
      (hash-set! results 'shell (run-shell "echo -n hello-from-shell"))))
  ;; Clipboard round-trip
  (key "c" "Clipboard Test"
    (lambda ()
      (define saved (get-clipboard))
      (set-clipboard! "modaliser-integration-test")
      (hash-set! results 'clipboard-write (get-clipboard))
      (set-clipboard! saved)))  ;; restore
  ;; App scanner
  (key "a" "App Count"
    (lambda ()
      (define apps (scan-installed-apps))
      (hash-set! results 'app-count (length apps))))
  ;; Keystroke lookup (structural test — don't actually post events)
  (key "k" "Keystroke Lookup"
    (lambda ()
      (hash-set! results 'keycode-t (char->keycode-or-named "t"))
      (hash-set! results 'keycode-return (char->keycode-or-named "return"))
      (hash-set! results 'mods (parse-modifier-symbols '(cmd shift)))))
  ;; HTTP sync
  (key "h" "HTTP Test"
    (lambda ()
      (define body (http-get-sync "http://captive.apple.com"))
      (hash-set! results 'http-result (and body (> (string-length body) 0))))))

;; ─── Test 1: Shell command via modal dispatch ───────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "s") 0))
(check-false modal-active?)
(check-equal? (hash-ref results 'shell #f) "hello-from-shell"
              "shell command should execute and capture output")
(displayln "  [1/5] shell: ok")

;; ─── Test 2: Clipboard via modal dispatch ───────────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "c") 0))
(check-false modal-active?)
(check-equal? (hash-ref results 'clipboard-write #f) "modaliser-integration-test"
              "clipboard write/read should round-trip")
(displayln "  [2/5] clipboard: ok")

;; ─── Test 3: App scanner via modal dispatch ─────────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "a") 0))
(check-false modal-active?)
(check-true (> (hash-ref results 'app-count 0) 100)
            "should find >100 apps on a real macOS system")
(displayln (format "  [3/5] app-scanner: ok (~a apps)" (hash-ref results 'app-count 0)))

;; ─── Test 4: Keystroke lookup via modal dispatch ────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "k") 0))
(check-false modal-active?)
(check-equal? (hash-ref results 'keycode-t #f) 17
              "keycode for 't' should be 17")
(check-equal? (hash-ref results 'keycode-return #f) KEY-RETURN
              "keycode for 'return' should be KEY-RETURN")
(check-equal? (hash-ref results 'mods #f) (bitwise-ior MOD-CMD MOD-SHIFT)
              "modifier symbols should parse correctly")
(displayln "  [4/5] keystroke-lookup: ok")

;; ─── Test 5: HTTP sync via modal dispatch ───────────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "h") 0))
(check-false modal-active?)
(check-true (hash-ref results 'http-result #f)
            "HTTP GET should return a non-empty response")
(displayln "  [5/5] http: ok")

;; ─── Cleanup ────────────────────────────────────────────────────

(stop-keyboard-dispatch!)
(terminate-all-processes!)
(displayln "test-integration-services: all checks passed")
