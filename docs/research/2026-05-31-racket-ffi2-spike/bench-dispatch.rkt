#lang racket/base
;; bench-dispatch.rkt — spike: outbound ObjC dispatch microbenchmark.
;; Compares per-call cost of sending `-hash` (no-arg, uint64 return) to a stable
;; NSObject across approaches. THROWAWAY (leaf 040/010).
;;
;;   C-floor                     — loop entirely in C (one FFI call); the floor.
;;   in-racket-tell              — today's path: ffi/unsafe/objc `tell`, SEL cached.
;;   native-typed-ffi2 (SEL)     — Racket -> ffi2 -> C typed objc_msgSend, SEL cached.
;;   native-typed-ffi2 (str)     — same but selector string marshalled per call.
;;   native-nsinvocation-ffi2    — Racket -> ffi2 -> C NSInvocation generic dispatch.
;;
;; NOTE: ffi2 and ffi/unsafe both export `->`. We keep ffi/unsafe's (used inside
;; `_fun`) and rename ffi2's arrow constructor to `ffi2->`. This collision is a
;; real migration constraint for any module mixing the two libraries.

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in ffi2 [-> ffi2->])
         racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define lib-str (path->string libspike-path))

(define spike (ffi2-lib lib-str))
(define-ffi2-definer define-spike #:lib spike)

(define-spike aw_spike_make_nsobject   (ffi2-> ptr_t))
(define-spike aw_spike_sel             (ffi2-> string_t ptr_t))
(define-spike aw_spike_msg_uint        (ffi2-> ptr_t string_t uint64_t))
(define-spike aw_spike_msg_uint_sel    (ffi2-> ptr_t ptr_t uint64_t))
(define-spike aw_spike_invoke_uint     (ffi2-> ptr_t string_t uint64_t))
(define-spike aw_spike_floor_hash_loop (ffi2-> ptr_t uint64_t uint64_t))
(define-spike aw_spike_ffi_msg_uint         (ffi2-> ptr_t ptr_t uint64_t))
(define-spike aw_spike_ffi_msg_uint_nocache (ffi2-> ptr_t ptr_t uint64_t))

;; One stable NSObject, made in C, held as a ffi2 ptr_t for the run.
(define obj-ptrt (aw_spike_make_nsobject))
(define hash-sel (aw_spike_sel "hash"))

;; Same object as an ffi/unsafe _id, for the `tell` baseline.
(define obj-id (cast (ptr_t->cpointer obj-ptrt) _pointer _id))

(define N 3000000)

(define (report label dt r)
  (printf "~a~a~a ms\t~a ns/call\t(chk ~a)\n"
          label
          (make-string (max 1 (- 32 (string-length label))) #\space)
          (real->decimal-string dt 1)
          (real->decimal-string (/ (* dt 1e6) N) 1)
          r))

(define (timeit label thunk)
  (collect-garbage)
  (define t0 (current-inexact-milliseconds))
  (define r (thunk))
  (report label (- (current-inexact-milliseconds) t0) r))

(printf "ffi2 dispatch spike — N = ~a iterations, selector -hash\n\n" N)

;; 0. C floor: loop runs inside C, single FFI crossing.
(timeit "C-floor (loop in C)"
        (lambda () (aw_spike_floor_hash_loop obj-ptrt N)))

;; 1. Today's path: in-Racket tell (SEL cached at macro expansion).
(timeit "in-racket-tell"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (tell #:type _uint64 obj-id hash))) acc))))

;; 2. Native typed entry via ffi2, SEL pre-registered (fair vs tell).
(timeit "native-typed-ffi2 (SEL cached)"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (aw_spike_msg_uint_sel obj-ptrt hash-sel))) acc))))

;; 3. Native typed entry via ffi2, selector string marshalled per call.
(timeit "native-typed-ffi2 (str/call)"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (aw_spike_msg_uint obj-ptrt "hash"))) acc))))

;; 4. Native NSInvocation generic dispatch via ffi2.
(timeit "native-nsinvocation-ffi2"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (aw_spike_invoke_uint obj-ptrt "hash"))) acc))))

;; 5. libffi generic dispatch via ffi2, CIF cached (steady-state hot path).
(timeit "native-libffi (CIF cached)"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (aw_spike_ffi_msg_uint obj-ptrt hash-sel))) acc))))

;; 6. libffi generic dispatch via ffi2, CIF rebuilt per call (cost the cache avoids).
(timeit "native-libffi (CIF per call)"
        (lambda ()
          (let loop ([i 0] [acc 0])
            (if (< i N) (loop (add1 i) (+ acc (aw_spike_ffi_msg_uint_nocache obj-ptrt hash-sel))) acc))))

(printf "\ndone.\n")
