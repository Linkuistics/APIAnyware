#lang racket/base
;; events.rkt — Structured event emitter (Modaliser-Spec logging contract).
;;
;; Line format: [<module>] <event-name> <k>=<v> <k>=<v>\n
;;   - numbers and booleans emit bare (true/false for #t/#f)
;;   - symbols emit bare (their string name), safe chars only — callers
;;     pass a symbol to get an unquoted enum-like value (e.g. 'select)
;;   - strings are ALWAYS double-quoted with '\' / '"' / newline escape;
;;     scenario regexes assume consistent quoting ('query="..."' etc.)
;;   - any other value is coerced via `format "~v"` then string-quoted
;;
;; Emission is silent until `events-init!` is called. This keeps the
;; unit test suite from polluting a log file just because a module
;; under test happens to `(require "events.rkt")`. `main.rkt` calls
;; `events-init!` exactly once after the single-instance check; the
;; spec contract says truncate-on-startup, which that ordering honours.
;;
;; API:
;;   (events-init!)                              ; open default / env path
;;   (events-init! #:path p)                     ; open explicit path
;;   (log-event 'module 'event [k v] ...)        ; k is symbol, v any
;;   (events-log-path)                           ; current target, or #f
;;   (close-events!)                             ; flush + close (idempotent)
;;
;; Thread-safety: the Cocoa run loop serialises everything that matters
;; (main-thread callbacks, CGEvent tap) onto the main OS thread, so a
;; single port with post-write flush is sufficient. If off-main-thread
;; emitters are added later, wrap with an os-semaphore.

(require racket/file
         racket/path
         racket/port)

(provide events-init!
         events-log-path
         close-events!
         log-event)

(define events-port (make-parameter #f))
(define events-path (make-parameter #f))

(define (events-log-path) (events-path))

(define (default-log-path)
  (or (getenv "MODALISER_EVENTS_LOG")
      (let ([xdg (getenv "XDG_CACHE_HOME")])
        (path->string
         (build-path (if (and xdg (not (equal? xdg "")))
                         xdg
                         (build-path (find-system-path 'home-dir) ".cache"))
                     "modaliser" "events.log")))))

(define (events-init! #:path [p #f])
  (close-events!)
  (define target (or p (default-log-path)))
  (define parent (path-only target))
  (when parent (make-directory* parent))
  (define port (open-output-file target #:exists 'truncate/replace))
  (file-stream-buffer-mode port 'line)
  (events-port port)
  (events-path target)
  target)

(define (close-events!)
  (define p (events-port))
  (when p
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output p)
      (close-output-port p)))
  (events-port #f)
  (events-path #f))

;; --- value formatting ---

(define (escape-string s)
  (define out (open-output-string))
  (for ([ch (in-string s)])
    (cond
      [(eqv? ch #\\)    (write-string "\\\\" out)]
      [(eqv? ch #\")    (write-string "\\\"" out)]
      [(eqv? ch #\newline) (write-string "\\n" out)]
      [(eqv? ch #\return)  (write-string "\\r" out)]
      [(eqv? ch #\tab)     (write-string "\\t" out)]
      [else             (write-char ch out)]))
  (get-output-string out))

(define (quote-string s)
  (string-append "\"" (escape-string s) "\""))

(define safe-symbol-rx #px"^[A-Za-z0-9_.:/+*?<>=!@#$%^&-]+$")

(define (format-value v)
  (cond
    [(boolean? v) (if v "true" "false")]
    [(exact-integer? v) (number->string v)]
    [(and (number? v) (rational? v) (exact? v)) (number->string (exact->inexact v))]
    [(number? v) (number->string v)]
    [(symbol? v)
     (let ([s (symbol->string v)])
       (if (regexp-match? safe-symbol-rx s) s (quote-string s)))]
    [(path? v)   (quote-string (path->string v))]
    [(string? v) (quote-string v)]
    [else (quote-string (format "~v" v))]))

(define (log-event module-sym event-sym . kvs)
  ;; Validate arg shape whether or not a port is open, so shape bugs
  ;; surface in unit tests that haven't called events-init!.
  (let loop ([rest kvs])
    (cond
      [(null? rest) (void)]
      [(null? (cdr rest))
       (error 'log-event "odd number of key/value args: ~a/~a ~v"
              module-sym event-sym kvs)]
      [else (loop (cddr rest))]))
  (define port (events-port))
  (when port
    ;; Only swallow I/O-level failures — out-of-disk, EBADF, closed-port
    ;; races on shutdown. Programmer errors have already been raised
    ;; above.
    (with-handlers ([exn:fail:filesystem? (lambda (_) (void))])
      (fprintf port "[~a] ~a" module-sym event-sym)
      (let loop ([rest kvs])
        (cond
          [(null? rest) (void)]
          [else
           (fprintf port " ~a=~a" (car rest) (format-value (cadr rest)))
           (loop (cddr rest))]))
      (newline port)
      (flush-output port))))

(module+ test-hooks
  (provide format-value escape-string safe-symbol-rx))
