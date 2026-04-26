#lang racket/base
;; http.rkt — HTTP GET facade (place-backed async, main-thread polling)
;;
;; Architecture:
;;
;;   Main thread                              Worker place
;;   ───────────                              ────────────
;;   (http-get url cb)  ─request──────────▶   fetch via net/url
;;                                            │
;;   call-on-main-thread-after 50ms tick      │
;;         ↓                                  │
;;   (sync/timeout 0 worker-ch)  ◀─response── done
;;         ↓
;;   (cb body)
;;
;; A single long-lived "network worker" place hosts all HTTP fetches.
;; Places have their own Racket VM and scheduler, so net/url works
;; inside them — unlike call-in-os-thread, where tcp-connect segfaults
;; (see memory: "ffi/unsafe/os-thread is limited to pure computation").
;;
;; The main thread never blocks: it drops a request onto the place
;; channel and schedules a 50 ms polling tick via call-on-main-thread-
;; after. Each tick drains ready responses with (sync/timeout 0 …),
;; which is empirically a pure non-blocking try-receive — no dependence
;; on the Racket scheduler's normal I/O pump, safe under nsapplication-
;; run where the scheduler is blocked by the Cocoa event loop.
;;
;; Stale-query guards live in the caller (e.g. web-search-handler's
;; current-search-query box). http-get is agnostic about semantics;
;; every issued request eventually delivers its callback.

(require racket/place
         racket/runtime-path
         net/url
         racket/port
         "../ffi/main-thread.rkt"
         "../lib/place-channel-utils.rkt")

(provide http-get
         http-get-sync
         shutdown-http-worker!)

(define-runtime-path worker-module-path "http-worker.rkt")

;; Poll interval for draining the worker's response channel.
;; 50 ms keeps added latency below a single frame at 16 ms * 3 and
;; stays well under Google Suggest's median round-trip (~150 ms).
(define POLL-INTERVAL-SECONDS 0.05)

;; ─── Main-thread state ──────────────────────────────────────
;; All of these are only read/written from the main thread (from
;; http-get directly, or from drain-and-maybe-reschedule! which is
;; always invoked via call-on-main-thread-after). No cross-thread
;; access, so no locks needed.

(define worker-place #f)
(define next-request-id 0)
(define pending-callbacks (make-hasheqv))
(define poll-scheduled? #f)

;; ─── Worker lifecycle ───────────────────────────────────────

;; Lazily spawn the worker place on the first http-get call.
;; Startup cost (~100 ms) is paid once and amortized over every
;; subsequent request.
(define (ensure-worker-started!)
  (unless worker-place
    (set! worker-place
          (dynamic-place worker-module-path 'http-worker-body))))

;; Gracefully tell the worker place to exit and wait for it.
;; Intended for clean app shutdown; not required for correctness
;; since places die with the parent process anyway.
(define (shutdown-http-worker!)
  (when worker-place
    (with-handlers ([exn:fail? (lambda (_e) (void))])
      (place-channel-put worker-place 'quit)
      (place-wait worker-place))
    (set! worker-place #f)))

;; ─── Polling loop ───────────────────────────────────────────

(define (ensure-poll-scheduled!)
  (unless poll-scheduled?
    (set! poll-scheduled? #t)
    (call-on-main-thread-after POLL-INTERVAL-SECONDS drain-and-maybe-reschedule!)))

(define (drain-and-maybe-reschedule!)
  (set! poll-scheduled? #f)
  (drain-all-ready-responses!)
  (when (positive? (hash-count pending-callbacks))
    (ensure-poll-scheduled!)))

(define (drain-all-ready-responses!)
  (let loop ()
    (define response (place-channel-try-get worker-place))
    (when response
      (define id (car response))
      (define body (cdr response))
      (define cb (hash-ref pending-callbacks id #f))
      (when cb
        (hash-remove! pending-callbacks id)
        (with-handlers ([exn:fail?
                         (lambda (e)
                           (eprintf "http: callback error for id ~a: ~a\n"
                                    id (exn-message e)))])
          (cb body)))
      (loop))))

;; ─── Public API ─────────────────────────────────────────────

;; (http-get url-string callback) → void
;; Fires off an async HTTP GET. Returns immediately. The callback is
;; eventually invoked on the main thread with the response body string
;; (on success) or #f (on any failure: network error, non-2xx, parse
;; error, etc.). Order of callback invocation is NOT guaranteed when
;; multiple requests are in flight — each request's callback is routed
;; to its own request by id.
(define (http-get url-string callback)
  (ensure-worker-started!)
  (define id next-request-id)
  (set! next-request-id (add1 id))
  (hash-set! pending-callbacks id callback)
  (place-channel-put worker-place (list id url-string))
  (ensure-poll-scheduled!))

;; (http-get-sync url-string) → string or #f
;; Blocking HTTP GET on the caller's thread. Kept for callers that
;; explicitly want synchronous semantics and know they're off the
;; main thread (or that the latency is acceptable on it). The async
;; http-get should be preferred for main-thread callers.
(define (http-get-sync url-string)
  (with-handlers ([exn:fail? (lambda (_e) #f)])
    (define u (string->url url-string))
    (define in (get-pure-port u #:redirections 5))
    (dynamic-wind
      void
      (lambda () (port->string in))
      (lambda () (close-input-port in)))))

;; ─── Test hooks ─────────────────────────────────────────────
;; Under the real Cocoa run loop, call-on-main-thread-after drives
;; the polling tick automatically. In a plain `racket tests/...`
;; invocation there is no Cocoa run loop, so the scheduled tick
;; never fires. Tests drive the drain manually via this hook —
;; identical to what the GCD-scheduled tick would do.

(module+ test-hooks
  (provide drain-all-ready-responses!
           pending-request-count))

(define (pending-request-count)
  (hash-count pending-callbacks))
