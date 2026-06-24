#lang racket/base
;; diag2.rkt — clean ffi2-callback test: NO ffi/unsafe, so ffi2's real `->`
;; (incl. nested arrow types for callback params) is unambiguous. THROWAWAY.
;; Tests an idiomatic ffi2 callback (arrow-type param, raw lambda) on the main
;; thread, then on a foreign pthread. Run with: racket diag2.rkt [main|pthread|both]

(require ffi2 racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define spike (ffi2-lib (path->string libspike-path)))
(define-ffi2-definer define-spike #:lib spike)

;; callout whose first parameter is a 0-arg void callback (nested arrow type)
(define-spike aw_spike_call_on_main    (-> (-> void_t) void_t))
(define-spike aw_spike_call_on_pthread (-> (-> void_t) void_t))

(define which
  (if (>= (vector-length (current-command-line-arguments)) 1)
      (vector-ref (current-command-line-arguments) 0)
      "both"))

(define fired (box #f))

(when (member which '("main" "both"))
  (printf "calling on MAIN with raw lambda...\n") (flush-output)
  (aw_spike_call_on_main (lambda () (set-box! fired 'main) (printf "  FIRED on main\n")))
  (printf "MAIN returned OK, fired=~a\n" (unbox fired)) (flush-output))

(when (member which '("pthread" "both"))
  (set-box! fired #f)
  (printf "calling on PTHREAD with raw lambda...\n") (flush-output)
  (aw_spike_call_on_pthread (lambda () (set-box! fired 'pthread) (printf "  FIRED on pthread\n")))
  (printf "PTHREAD returned OK, fired=~a\n" (unbox fired)) (flush-output))

(printf "diag2 done.\n") (flush-output)
