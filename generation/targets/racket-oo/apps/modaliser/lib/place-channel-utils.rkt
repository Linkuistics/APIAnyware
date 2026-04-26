#lang racket/base
;; place-channel-utils.rkt — Non-blocking try-receive for place channels.
;;
;; Racket does not expose a `place-channel-try-get`, but place channels
;; implement the synchronizable-event interface and `(sync/timeout 0 ch)`
;; is empirically a pure non-blocking try-receive: it returns the next
;; pending message if one is ready, #f otherwise, without invoking the
;; Racket thread scheduler's normal event pump. This is the one
;; scheduler-adjacent primitive that remains safe under nsapplication-
;; run, because each poll tick runs inside a brief Racket execution
;; window (scheduled via call-on-main-thread-after → GCD main queue)
;; and touches no thread-waiting mechanism.
;;
;; Isolated into a one-function helper module so the tests/source-
;; guards.rkt exemption for (sync/timeout ...) is scoped to a single
;; 5-line definition. All other forbidden scheduler forms remain
;; flagged in this file and everywhere else — see the per-form allowlist
;; entry in tests/test-source-guards.rkt.

(require racket/place)

(provide place-channel-try-get)

;; (place-channel-try-get ch) → any or #f
;; Returns the next available message on ch without blocking.
;; Returns #f if no message is ready. Safe to call from the main
;; thread under nsapplication-run.
(define (place-channel-try-get ch)
  (sync/timeout 0 ch))
