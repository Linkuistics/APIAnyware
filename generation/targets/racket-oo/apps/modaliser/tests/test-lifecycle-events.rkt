#lang racket/base
;; test-lifecycle-events.rkt — Verifies main.rkt emits shutdown events
;; for signal and uncaught-error paths (Modaliser-Spec logging contract).
;;
;; Each case spawns `racket main.rkt` as a subprocess with a sentinel
;; env var (MODALISER_TEST_BLOCK) that gates a headless path in main.rkt:
;; the child installs signal/error handlers, logs `[lifecycle] startup`,
;; then blocks on a semaphore (signal) or raises (error). This lets us
;; probe the contract without entering NSApp.

(require rackunit
         racket/file
         racket/port
         racket/runtime-path)

(define-runtime-path here ".")

(define main-rkt (simplify-path (build-path here ".." "main.rkt")))
(define racket-bin "/opt/homebrew/bin/racket")

(define (prepare-env tmp block-mode)
  (define env (environment-variables-copy (current-environment-variables)))
  (environment-variables-set! env #"MODALISER_EVENTS_LOG"
                              (string->bytes/utf-8 (path->string tmp)))
  (environment-variables-set! env #"MODALISER_TEST_BLOCK"
                              (string->bytes/utf-8 block-mode))
  env)

(define (wait-for-startup-line tmp timeout-s)
  ;; Poll the tmp log until the [lifecycle] startup line appears, so we
  ;; know the child has installed its signal handler before we send.
  (define deadline (+ (current-inexact-milliseconds) (* 1000.0 timeout-s)))
  (let loop ()
    (cond
      [(and (file-exists? tmp)
            (regexp-match? #px"\\[lifecycle\\] startup"
                           (file->string tmp)))
       #t]
      [(> (current-inexact-milliseconds) deadline) #f]
      [else
       (sleep 0.05)
       (loop)])))

(test-case "signal emits shutdown reason=signal"
  (define tmp (make-temporary-file "mod-signal-~a.log"))
  (define env (prepare-env tmp "signal"))
  (define-values (sp out in err)
    (parameterize ([current-environment-variables env])
      (subprocess #f #f #f racket-bin (path->string main-rkt))))
  (close-output-port in)
  (unless (wait-for-startup-line tmp 60.0)
    (subprocess-kill sp #t) (subprocess-wait sp)
    (fail (format "child did not write startup line: stderr=~a"
                  (port->string err))))
  (subprocess-kill sp #f)  ; #f → SIGINT → Racket exn:break
  (subprocess-wait sp)
  (close-input-port out)
  (close-input-port err)
  (define log (file->string tmp))
  (delete-file tmp)
  (check-regexp-match #px"\\[lifecycle\\] startup" log)
  (check-regexp-match #px"\\[lifecycle\\] shutdown reason=signal" log))

(test-case "uncaught exception emits shutdown reason=error"
  (define tmp (make-temporary-file "mod-error-~a.log"))
  (define env (prepare-env tmp "raise"))
  (define-values (sp out in err)
    (parameterize ([current-environment-variables env])
      (subprocess #f #f #f racket-bin (path->string main-rkt))))
  (close-output-port in)
  (subprocess-wait sp)
  (close-input-port out)
  (close-input-port err)
  (define log (file->string tmp))
  (delete-file tmp)
  (check-regexp-match #px"\\[lifecycle\\] shutdown reason=error" log)
  (check-regexp-match #px"message=" log))

(displayln "test-lifecycle-events: all checks passed")
