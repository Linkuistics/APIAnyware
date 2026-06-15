#lang racket/base
;; bench2.rkt — multi-shape dispatch benchmark (D1 rigor). Compares, across four
;; representative ABI shapes, three mechanisms. THROWAWAY (leaf 040/010).
;;
;; Baselines:
;;   racket-msgsend : in-Racket typed objc_msgSend via get-ffi-obj (the status-quo
;;                    mechanism the emitter generates for non-all-object shapes —
;;                    DispatchStrategy::TypedMsgSend). The honest "stays Racket" base.
;;   generated-typed: Racket -> ffi2 -> a generated C typed entry (the proposal).
;;   libffi-generic : Racket -> ffi2 -> one generic libffi dispatcher (CIF cached).
;;
;; Shapes (against a controlled AWSpikeTarget):
;;   h        : (id,SEL) -> uint64                 scalar return
;;   idfor:   : (id,SEL,id) -> id                  pointer in / pointer out
;;   rectfor: : (id,SEL,uint64) -> CGRect          STRUCT return (stresses libffi)
;;   addx:y:  : (id,SEL,double,double) -> double    multi-float args
;;
;; ffi2 & ffi/unsafe both export `->`; keep ffi/unsafe's (used in _fun) and drop
;; ffi2's via except-in (ffi2's nested arrow parsing breaks under rename-in).

;; keep ffi2's `->` (needed for arrow types incl. nested); drop ffi/unsafe's.
(require ffi2
         (except-in ffi/unsafe ->)
         racket/runtime-path)

(define-runtime-path libspike-path "libspike.dylib")
(define lib-str (path->string libspike-path))

;; ---- native side via ffi2 ----
(define spike (ffi2-lib lib-str))
(define-ffi2-definer define-spike #:lib spike)
(define-ffi2-type Rect4_t (struct_t [a double_t] [b double_t] [c double_t] [d double_t]))
(define-spike aw_spike_make_target (-> ptr_t))
(define-spike aw_spike_sel         (-> string_t ptr_t))
(define-spike aw_t_h      (-> ptr_t ptr_t uint64_t))
(define-spike aw_t_idfor  (-> ptr_t ptr_t ptr_t ptr_t))
(define-spike aw_t_rectfor(-> ptr_t ptr_t uint64_t ptr_t void_t))
(define-spike aw_t_addxy  (-> ptr_t ptr_t double_t double_t double_t))
(define-spike aw_l_h      (-> ptr_t ptr_t uint64_t))
(define-spike aw_l_idfor  (-> ptr_t ptr_t ptr_t ptr_t))
(define-spike aw_l_rectfor(-> ptr_t ptr_t uint64_t ptr_t void_t))
(define-spike aw_l_addxy  (-> ptr_t ptr_t double_t double_t double_t))

;; ---- Racket-side status-quo baseline: typed get-ffi-obj objc_msgSend ----
(define objc (ffi-lib "libobjc"))
(define-cstruct _Rect4 ([a _double] [b _double] [c _double] [d _double]))
;; Use _cprocedure (no `->` token) since ffi/unsafe's `->` is shadowed by ffi2's.
;; This is the same underlying typed objc_msgSend the emitter's _fun expands to.
(define r-h       (get-ffi-obj "objc_msgSend" objc (_cprocedure (list _pointer _pointer) _uint64)))
(define r-idfor   (get-ffi-obj "objc_msgSend" objc (_cprocedure (list _pointer _pointer _pointer) _pointer)))
(define r-rectfor (get-ffi-obj "objc_msgSend" objc (_cprocedure (list _pointer _pointer _uint64) _Rect4)))
(define r-addxy   (get-ffi-obj "objc_msgSend" objc (_cprocedure (list _pointer _pointer _double _double) _double)))

(define tgt (aw_spike_make_target))
(define tgt-cp (ptr_t->cpointer tgt))          ; ffi/unsafe cpointer view
(define sel-h       (aw_spike_sel "h"))
(define sel-idfor   (aw_spike_sel "idfor:"))
(define sel-rectfor (aw_spike_sel "rectfor:"))
(define sel-addxy   (aw_spike_sel "addx:y:"))
(define sel-h-cp       (ptr_t->cpointer sel-h))
(define sel-idfor-cp   (ptr_t->cpointer sel-idfor))
(define sel-rectfor-cp (ptr_t->cpointer sel-rectfor))
(define sel-addxy-cp   (ptr_t->cpointer sel-addxy))
(define rect-out (ffi2-malloc Rect4_t))

(define (timeit label N thunk)
  (collect-garbage)
  (define t0 (current-inexact-milliseconds))
  (define r (thunk))
  (define dt (- (current-inexact-milliseconds) t0))
  (printf "  ~a~a~a ns/call\t(~a ms)\n"
          label (make-string (max 1 (- 22 (string-length label))) #\space)
          (real->decimal-string (/ (* dt 1e6) N) 1)
          (real->decimal-string dt 0)))

(define Ns 3000000)
(define Nr 1500000)

(printf "== h  (id,SEL)->uint64 [scalar] ==  N=~a\n" Ns)
(timeit "racket-msgsend" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (r-h tgt-cp sel-h-cp) (loop (add1 i))))))
(timeit "generated-typed" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_t_h tgt sel-h) (loop (add1 i))))))
(timeit "libffi-generic"  Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_l_h tgt sel-h) (loop (add1 i))))))

(printf "== idfor:  (id,SEL,id)->id [pointer] ==  N=~a\n" Ns)
(timeit "racket-msgsend" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (r-idfor tgt-cp sel-idfor-cp tgt-cp) (loop (add1 i))))))
(timeit "generated-typed" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_t_idfor tgt sel-idfor tgt) (loop (add1 i))))))
(timeit "libffi-generic"  Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_l_idfor tgt sel-idfor tgt) (loop (add1 i))))))

(printf "== rectfor:  (id,SEL,uint64)->CGRect [STRUCT] ==  N=~a\n" Nr)
(timeit "racket-msgsend" Nr (lambda () (let loop ([i 0]) (when (< i Nr) (r-rectfor tgt-cp sel-rectfor-cp i) (loop (add1 i))))))
(timeit "generated-typed" Nr (lambda () (let loop ([i 0]) (when (< i Nr) (aw_t_rectfor tgt sel-rectfor i rect-out) (loop (add1 i))))))
(timeit "libffi-generic"  Nr (lambda () (let loop ([i 0]) (when (< i Nr) (aw_l_rectfor tgt sel-rectfor i rect-out) (loop (add1 i))))))

(printf "== addx:y:  (id,SEL,double,double)->double [float] ==  N=~a\n" Ns)
(timeit "racket-msgsend" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (r-addxy tgt-cp sel-addxy-cp 1.5 2.5) (loop (add1 i))))))
(timeit "generated-typed" Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_t_addxy tgt sel-addxy 1.5 2.5) (loop (add1 i))))))
(timeit "libffi-generic"  Ns (lambda () (let loop ([i 0]) (when (< i Ns) (aw_l_addxy tgt sel-addxy 1.5 2.5) (loop (add1 i))))))

(printf "\ndone.\n")
