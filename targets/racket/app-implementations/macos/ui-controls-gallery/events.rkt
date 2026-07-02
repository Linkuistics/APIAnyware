#lang racket/base
;; events.rkt — UI Controls Gallery structured event log.
;;
;; The k87 logging contract
;; (apps/macos/ui-controls-gallery/docs/logging-contract.md): the three
;; hello-window lifecycle events plus the four [controls] state-change events
;; the spec §13 interaction assertions ride (the runner's `expect-ax` matches
;; role + exact title only — it has no value/state read):
;;   [lifecycle] startup                        — readiness probe (`wait-ready`)
;;   UI Controls Gallery running. …             — §3.6 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>            — terminate; reason ∈ {menu,signal,error}
;;   [controls] radio-selected option="…"       — radio action; post-state sole selection
;;   [controls] checkbox-changed state=on|off   — checkbox action; post-toggle state
;;   [controls] slider-changed value=<int>      — slider action; double → nearest int
;;   [controls] stepper-changed value=<int>     — stepper action; integral value
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the hello-window events.rkt (the worked template).
;;
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [controls] events from action
;; callbacks, shutdown on terminate — so one port with a post-write flush
;; suffices (no lock needed).

(require racket/file
         racket/path
         racket/string)

(provide events-init!
         emit-startup
         emit-opened
         emit-shutdown
         emit-radio-selected
         emit-checkbox-changed
         emit-slider-changed
         emit-stepper-changed
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/ui-controls-gallery/events.log")

(define the-port #f)
(define the-path #f)

;; UI_CONTROLS_GALLERY_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "UI_CONTROLS_GALLERY_EVENTS_LOG"))
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

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (quote-string s)
  (string-append
   "\""
   (string-replace
    (string-replace
     (string-replace s "\\" "\\\\")
     "\"" "\\\"")
    "\n" "\\n")
   "\""))

(define (emit-startup)         (emit-line "[lifecycle] startup"))
(define (emit-opened)          (emit-line "UI Controls Gallery running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The four [controls] events — each emitted from its control's action
;; callback AFTER the state change it names is applied.
(define (emit-radio-selected title)
  (emit-line (format "[controls] radio-selected option=~a" (quote-string title))))

(define (emit-checkbox-changed on?)
  (emit-line (format "[controls] checkbox-changed state=~a" (if on? "on" "off"))))

;; Slider carries a double; the contract formats values as integers so the
;; clamped ends are exactly 0/100.
(define (emit-slider-changed value)
  (emit-line (format "[controls] slider-changed value=~a"
                     (inexact->exact (round value)))))

;; Stepper values (0–10 step 1) are integral already.
(define (emit-stepper-changed value)
  (emit-line (format "[controls] stepper-changed value=~a" value)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
