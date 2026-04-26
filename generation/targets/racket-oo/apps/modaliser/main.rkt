#lang racket/base
;; main.rkt — Modaliser application entry point
;;
;; Creates the NSApplication, sets activation policy to accessory (no dock icon),
;; installs the app delegate, and enters the Cocoa run loop.
;;
;; Bootstrap sequence (in applicationDidFinishLaunching:):
;;   1. Set up status bar (menu icon + Settings/Relaunch/Quit)
;;   2. Check accessibility permissions (required for CGEvent tap)
;;   3. Wire overlay + chooser hooks into the state machine
;;   4. Start keyboard dispatch (creates CGEvent tap → event-dispatch → state machine)
;;   5. Load user config (registers trees, leader keys, theme)
;;
;; Run with:
;;   racket main.rkt

(require racket/file
         racket/os
         racket/string
         "bindings/runtime/objc-base.rkt"
         "bindings/runtime/coerce.rkt"
         "bindings/runtime/delegate.rkt"
         "bindings/generated/oo/appkit/nsapplication.rkt"
         "services/lifecycle.rkt"
         "ffi/permissions.rkt"
         "core/state-machine.rkt"
         "core/event-dispatch.rkt"
         "ui/overlay.rkt"
         "ui/chooser.rkt"
         "lib/config-loader.rkt"
         "lib/events.rkt"
         "lib/mru-store.rkt")

;; NSApplicationActivationPolicy
(define NSApplicationActivationPolicyAccessory 1)

;; Ensure output is visible immediately (not block-buffered when piped)
(file-stream-buffer-mode (current-output-port) 'line)

;; --- Single-instance guard ---
;; Prevent multiple copies from running simultaneously.
;; Uses a PID lock file at ~/.config/modaliser/.lock

(define lock-file
  (build-path (find-system-path 'home-dir) ".config" "modaliser" ".lock"))

;; Liveness check via /bin/kill -0. No libc FFI needed — startup-only path,
;; subprocess overhead is irrelevant here. Signal 0 is POSIX-defined to test
;; whether the PID is valid without actually sending any signal.
(define (process-alive? pid)
  (define-values (proc out _in err)
    (subprocess #f #f #f "/bin/kill" "-0" (number->string pid)))
  (close-input-port out)
  (close-input-port err)
  (subprocess-wait proc)
  (zero? (subprocess-status proc)))

(define (another-instance-running?)
  (and (file-exists? lock-file)
       (let ([pid (string->number (string-trim (file->string lock-file)))])
         (and pid (process-alive? (inexact->exact (truncate pid)))))))

(define (write-lock-file!)
  (call-with-output-file lock-file
    (lambda (out) (fprintf out "~a\n" (getpid)))
    #:exists 'replace))

(define (remove-lock-file!)
  (when (file-exists? lock-file) (delete-file lock-file)))

;; --- Test-hook gate ---
;; Integration tests (tests/test-lifecycle-events.rkt) set
;; MODALISER_TEST_BLOCK to run a headless path that skips NSApp startup
;; and the shared lock file, exercises the shutdown handlers, and exits.
;; The env var is unset in production, so `test-block-mode` is #f there.
(define test-block-mode (getenv "MODALISER_TEST_BLOCK"))

(unless test-block-mode
  (when (another-instance-running?)
    (displayln "modaliser: another instance is already running — exiting")
    (exit 0))
  (write-lock-file!))

;; Init structured event log after the single-instance guard so the
;; truncate-on-startup contract only fires for the authoritative writer.
(events-init!)
(log-event 'lifecycle 'startup)

;; --- Shutdown wiring ---
;; Single uncaught-exception handler covers both paths required by the
;; logging contract:
;;   - SIGINT/SIGHUP/SIGTERM → Racket delivers `exn:break` (via its own
;;     signal-to-break bridge) → reason=signal.
;;   - any other unhandled exception → reason=error.
;; The C-level signal(2) approach doesn't compose with Racket CS's own
;; SIGINT handler, so we ride Racket's break mechanism instead. During
;; `nsapplication-run` (blocked in a C call) breaks are pending until
;; the loop yields — `applicationWillTerminate:` already covers the
;; Cmd-Q / menu-quit shutdown in that state.
(define (shutdown-cleanup!)
  (unless test-block-mode
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (remove-lock-file!))))

(uncaught-exception-handler
 (lambda (exn)
   (with-handlers ([exn:fail? (lambda (_) (void))])
     (cond
       [(exn:break? exn)
        (log-event 'lifecycle 'shutdown 'reason 'signal)]
       [else
        (define msg (if (exn? exn) (exn-message exn) (format "~v" exn)))
        (log-event 'lifecycle 'shutdown 'reason 'error 'message msg)])
     (close-events!))
   (shutdown-cleanup!)
   (exit (if (exn:break? exn) 130 1))))

;; Test-hook dispatch: block on a never-signalled semaphore for the
;; signal test, or raise for the error test. Both paths never return.
(when test-block-mode
  (cond
    [(equal? test-block-mode "signal")
     (semaphore-wait (make-semaphore 0))]
    [(equal? test-block-mode "raise")
     (error 'modaliser "synthetic test failure")]
    [else
     (error 'modaliser "unknown MODALISER_TEST_BLOCK mode: ~a" test-block-mode)]))

;; --- Application setup ---

(define app (nsapplication-shared-application))

;; Accessory mode: no dock icon, no main menu bar
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

;; --- App delegate ---
;; Must keep a reference at module scope — Cocoa holds delegates weakly.

;; Delegate bodies must be wrapped in with-handlers — unhandled exceptions in
;; ObjC delegate callbacks crash the app with no Racket stack trace.
(define app-delegate
  (make-delegate
   "applicationDidFinishLaunching:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationDidFinishLaunching delegate error: ~a\n"
                                 (exn-message e)))])
       (displayln "Modaliser starting")

       ;; 1. Status bar
       (setup-status-bar!)

       ;; 2. Accessibility check — always prompt to ensure the app bundle
       ;; (not just the binary) is authorized. The prompt only appears if
       ;; the app isn't already in the Accessibility list.
       (define trusted? (request-accessibility!))
       (unless trusted?
         (displayln "modaliser: accessibility not granted — grant permission in System Settings and relaunch"))

       (when trusted?
         ;; 3. Wire overlay + chooser hooks into the state machine
         (set-overlay-hooks!
          #:show show-overlay
          #:update update-overlay
          #:hide hide-overlay
          #:open-chooser open-chooser
          #:open? overlay-open?)

         ;; 4. Start keyboard dispatch (CGEvent tap)
         (cond
           [(start-keyboard-dispatch!)
            (displayln "modaliser: keyboard capture active")]
           [else
            (displayln "modaliser: keyboard capture FAILED")])

         ;; 5. Load MRU history + user config
         (mru-load!)
         (load-config!)

         (displayln "Modaliser launched — fully operational"))))

   "applicationWillTerminate:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationWillTerminate delegate error: ~a\n"
                                 (exn-message e)))])
       (displayln "Modaliser shutting down")
       (log-event 'lifecycle 'shutdown 'reason 'menu)
       (stop-keyboard-dispatch!)
       (remove-lock-file!)
       (close-events!)))))

(void (nsapplication-set-delegate! app app-delegate))

;; --- Enter run loop (does not return) ---

(displayln "Modaliser: entering run loop")
(nsapplication-run app)
