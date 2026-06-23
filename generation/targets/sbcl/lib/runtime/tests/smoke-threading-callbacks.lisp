;;;; tests/smoke-threading-callbacks.lisp — leaf 050/060 done-when smoke (ADR-0035).
;;;;
;;;; Run from the repo root (compiles the companion C harness with clang itself):
;;;;   sbcl --non-interactive --disable-debugger \
;;;;        --load generation/targets/sbcl/lib/runtime/tests/smoke-threading-callbacks.lisp
;;;;
;;;; The HIGHEST-RISK runtime leaf: it wires the exact mechanism the threading spike
;;;; crashed 5/5 on. So the proof is EMPIRICAL, not by inspection. The four bars:
;;;;
;;;;   (1) REGRESSION GATE — a Lisp `aw-block` fired from 8 CONCURRENT foreign GCD
;;;;       workers (500x each) under GC pressure SURVIVES + runs every invocation ON
;;;;       MAIN + returns its value across the sync bounce. This is the spike's
;;;;       `foreign-concurrent` shape (which crashed 5/5 with a raw callback); the
;;;;       bounce closes it.
;;;;   (2) a REAL framework block API (`-[NSArray enumerateObjectsUsingBlock:]`) runs the
;;;;       Lisp closure end-to-end, args coerced (`aw-wrap`/`sap-int`) — the on-main
;;;;       direct path (enumerate is synchronous on the caller).
;;;;   (3) the NATIVE-worker control — an `sb-thread` runs pure-Lisp compute (the spike's
;;;;       surviving control); `with-background-work` is the safe-worker surface.
;;;;   (4) `aw-on-main` delivers a worker's result onto the main thread.

