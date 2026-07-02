#lang racket/base
;; events.rkt — Note Editor structured event log.
;;
;; The k123 logging contract
;; (apps/macos/note-editor/docs/logging-contract.md): the three hello-window
;; lifecycle events plus the six [document] state transitions and the one
;; [preview] render event the spec §15 assertions ride (the save sheet's
;; completion handler resolves on the sheet's schedule, so save completion is
;; not assertable without a log record; the status label is the app's only
;; per-operation message surface — 11-pt, the OCR small-text class; and
;; preview render completion is entirely unobservable — §5.4):
;;   [lifecycle] startup                      — readiness probe (`wait-ready`)
;;   Note Editor running. …                   — §3 step 8 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>          — terminate; reason ∈ {menu,signal,error}
;;   [document] <event> path="…" dirty=<b>    — new/opened/saved/open-failed/
;;                                              save-failed/dirty-changed; POST-state
;;                                              at rule end; fixed key order path·dirty;
;;                                              failure events carry the ATTEMPTED path
;;   [preview] rendered placeholder=<b> chars=<n>
;;                                            — immediately after every
;;                                              loadHTMLString: hand-off; fixed key
;;                                              order placeholder·chars
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the mini-browser events.rkt (k116; scenekit k107 / pdfkit k98 line).
;;
;; Single writer: every event is emitted on the main thread — startup, the
;; initial render, and the launch line before -run; the [document]/[preview]
;; events from the five action handlers, the text-change notification observer,
;; and the save sheet's completion handler (all delivered by AppKit on the main
;; thread); shutdown on terminate — so one port with a post-write flush
;; suffices.

(require racket/file
         racket/path
         racket/string)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-document
         emit-preview-rendered
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/note-editor/events.log")

(define the-port #f)
(define the-path #f)

;; NOTE_EDITOR_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "NOTE_EDITOR_EVENTS_LOG"))
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
(define (emit-launch-line)     (emit-line "Note Editor running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The six [document] events, one emitter (contract "Document events"): the
;; caller passes the event name plus the two payload values. On the state
;; events (new/opened/saved/dirty-changed) `path` is the POST-state current
;; path (empty string when unset); on the failure events (open-failed/
;; save-failed) it is the ATTEMPTED file's absolute path (the model is
;; unchanged by rule §8.5.6/7). `dirty` is the post-state flag in both cases.
;; Fixed key order path · dirty (multi-key regex matchers rely on adjacency).
(define (emit-document event path dirty)
  (emit-line (format "[document] ~a path=~a dirty=~a"
                     event
                     (quote-string (or path ""))
                     (bool->contract dirty))))

;; The one [preview] event (contract "Preview events"): emitted immediately
;; after every loadHTMLString: hand-off — it witnesses the hand-off, not the
;; pixels (render completion is unobservable, §5.4). `placeholder` = whether
;; the §7.1 placeholder body was rendered; `chars` = the Unicode scalar count
;; of the Markdown source the render consumed (0 for the empty document).
;; Fixed key order placeholder · chars.
(define (emit-preview-rendered placeholder? chars)
  (emit-line (format "[preview] rendered placeholder=~a chars=~a"
                     (bool->contract placeholder?)
                     chars)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
