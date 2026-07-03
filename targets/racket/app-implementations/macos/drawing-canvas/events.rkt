#lang racket/base
;; events.rkt — Drawing Canvas structured event log.
;;
;; The k132 logging contract
;; (apps/macos/drawing-canvas/docs/logging-contract.md): the three hello-window
;; lifecycle events plus the five [canvas] state transitions the spec §14
;; assertions ride (the canvas is a custom NSView whose strokes are framebuffer
;; pixels — OCR-meaningless and AX-invisible, spec §12 — so without log events
;; stroke lifecycle and tool state are not assertable at all; the scenekit
;; [scene] channel mirror):
;;   [lifecycle] startup                      — readiness probe (`wait-ready`)
;;   Drawing Canvas running. …                — §3 step 6 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>          — terminate; reason ∈ {menu,signal,error}
;;   [canvas] stroke-begun r= g= b= width=    — end of the §7.2 mouse-down rule; the
;;                                              stroke's FROZEN colour+width
;;   [canvas] stroke-committed r= g= b= width= points=
;;                                            — end of the §7.2 mouse-up rule; same
;;                                              frozen tuple + stored point count
;;   [canvas] color-changed r= g= b=          — panel handler success path, post-store
;;   [canvas] width-changed width=            — slider action, post-store
;;   [canvas] cleared count=<n>               — end of every Clear; 0 on empty
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the note-editor events.rkt (k125; mini-browser k116 line). No event
;; in this app carries a string value, so the quote-string helper is omitted —
;; every value is a bare integer or symbol per the contract's line format.
;;
;; Single writer: every event is emitted on the main thread — startup and the
;; launch line before -run; the [canvas] events from the canvas subclass's
;; mouse overrides (AppKit event dispatch), the slider and Clear action
;; handlers, and the colour panel's continuous colorChanged: action (the shared
;; NSColorPanel is in-process; the Cocoa run loop serialises its sends) —
;; shutdown on terminate — so one port with a post-write flush suffices.
;;
;; Integer formatting (contract "Canvas events"): r/g/b are the stored
;; device-RGB components × 255, width the stored width, each rounded to the
;; nearest integer at emit from the stored doubles — rounded ONCE, here, so
;; every event formatting the same stored double agrees (the freeze proof
;; rides that agreement).

(require racket/file
         racket/path)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-stroke-begun
         emit-stroke-committed
         emit-color-changed
         emit-width-changed
         emit-cleared
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/drawing-canvas/events.log")

(define the-port #f)
(define the-path #f)

;; DRAWING_CANVAS_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "DRAWING_CANVAS_EVENTS_LOG"))
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

;; Stored double -> bare integer, rounded to nearest (the one rounding site).
(define (component->255 c) (inexact->exact (round (* c 255.0))))
(define (width->int w)     (inexact->exact (round w)))

(define (emit-startup)         (emit-line "[lifecycle] startup"))
(define (emit-launch-line)     (emit-line "Drawing Canvas running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The two stroke events (contract "Canvas events"): the caller passes the
;; STROKE'S OWN frozen components/width (captured at its mouse-down — read from
;; the stroke, never from the current tool state), plus the stored point count
;; on commit (down point + drag points; the release is not appended). Fixed key
;; order r · g · b · width (· points).
(define (emit-stroke-begun r g b width)
  (emit-line (format "[canvas] stroke-begun r=~a g=~a b=~a width=~a"
                     (component->255 r) (component->255 g) (component->255 b)
                     (width->int width))))

(define (emit-stroke-committed r g b width points)
  (emit-line (format "[canvas] stroke-committed r=~a g=~a b=~a width=~a points=~a"
                     (component->255 r) (component->255 g) (component->255 b)
                     (width->int width) points)))

;; Success-path only (§8.1 step 4): emitted after the device-RGB components are
;; stored; the silent no-ops (nil panel colour, failed conversion) emit nothing.
(define (emit-color-changed r g b)
  (emit-line (format "[canvas] color-changed r=~a g=~a b=~a"
                     (component->255 r) (component->255 g) (component->255 b))))

(define (emit-width-changed width)
  (emit-line (format "[canvas] width-changed width=~a" (width->int width))))

;; Always emitted, including on an already-empty canvas (count=0) — the
;; positive channel for stroke-set cardinality.
(define (emit-cleared count)
  (emit-line (format "[canvas] cleared count=~a" count)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
