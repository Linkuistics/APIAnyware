#lang racket/base
;; events.rkt — Swift-Native Probe structured event log (racket target).
;;
;; The k141 logging contract (apps/macos/swift-native-probe/docs/logging-contract.md):
;; the hello-window lifecycle triad plus the [probe] events that carry THIS app's actual
;; coverage proof — one [probe] result per probed shape (each with an explicit ok-check vs
;; a known-good expected) and a [probe] complete summary whose all-ok=#t is the single
;; target-agnostic coverage assertion scenario 01 consumes:
;;   [lifecycle] startup                                        — readiness probe (`wait-ready`)
;;   [probe] result shape=<s> name="<sym>" ok=<#t|#f> value=<v> — once per probed shape
;;   [probe] complete count=<n> ok=<n> all-ok=<#t|#f>           — the coverage assertion (01)
;;   Swift-Native Probe opened.                                 — window key+front; BARE line
;;   [lifecycle] shutdown reason=<r>                            — terminate; reason ∈ {menu,signal,error}
;;
;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading stdout:
;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference emitters: the
;; drawing-canvas events.rkt (this target's k134 sibling — the module shape) and the sbcl
;; swift-native-probe events.lisp (this app's k143 sibling — the [probe] event shape).
;;
;; Unlike drawing-canvas (whose events carry only bare integers), this app's [probe] events
;; carry STRING values — `name` always, and the `constant` shape's value ("com.apple.CreateML")
;; — so this module keeps a `quote-string` helper (drawing-canvas omitted it). Racket's
;; `~s` produces the contract's re-readable double-quoted form (escaping `"`/`\`/newline).
;;
;; Single writer: the probe computes on the main thread before the run loop, and the only
;; later writes are the launch line and the shutdown line (also main thread) — one port
;; with a post-write flush suffices, no lock.

(require racket/file
         racket/path)

(provide events-init!
         emit-startup
         emit-launch-line
         emit-shutdown
         emit-probe-result
         emit-probe-complete
         close-events!
         events-log-path)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same file
;; whether or not #:log-env (SWIFT_NATIVE_PROBE_EVENTS_LOG) propagates through LaunchServices.
(define default-events-path "/tmp/swift-native-probe/events.log")

(define the-port #f)
(define the-path #f)

;; SWIFT_NATIVE_PROBE_EVENTS_LOG if set and non-empty, else the fixed default.
(define (resolve-path)
  (define env (getenv "SWIFT_NATIVE_PROBE_EVENTS_LOG"))
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
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on shutdown).
    ;; A shape/programmer error must still surface.
    (with-handlers ([exn:fail:filesystem? (lambda (_) (void))])
      (fprintf the-port "~a\n" line)
      (flush-output the-port))))

;; Scheme-style boolean literal for the contract's ok/all-ok alphabet.
(define (bool->hash b) (if b "#t" "#f"))

;; Re-readable double-quoted form (the contract's string-value alphabet): `~s` escapes
;; `"`/`\`/newline. Used for `name` (always) and any string `value`.
(define (quote-string s) (format "~s" s))

(define (emit-startup)     (emit-line "[lifecycle] startup"))

;; The §step-6 launch diagnostic — the bare (unbracketed) line the runner's `wait-for-log`
;; matches; dual-emitted (the stdout print stays in swift-native-probe.rkt for unbundled
;; runs). Identical wording across all four impls (the contract's stable launch line).
(define (emit-launch-line) (emit-line "Swift-Native Probe opened."))

(define (emit-shutdown reason)
  (emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; One coverage-set shape's result. SHAPE is a bare symbol (function/constant/…), NAME the
;; probed symbol (emitted double-quoted), OK a boolean (emitted #t/#f), VALUE-REPR the
;; ALREADY-rendered value string — the caller renders numbers bare and strings quoted (only
;; the call site knows each shape's live type), per the contract's value semantics.
(define (emit-probe-result shape name ok value-repr)
  (emit-line (format "[probe] result shape=~a name=~a ok=~a value=~a"
                     shape (quote-string name) (bool->hash ok) value-repr)))

;; The coverage summary scenario 01 asserts. ALL-OK must be #t iff OK = COUNT.
(define (emit-probe-complete count ok all-ok)
  (emit-line (format "[probe] complete count=~a ok=~a all-ok=~a"
                     count ok (bool->hash all-ok))))

(define (close-events!)
  (when the-port
    (with-handlers ([exn:fail? (lambda (_) (void))])
      (flush-output the-port)
      (close-output-port the-port)))
  (set! the-port #f)
  (set! the-path #f))
