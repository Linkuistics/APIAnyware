;;;; tests/smoke-lifetime-conditions.lisp — leaf 050/050 done-when smoke.
;;;;
;;;; Run from the repo root:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;        --load generation/targets/sbcl/lib/runtime/tests/smoke-lifetime-conditions.lisp
;;;;
;;;; The enriched IR is gitignored, so `generate --target sbcl` cannot run locally; this
;;;; hand-authors the binding slice it needs in the emitter's EXACT output shape and drives
;;;; it against LIVE, REAL ObjC (NSObject / NSFileManager / NSArray). It proves the three
;;;; done-when items:
;;;;   (1) BACKGROUND-RELEASE (ADR-0036): a wrapped +1, dropped + GC'd, has its finalizer
;;;;       ENQUEUE the raw id OFF-MAIN (retainCount unchanged — no off-main release), and
;;;;       the MAIN-THREAD drain release it exactly once (retainCount falls by one);
;;;;   (2) `with-autorelease-pool` drains on BOTH normal exit AND a signalled non-local
;;;;       exit (the `unwind-protect` guarantee conditions depend on, ADR-0037);
;;;;   (3) an `NSError**` method that FAILS signals `ns:cocoa-error` with populated
;;;;       domain/code/localized-description; `return-nil`/`use-value` restarts work;
;;;;       SUCCESS returns the value with no signal.

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

(aw-load-framework "Foundation")

;;; ===========================================================================
;;; Small raw-msgSend helpers (the smoke's own, mirroring the emitter shape).
;;; ===========================================================================

(defun new-nsobject ()
  "`[[NSObject alloc] init]` — a +1-owned bare NSObject (retainCount 1)."
  (%msgsend-id-0 (%msgsend-id-0 (aw-class "NSObject") (aw-sel "alloc")) (aw-sel "init")))

(defun retain-count (id-sap)
  "`-retainCount` (NSUInteger). Reliable for a plain NSObject (not tagged / a singleton)."
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:unsigned-long
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   id-sap (aw-sel "retainCount")))

(defun queue-has (id-int)
  "Locked membership test (the finalizer thread may be pushing concurrently)."
  (sb-thread:with-mutex (*release-queue-lock*)
    (and (member id-int *release-queue*) t)))

(defun queue-empty-p ()
  (sb-thread:with-mutex (*release-queue-lock*) (null *release-queue*)))

;;; ===========================================================================
;;; (1) Background release — finalizer enqueues off-main; main drain releases once.
;;;
;;; TEST NOTE — `sb-sys:scrub-control-stack` (verified first-hand on 2.6.5): a wrapper
;;; that `aw-wrap` RETURNS lingers in a caller register/stack slot, so a tight
;;; "create → drop → GC" loop won't collect it (a real app holds the wrapper in a scope
;;; that ends well before GC, so this is a test-measurement artifact, NOT a runtime
;;; leak). Scrubbing the control stack before each GC clears those stale references and
;;; makes finalization deterministic — the standard SBCL idiom for finalizer tests.
;;; ===========================================================================

