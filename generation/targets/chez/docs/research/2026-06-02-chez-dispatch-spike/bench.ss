;; bench.ss — chez dispatch/marshalling spike harness. THROWAWAY.
;;
;; Run from this directory:  chez --script bench.ss
;;
;; Part A isolates the cost of a native typed shim (aw_chez_send_*) vs Chez
;; calling objc_msgSend DIRECTLY via foreign-procedure, plus libffi-generic.
;; Part B measures whether native marshalling beats chez-side coercion.

(import (chezscheme))

(load-shared-object "./libchezspike.dylib")
(load-shared-object "libobjc.A.dylib")

;; --- geometry ftype for the direct struct-return path -----------------------
(define-ftype NSPoint (struct [x double-float] [y double-float]))
(define-ftype NSSize  (struct [w double-float] [h double-float]))
(define-ftype NSRect  (struct [origin NSPoint] [size NSSize]))

;; --- libobjc + spike entry points -------------------------------------------
(define objc_getClass (foreign-procedure "objc_getClass" (string) void*))
(define aw-make-target (foreign-procedure "aw_spike_make_target" () void*))
(define aw-sel         (foreign-procedure "aw_spike_sel" (string) void*))

;; direct objc_msgSend, one typed foreign-procedure per shape (status quo)
(define %msg-scalar (foreign-procedure "objc_msgSend" (void* void* integer-64) integer-64))
(define %msg-id     (foreign-procedure "objc_msgSend" (void* void* void*) void*))
(define %msg-2f     (foreign-procedure "objc_msgSend" (void* void* double-float double-float) double-float))
(define %msg-rect   (foreign-procedure "objc_msgSend" (void* void*) (& NSRect)))
(define %msg-0      (foreign-procedure "objc_msgSend" (void* void*) void*))
(define %msg-add    (foreign-procedure "objc_msgSend" (void* void* void*) void*))

;; native typed shims (the "hop")
(define send-scalar (foreign-procedure "aw_chez_send_scalar" (void* void* integer-64) integer-64))
(define send-id     (foreign-procedure "aw_chez_send_id" (void* void* void*) void*))
(define send-2f     (foreign-procedure "aw_chez_send_2f" (void* void* double-float double-float) double-float))
(define send-rect   (foreign-procedure "aw_chez_send_rect" (void* void* void*) void))

;; libffi generic, CIF cached
(define ffi-scalar  (foreign-procedure "aw_chez_ffi_scalar" (void* void* integer-64) integer-64))

;; marshalling helpers
(define str2ns      (foreign-procedure "aw_chez_str2ns" (string) void*))
(define ns2str      (foreign-procedure "aw_chez_ns2str" (void*) string))
(define aw-free     (foreign-procedure "aw_chez_free" (void*) void))
(define append-bang (foreign-procedure "aw_chez_append_bang" (string) string))
(define strs->arr   (foreign-procedure "aw_chez_strings_to_nsarray_joined" (string) void*))
(define strs->arr2  (foreign-procedure "aw_chez_strs_to_nsarray" (void* int) void*))
(define arr-count   (foreign-procedure "aw_chez_nsarray_count" (void*) unsigned-long))

;; ---------------------------------------------------------------------------
(define target (aw-make-target))
(define sel-scalar  (aw-sel "scalar:"))
(define sel-idecho  (aw-sel "idecho:"))
(define sel-rect    (aw-sel "rect"))
(define sel-sum     (aw-sel "sum:and:"))
(define sel-append  (aw-sel "appendBang:"))
(define cls-mutarr  (objc_getClass "NSMutableArray"))
(define sel-array   (aw-sel "array"))
(define sel-addobj  (aw-sel "addObject:"))

(define rect-buf (foreign-alloc (* 8 4))) ; 4 doubles for the native rect shim
;; (& NSRect) return passes the result buffer as an implicit LEADING arg.
(define rect-ret (make-ftype-pointer NSRect (foreign-alloc (ftype-sizeof NSRect))))

