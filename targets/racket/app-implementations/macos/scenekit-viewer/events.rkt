#lang racket/base
;; events.rkt — SceneKit Viewer structured event log.
;;
;; The k105 logging contract
;; (apps/macos/scenekit-viewer/docs/logging-contract.md): the three hello-window
;; lifecycle events plus the two [scene] state-transition events the spec §13
;; scene assertions ride (the SCNView's rendered contents are pixel-level —
;; invisible to OCR and the AX tree, and the verb set has no drag or pixel-diff
;; verb — so the geometry swap and the colour that survives it are assertable
;; only through these log events):
;;   [lifecycle] startup                              — readiness probe (`wait-ready`)
;;   SceneKit Viewer running. …                       — §3.6 launch diagnostic; BARE line
;;   [lifecycle] shutdown reason=<r>                  — terminate; reason ∈ {menu,signal,error}
;;   [scene] geometry-changed shape="…" r=… g=… b=…   — picker handler; post swap + §7.2 re-apply
;;   [scene] color-changed r=… g=… b=…                — panel handler success path; post store+apply
;;
;; The runner tails this file (runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;; emitter: the pdfkit-viewer events.rkt (the k98 worked template).
;;
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [scene] events from the picker's
;; action callback and the in-process colour panel's continuous action callback,
;; shutdown on terminate — so one port with a post-write flush suffices.

(require racket/file
         racket/path
         racket/string)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-geometry-changed
         emit-color-changed
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env propagates through LaunchServices.
(define default-events-path "/tmp/scenekit-viewer/events.log")

(define the-port #f)
(define the-path #f)

;; SCENEKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "SCENEKIT_VIEWER_EVENTS_LOG"))
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
(define (emit-launch-line)     (emit-line "SceneKit Viewer running. Close window or Ctrl+C to exit."))
(define (emit-shutdown reason) (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The two [scene] events — each emitted AFTER the state change it names is
;; fully applied (contract "Scene events"). `r`/`g`/`b` are the STORED current
;; colour's device-RGB components ×255, rounded to nearest integer (bare
;; integers 0–255) — the caller converts via colorUsingColorSpace: device-RGB
;; at emit time and folds; the emitters take the already-folded integers.

;; `shape` is the applied catalogue title (Cube/Sphere/Torus/Cylinder) —
;; identical to the picker's selected-item title. Carries the post-swap colour
;; so the §13 key behaviour (colour persists across a swap) is a single-line
;; assertion.
(define (emit-geometry-changed shape r g b)
  (emit-line (format "[scene] geometry-changed shape=~a r=~a g=~a b=~a"
                     (quote-string shape) r g b)))

;; Success path only — a nil panel colour and a failed device-RGB conversion
;; are silent no-ops (no event, no error line; absence IS the contract).
(define (emit-color-changed r g b)
  (emit-line (format "[scene] color-changed r=~a g=~a b=~a" r g b)))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