;; Make a +1 NSObject, take a GUARD retain (so retainCount stays readable after the
;; drain frees the wrap's +1), wrap it at +1 (arms the finalizer), and DROP the wrap —
;; binding it in a `let` whose scope ends + clearing the slot, so nothing lexical survives.
(defun make-and-drop-wrapped ()
  "Return the raw id int of a +1 NSObject whose wrap was armed + immediately dropped."
  (let ((id (new-nsobject)))                  ; retainCount 1 (the +1 we hand the wrap)
    (%objc-retain id)                         ; guard retain -> retainCount 2
    (let ((w (aw-wrap id t)))                 ; wrap TAKES the +1; finalizer armed
      (setf w nil))                           ; ... drop it; clear the slot
    (sb-sys:sap-int id)))

(defun gc-until (predicate)
  "GC (scrubbing the stack first) until PREDICATE or a generous bound; return its value."
  (loop repeat 400 thereis (funcall predicate)
        do (sb-sys:scrub-control-stack) (sb-ext:gc :full t) (sleep 0.003)))

;; (a) finalizers run OFF the main thread (ADR-0036's premise) — a throwaway probe
;; records the thread its finalizer runs on.
(defvar *finalizer-thread-name* :never-ran)
(let ((o (list :off-main-probe)))
  (sb-ext:finalize o (lambda ()
                       (setf *finalizer-thread-name*
                             (sb-thread:thread-name sb-thread:*current-thread*)))
                   :dont-save t))
(gc-until (lambda () (not (eq *finalizer-thread-name* :never-ran))))
(check (not (eq *finalizer-thread-name* :never-ran)) t)                  ; the finalizer ran
(check (equal *finalizer-thread-name*
              (sb-thread:thread-name sb-thread:*current-thread*)) nil)   ; ... and OFF main

;; (b) measured: a +1 wrap, dropped + GC'd, has its raw id ENQUEUED (no release) by the
;; finalizer and then RELEASED exactly once by the main-thread drain.
(let ((id-int (make-and-drop-wrapped)))
  (gc-until (lambda () (queue-has id-int)))
  (check (queue-has id-int) t)                                  ; finalizer enqueued the id
  (check (retain-count (sb-sys:int-sap id-int)) 2)             ; ... and did NOT release it
  (let ((n (with-autorelease-pool (aw-drain-release-queue))))  ; MAIN-THREAD drain releases
    (check (>= n 1) t))
  (check (retain-count (sb-sys:int-sap id-int)) 1)             ; drained exactly the wrap's +1
  (check (queue-empty-p) t)                                    ; queue cleared
  (%objc-release (sb-sys:int-sap id-int)))                     ; drop the guard -> dealloc

;;; ===========================================================================
;;; (2) with-autorelease-pool drains on normal AND signalled non-local exit.
;;; ===========================================================================

;; normal exit: a queued +1 is released by the pool boundary; multiple values preserved
(let ((id (new-nsobject)))
  (aw-enqueue-release (sb-sys:sap-int id))
  (multiple-value-bind (a b) (with-autorelease-pool (values :x :y))
    (check a :x)
    (check b :y))
  (check (queue-empty-p) t))                  ; drained on NORMAL exit

;; signalled non-local exit: the pool still drains (unwind-protect), the condition is caught
(let ((id (new-nsobject)))
  (aw-enqueue-release (sb-sys:sap-int id))
  (check (handler-case (with-autorelease-pool (error 'ns:objc-error))
           (ns:objc-error () :caught))
         :caught)
  (check (queue-empty-p) t))                  ; drained on the SIGNALLED exit too

;;; ===========================================================================
;;; (3) NSError** -> ns:cocoa-error (the conditions surface).
;;; ===========================================================================

(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("NS-FILE-MANAGER" "NS-ARRAY" "DEFAULT-MANAGER"
               "CONTENTS-OF-DIRECTORY-AT-PATH-ERROR"))
    (export (intern n '#:ns) '#:ns)))

(defclass ns:ns-file-manager (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-file-manager "NSFileManager" "NSObject")
(defclass ns:ns-array (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-array "NSArray" "NSObject")

;; class method `+[NSFileManager defaultManager]` (a +0 singleton — no finalizer)
(defgeneric ns:default-manager (class))
(defmethod ns:default-manager ((class (eql (find-class 'ns:ns-file-manager))))
  (declare (ignore class))
  (aw-wrap (%msgsend-id-0 (aw-class "NSFileManager") (aw-sel "defaultManager"))))

;; `-[NSFileManager contentsOfDirectoryAtPath:error:]` — the emitter shape for an
;; NSError**-bearing object-returning method: `aw-with-error-cell` binds `%err`, the
;; dispatch threads it as the trailing id*, and a nil primary return signals.
(defgeneric ns:contents-of-directory-at-path-error (receiver path))
(defmethod ns:contents-of-directory-at-path-error ((self ns:ns-file-manager) path)
  (aw-with-error-cell (%err)
    (aw-wrap (sb-alien:alien-funcall
              (sb-alien:sap-alien +objc-msgsend+
                                  (sb-alien:function sb-alien:system-area-pointer
                                                     sb-alien:system-area-pointer
                                                     sb-alien:system-area-pointer
                                                     sb-alien:system-area-pointer
                                                     sb-alien:system-area-pointer))
              (aw-ptr self) (aw-sel "contentsOfDirectoryAtPath:error:")
              (aw-make-nsstring path) %err))))

(with-autorelease-pool                        ; a pool so the autoreleased NSErrors drain cleanly
  (let ((fm (ns:default-manager (find-class 'ns:ns-file-manager))))
    (check (typep fm 'ns:ns-file-manager) t)

    ;; FAILURE -> signals ns:cocoa-error with populated, eagerly-read fields
    (check (handler-case
               (progn (ns:contents-of-directory-at-path-error fm "/no/such/aw-xyz")
                      :unexpectedly-returned)
             (ns:cocoa-error (e)
               (list (ns:domain e) (integerp (ns:code e)) (and (ns:localized-description e) t))))
           (list "NSCocoaErrorDomain" t t))

    ;; return-nil restart -> the failed call yields nil
    (check (handler-bind ((ns:cocoa-error (lambda (c) (declare (ignore c))
                                            (invoke-restart 'return-nil))))
             (ns:contents-of-directory-at-path-error fm "/no/such/aw-xyz"))
           nil)

    ;; use-value restart -> the failed call yields the supplied substitute
    (check (handler-bind ((ns:cocoa-error (lambda (c) (declare (ignore c))
                                            (invoke-restart 'use-value :substituted))))
             (ns:contents-of-directory-at-path-error fm "/no/such/aw-xyz"))
           :substituted)

    ;; SUCCESS -> a wrapped NSArray, NO signal
    (let ((result (handler-case (ns:contents-of-directory-at-path-error fm "/tmp")
                    (ns:cocoa-error () :unexpected-signal))))
      (check (typep result 'ns:ns-array) t))))

;;; ===========================================================================
(if (zerop *fails*)
    (format t "~&### SMOKE PASS — all checks green~%")
    (format t "~&### SMOKE FAIL — ~A check(s) failed~%" *fails*))
(sb-ext:exit :code (if (zerop *fails*) 0 1))
