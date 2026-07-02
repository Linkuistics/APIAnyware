#lang racket/base
;; events.rkt — PDFKit Viewer structured event log.
;;
;; The k96 logging contract
;; (apps/macos/pdfkit-viewer/docs/logging-contract.md): the three hello-window
;; lifecycle events plus the two [document] state-transition events the spec §13
;; document-open / page-navigation assertions ride (the nav-button enabled flags
;; are dropped by the AX-snapshot transform, and the label's OCR can catch a
;; pre-repaint frame):
;;   [lifecycle] startup                          — readiness probe (`wait-ready`)
;;   PDFKit Viewer running. …                     — §3.7 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>              — terminate; reason ∈ {menu,signal,error}
;;   [document] opened file="…" pages=N           — open handler success path; post-state
;;   [document] page-changed page=n pages=N       — page-changed observer; post-refresh
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the ui-controls-gallery events.rkt (the worked template).
;;
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [document] events from the open-button
;; action callback and the page-changed notification observer, shutdown on
;; terminate — so one port with a post-write flush suffices (no lock needed).

(require racket/file
         racket/path
         racket/string)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-document-opened
         emit-page-changed
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/pdfkit-viewer/events.log")

(define the-port #f)
(define the-path #f)

;; PDFKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "PDFKIT_VIEWER_EVENTS_LOG"))
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
(define (emit-launch-line)     (emit-line "PDFKit Viewer running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The two [document] events — each emitted AFTER the state change it names is
;; applied (label text + nav-button enabled states already set; contract
;; "Document events").

;; `file` is the opened URL's LAST PATH COMPONENT (the panel canonicalizes
;; paths, so the basename is the stable identity); `pages` = pageCount.
;; Success path only — silent no-ops (cancel / nil URL / failed initWithURL:)
;; emit nothing.
(define (emit-document-opened file pages)
  (emit-line (format "[document] opened file=~a pages=~a" (quote-string file) pages)))

;; `page` is 1-based and always equals the label's n (nil-current-page
;; fallback ⇒ page=1); `pages` = N. Bare integers.
(define (emit-page-changed page pages)
  (emit-line (format "[document] page-changed page=~a pages=~a" page pages)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
