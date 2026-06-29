#lang racket/base
;; events.rkt — Hello Window structured event log.
;;
;; The de-Modalisered v1 logging contract
;; (apps/macos/hello-window/docs/logging-contract.md), narrowed to the three
;; events Hello Window's scenario suite consumes:
;;   [lifecycle] startup             — readiness probe (runner `wait-ready`)
;;   Hello Window opened.            — §10 launch diagnostic; BARE line; scenario 01
;;   [lifecycle] shutdown reason=<r> — terminate; scenario 03 / `quit-impl!`
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the v1 Modaliser lib/events.rkt.
;;
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit, so one port with a post-write flush suffices (no lock needed).

(require racket/file
         racket/path)

(provide events-init!
         emit-startup
         emit-opened
         emit-shutdown
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/hello-window/events.log")

(define the-port #f)
(define the-path #f)

;; HELLO_WINDOW_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "HELLO_WINDOW_EVENTS_LOG"))
  (if (and env (not (string=? env ""))) env default-events-path))

(define (events-log-path) the-path)

(define (events-init!)
  (close-events!)
  (define target (resolve-path))
  (define parent (path-only target))
  (when parent (make-directory* parent))
  (define port (open-output-file target #:exists 'truncate/replace))
  (file-stream-buffer-mode port 'line)
  (set! the-port port)
  (set! the-path target)
  target)

(define (emit-line line)
  (when the-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A shape/programmer error must still surface.
    (with-handlers ([exn:fail:filesystem? (lambda (_) (void))])
      (fprintf the-port "~a\n" line)
      (flush-output the-port))))

(define (emit-startup)        (emit-line "[lifecycle] startup"))
(define (emit-opened)         (emit-line "Hello Window opened."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