;; --- timing -----------------------------------------------------------------
(define (ns/call name iters thunk)
  ;; warm up
  (let loop ([i 0]) (when (< i 200000) (thunk) (loop (+ i 1))))
  (collect (collect-maximum-generation))
  (let* ([t0 (current-time 'time-monotonic)]
         [_  (let loop ([i 0]) (when (< i iters) (thunk) (loop (+ i 1))))]
         [t1 (current-time 'time-monotonic)]
         [dt-ns (+ (* (- (time-second t1) (time-second t0)) 1000000000)
                   (- (time-nanosecond t1) (time-nanosecond t0)))])
    (printf "  ~a~a~7,1f ns/call\n"
            name
            (make-string (max 1 (- 34 (string-length name))) #\space)
            (/ dt-ns iters))))

(define N 3000000)

(printf "\n=== PART A: dispatch (~a iters) ===\n" N)
(printf " scalar  (id,SEL,long)->long\n")
(ns/call "direct foreign-procedure" N (lambda () (%msg-scalar target sel-scalar 41)))
(ns/call "native typed shim (hop)"  N (lambda () (send-scalar target sel-scalar 41)))
(ns/call "libffi generic (cached)"  N (lambda () (ffi-scalar  target sel-scalar 41)))

(printf " id->id  (id,SEL,id)->id\n")
(ns/call "direct foreign-procedure" N (lambda () (%msg-id  target sel-idecho target)))
(ns/call "native typed shim (hop)"  N (lambda () (send-id  target sel-idecho target)))

(printf " 2xfloat (id,SEL,dbl,dbl)->dbl\n")
(ns/call "direct foreign-procedure" N (lambda () (%msg-2f  target sel-sum 1.5 2.5)))
(ns/call "native typed shim (hop)"  N (lambda () (send-2f  target sel-sum 1.5 2.5)))

(printf " struct  (id,SEL)->NSRect\n")
(ns/call "direct foreign-procedure (& NSRect)" N
         (lambda () (begin (%msg-rect rect-ret target sel-rect)
                           (ftype-ref NSRect (origin x) rect-ret))))
(ns/call "native shim -> flat buffer" N
         (lambda () (begin (send-rect target sel-rect rect-buf) (foreign-ref 'double rect-buf 0))))

(printf "\n=== PART B: marshalling (~a iters) ===\n" N)
(printf " string in/out  -appendBang:\n")
(ns/call "chez-side: str2ns+msg+ns2str" N
         (lambda ()
           (let* ([ns (str2ns "hello")]
                  [r  (%msg-id target sel-append ns)]
                  [s  (ns2str r)])
             s)))
(ns/call "native one-call append-bang" N (lambda () (append-bang "hello")))

(let ([M (quotient N 30)]
      [items '("a" "b" "c" "d" "e" "f" "g" "h")])
  (printf " list->NSArray (~a elems, ~a iters)\n" (length items) M)
  (ns/call "chez-side: mutarray + loop" M
           (lambda ()
             (let ([arr (%msg-0 cls-mutarr sel-array)])
               (for-each (lambda (s) (%msg-add arr sel-addobj (str2ns s))) items)
               (arr-count arr))))
  (ns/call "native one-call (joined+split)" M
           (lambda ()
             (let ([arr (strs->arr "a\nb\nc\nd\ne\nf\ng\nh")])
               (arr-count arr))))
  ;; char** batch: chez marshals each element to a C string into a void* array,
  ;; then ONE crossing builds the NSArray (the realistic native batch path).
  (ns/call "native char** batch (marshal+1 call)" M
           (lambda ()
             (let* ([n (length items)]
                    [vec (foreign-alloc (* 8 n))]
                    [cstrs (map (lambda (s)
                                  (let* ([bv (string->utf8 (string-append s "\x0;"))]
                                         [p (foreign-alloc (bytevector-length bv))])
                                    (let loop ([i 0])
                                      (when (< i (bytevector-length bv))
                                        (foreign-set! 'unsigned-8 p i (bytevector-u8-ref bv i))
                                        (loop (+ i 1))))
                                    p))
                                items)])
               (let loop ([i 0] [ps cstrs])
                 (unless (null? ps)
                   (foreign-set! 'void* vec (* 8 i) (car ps))
                   (loop (+ i 1) (cdr ps))))
               (let ([arr (strs->arr2 vec n)])
                 (arr-count arr)
                 (for-each foreign-free cstrs)
                 (foreign-free vec))))))

(printf "\ndone.\n")
