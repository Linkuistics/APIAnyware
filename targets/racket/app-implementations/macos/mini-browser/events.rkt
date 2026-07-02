#lang racket/base
;; events.rkt — Mini Browser structured event log.
;;
;; The k114 logging contract
;; (apps/macos/mini-browser/docs/logging-contract.md): the three hello-window
;; lifecycle events plus the three [nav] navigation-state transitions the spec
;; §13 assertions ride (WKWebView loads are asynchronous, multi-callback — the
;; delegate resolves on the framework's schedule, so navigation completion and
;; failure are not assertable without a log record; and the ◀/▶ history enabled
;; flags are dropped by the AppSpec AX-snapshot transform — the finished
;; event's can-go-back/can-go-forward is the operative history channel):
;;   [lifecycle] startup                          — readiness probe (`wait-ready`)
;;   Mini Browser running. …                      — §3.7 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>              — terminate; reason ∈ {menu,signal,error}
;;   [nav] started url="…"                        — didStartProvisionalNavigation, post-state
;;   [nav] finished url="…" title="…" can-go-back=… can-go-forward=…
;;                                                — didFinishNavigation, after the whole
;;                                                  §7.2 chrome refresh; fixed key order
;;   [nav] failed phase=<request|load> message="…"
;;                                                — both failure callbacks, message
;;                                                  computed, BEFORE runModal (the
;;                                                  runner's pre-dismissal cue)
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the scenekit-viewer events.rkt (k107; pdfkit k98 template).
;;
;; Single writer: every event is emitted on the main thread — startup/launch
;; before -run, the [nav] events from the four WKNavigationDelegate callbacks
;; (WebKit delivers them on the main thread), shutdown on terminate — so one
;; port with a post-write flush suffices.

(require racket/file
         racket/path
         racket/string)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-nav-started
         emit-nav-finished
         emit-nav-failed
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/mini-browser/events.log")

(define the-port #f)
(define the-path #f)

;; MINI_BROWSER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "MINI_BROWSER_EVENTS_LOG"))
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
;; escaped; numbers/booleans/symbols emit bare. Booleans emit as the bare
;; symbols true/false — the contract defines the bytes, not the runtime's
;; native print form (#t does not conform).
(define (quote-string s)
  (string-append
   "\""
   (string-replace
    (string-replace
     (string-replace s "\\" "\\\\")
     "\"" "\\\"")
    "\n" "\\n")
   "\""))

(define (bool->contract b) (if b "true" "false"))

(define (emit-startup)         (emit-line "[lifecycle] startup"))
(define (emit-launch-line)     (emit-line "Mini Browser running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The three [nav] events. `started`/`finished` are POST-state (emitted after
;; the state change they name is fully applied); `failed` deliberately deviates
;; — emitted after the message is computed but BEFORE the blocking modal alert,
;; so the runner has a deterministic dismissal cue (contract "Navigation
;; events", deviation note). `url`/`title` are the web view's properties at
;; callback time, empty string when nil; the caller passes the already-read
;; Racket strings.

(define (emit-nav-started url)
  (emit-line (format "[nav] started url=~a" (quote-string url))))

;; Fixed key order url · title · can-go-back · can-go-forward (multi-key regex
;; matchers rely on adjacency).
(define (emit-nav-finished url title can-go-back can-go-forward)
  (emit-line (format "[nav] finished url=~a title=~a can-go-back=~a can-go-forward=~a"
                     (quote-string url)
                     (quote-string title)
                     (bool->contract can-go-back)
                     (bool->contract can-go-forward))))

;; `phase` ∈ {request, load} — normalized lowercase, emitted bare. `message` is
;; the error's localizedDescription (platform-formatted), or the literal
;; "Unknown error" on the nil-error boundary.
(define (emit-nav-failed phase message)
  (emit-line (format "[nav] failed phase=~a message=~a" phase (quote-string message))))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
