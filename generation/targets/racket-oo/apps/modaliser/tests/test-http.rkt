#lang racket/base
;; test-http.rkt — Tests for services/http.rkt
;;
;; Covers the place-backed async http-get, the synchronous http-get-sync,
;; and the load-time smoke check. The async tests drive the drain loop
;; manually via the test-hooks submodule — under a real Cocoa run loop
;; the tick is scheduled via call-on-main-thread-after, but this test
;; file runs without an NSApplication and GCD's main queue never drains,
;; so the scheduled ticks are invisible. Manual draining exercises the
;; same drain-all-ready-responses! code path the scheduled tick would.

(require rackunit
         racket/port
         "../services/http.rkt"
         (submod "../services/http.rkt" test-hooks))

;; ─── Load-time smoke test ──────────────────────────────────
;; Catches load-time breakage in http.rkt (memory: "Verify bindings
;; by loading, not grepping"). The static forbidden-form guardrail
;; lives in tests/test-source-guards.rkt.
(check-not-exn
 (lambda ()
   (dynamic-require
    (build-path (current-directory) "services" "http.rkt") #f))
 "http.rkt must load without errors")

;; ─── http-get-sync (synchronous path) ──────────────────────

(define result (http-get-sync "http://captive.apple.com"))
(check-true (string? result)
            "http-get-sync: successful request returns a string")
(check-true (> (string-length result) 0)
            "http-get-sync: response is non-empty")

(check-false (http-get-sync "http://this-domain-definitely-does-not-exist-xyz123.example")
             "http-get-sync: invalid domain returns #f")

(check-false (http-get-sync "not-a-url")
             "http-get-sync: malformed URL returns #f")

;; ─── http-get (async, place-backed) ────────────────────────

;; Bounded drain loop: poll drain-all-ready-responses! at 20 ms
;; intervals until either the target predicate holds or the deadline
;; expires. Returns #t on success, raises on timeout. Uses (sleep)
;; which is scheduler-dependent — safe here because the test runs
;; outside nsapplication-run so Racket's scheduler is live.
(define (wait-for-drain pred timeout-seconds label)
  (define deadline (+ (current-inexact-milliseconds) (* 1000 timeout-seconds)))
  (let loop ()
    (drain-all-ready-responses!)
    (cond
      [(pred) #t]
      [(> (current-inexact-milliseconds) deadline)
       (error 'wait-for-drain
              "~a not satisfied within ~a seconds" label timeout-seconds)]
      [else
       (sleep 0.02)
       (loop)])))

;; Test 1: single async GET against a live endpoint.
(test-case "async http-get: single request delivers body"
  (define result-box (box 'unset))
  (http-get "http://captive.apple.com"
            (lambda (body) (set-box! result-box body)))
  (wait-for-drain (lambda () (not (eq? (unbox result-box) 'unset)))
                  10.0 "single-request callback")
  (check-true (string? (unbox result-box)))
  (check-true (> (string-length (unbox result-box)) 0))
  (check-equal? (pending-request-count) 0
                "all pending callbacks drained"))

;; Test 2: invalid URL delivers #f, not a raised error.
(test-case "async http-get: failure delivers #f"
  (define result-box (box 'unset))
  (http-get "http://this-domain-definitely-does-not-exist-xyz123.example"
            (lambda (body) (set-box! result-box body)))
  (wait-for-drain (lambda () (not (eq? (unbox result-box) 'unset)))
                  10.0 "failed-request callback")
  (check-false (unbox result-box))
  (check-equal? (pending-request-count) 0))

;; Test 3: multiple concurrent requests route to correct callbacks.
;; Each request's callback writes to a unique slot; we verify no
;; cross-contamination.
(test-case "async http-get: concurrent requests route correctly"
  (define N 3)
  (define slots (make-vector N 'unset))
  (for ([i (in-range N)])
    (define my-i i)
    (http-get "http://captive.apple.com"
              (lambda (body) (vector-set! slots my-i body))))
  (check-equal? (pending-request-count) N
                "all N requests registered before any drain")
  (wait-for-drain
    (lambda ()
      (for/and ([s (in-vector slots)]) (not (eq? s 'unset))))
    10.0 "all concurrent callbacks")
  (for ([s (in-vector slots)] [i (in-naturals)])
    (check-true (string? s)
                (format "slot ~a received a string body" i)))
  (check-equal? (pending-request-count) 0))

(displayln "test-http: all checks passed")