(in-package #:cl-user)
(defparameter *here* (or *load-truename* *load-pathname*))
(defparameter *repo-root*
  (let ((d (make-pathname :directory (pathname-directory *here*))))
    (dotimes (_ 6 d) (setf d (make-pathname :directory (butlast (pathname-directory d)))))))
(load (merge-pathnames "generation/targets/sbcl/lib/runtime/load.lisp" *repo-root*))

(in-package #:apianyware-sbcl-impl)

(defvar *fails* 0)
(defmacro check (form expected)
  `(let ((got ,form))
     (if (equal got ,expected)
         (format t "### ok    ~S => ~S~%" ',form got)
         (progn (incf *fails*) (format t "### FAIL  ~S => ~S (expected ~S)~%" ',form got ,expected)))))

;;; --- load Foundation + the native dylib, register the block dispatcher ---
(aw-load-framework "Foundation")
(setf *native-dylib-path*
      (namestring (merge-pathnames
                   "swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                   cl-user::*repo-root*)))
(aw-load-native-dylib)
(aw-init-block-dispatcher)

;;; --- compile + load the C storm harness (clang -fblocks, like the threading spike) ---
(defparameter *harness-src*
  (namestring (merge-pathnames
               "generation/targets/sbcl/lib/runtime/tests/smoke-threading-callbacks.c"
               cl-user::*repo-root*)))
(defparameter *harness-dylib* "/tmp/libsbclthreadsmoke.dylib")
(let ((p (sb-ext:run-program
          "clang" (list "-fblocks" "-dynamiclib" "-O2" "-framework" "CoreFoundation"
                        "-o" *harness-dylib* *harness-src*)
          :search t :error *error-output*)))
  (unless (zerop (sb-ext:process-exit-code p))
    (format t "### FAIL: clang could not build the storm harness~%")
    (sb-ext:exit :code 1)))
(sb-alien:load-shared-object *harness-dylib*)

(sb-alien:define-alien-routine ("aw_sbcl_smoke_block_storm" aw-smoke-block-storm)
    sb-alien:long
  (block sb-alien:system-area-pointer)
  (outer sb-alien:long)
  (inner sb-alien:long))
(sb-alien:define-alien-routine ("aw_sbcl_smoke_pump" aw-smoke-pump) sb-alien:void
  (seconds sb-alien:double))
(sb-alien:define-alien-routine ("aw_sbcl_smoke_is_main" aw-smoke-is-main) sb-alien:int)

;; identical consing work in every Lisp callback — generates the heap pressure that
;; makes GC fire (the spike's `do-cons-work`).
(declaim (inline do-cons-work))
(defun do-cons-work ()
  (let ((s 0))
    (declare (fixnum s))
    (dolist (x (loop for i fixnum from 0 below 64 collect i)) (incf s x))
    s))

;;; ===========================================================================
;;; (1) THE REGRESSION GATE — concurrent foreign block storm under GC pressure.
;;;     8 workers x 500 invocations; each block call bounces to main, conses, and
;;;     returns (1+ index). The sum proves both survival-under-concurrency AND the
;;;     value crossing the sync bounce. The on-main flag proves NO Lisp ran off-main.
;;; ===========================================================================
(let ((calls 0)
      (off-main nil)
      (stop (list nil)))   ; a shared CONS box — heap state crosses threads (a dynamic
                           ; special binding would NOT: SBCL dynamic bindings are per-thread).
  ;; A value-returning block: runs ON MAIN (the dylib bounced first). a2 = the index.
  (let* ((blk (aw-block
               (lambda (a1 a2 a3)
                 (declare (ignore a1 a3))
                 (unless (= 1 (aw-smoke-is-main)) (setf off-main t))
                 (do-cons-work)                 ; heap pressure, on main
                 (incf calls)
                 (1+ (sb-sys:sap-int a2)))))     ; value returned across the sync bounce
         ;; native pressure threads (suspendable; the foreign workers are NOT, but they
         ;; never run Lisp): a background conser + a stop-the-world forcer.
         (conser (sb-thread:make-thread
                  (lambda () (loop until (car stop) do (do-cons-work)))
                  :name "bg-conser"))
         (forcer (sb-thread:make-thread
                  (lambda () (loop until (car stop) do (sb-ext:gc :full t) (sleep 0.003)))
                  :name "gc-forcer"))
         ;; THE STORM: 8 concurrent GCD foreign workers, 500 calls each (blocks main in
         ;; the run loop, servicing the bounces; returns the summed value).
         (sum (aw-smoke-block-storm blk 8 500)))
    (setf (car stop) t)
    (sb-thread:join-thread conser)
    (sb-thread:join-thread forcer)
    (format t "### storm survived: calls=~D sum=~D off-main=~A~%" calls sum off-main)
    (check calls 4000)                          ; every invocation ran
    (check off-main nil)                        ; ... all of them on the main thread
    (check sum (* 8 (loop for j from 0 below 500 sum (1+ j))))))  ; value crossed: 8*125250

;;; ===========================================================================
;;; (2) A REAL framework block API — `-[NSArray enumerateObjectsUsingBlock:]` runs the
;;;     Lisp closure on main (direct path), with the obj + index args coerced.
;;; ===========================================================================
(let* ((arr (%msgsend-id-0 (aw-class "NSMutableArray") (aw-sel "array"))))
  (dolist (s '("alpha" "beta" "gamma"))
    (%msgsend-id-1 arr (aw-sel "addObject:") (aw-make-nsstring s)))
  (let ((seen '()))
    (let ((blk (aw-block
                (lambda (obj idx stop)
                  (declare (ignore stop))
                  (push (cons (sb-sys:sap-int idx) (nsstring->string obj)) seen)))))
      (%msgsend-id-1 arr (aw-sel "enumerateObjectsUsingBlock:") blk))
    (check (nreverse seen) '((0 . "alpha") (1 . "beta") (2 . "gamma")))))

;;; ===========================================================================
;;; (3) NATIVE-worker control — `with-background-work` runs pure-Lisp compute safely.
;;; ===========================================================================
(let ((box (list nil)))
  (let ((w (with-background-work (:name "control")
             (setf (car box) (let ((s 0)) (dotimes (i 100000 s) (incf s (do-cons-work))))))))
    (sb-thread:join-thread w))
  (check (car box) (* 100000 (do-cons-work))))

;;; ===========================================================================
;;; (4) `aw-on-main` — a native worker delivers a result onto the main thread.
;;; ===========================================================================
(let ((delivered nil) (ran-on-main nil))
  (with-background-work (:name "deliver")
    (sleep 0.05)
    (aw-on-main (lambda ()
                  (setf ran-on-main (= 1 (aw-smoke-is-main)))
                  (setf delivered t))))
  (loop repeat 60 until delivered do (aw-smoke-pump 0.05d0))
  (check delivered t)
  (check ran-on-main t))

(format t "~%### smoke-threading-callbacks: ~A (~D failure~:P)~%"
        (if (zerop *fails*) "PASS" "FAIL") *fails*)
(sb-ext:exit :code (if (zerop *fails*) 0 1))
