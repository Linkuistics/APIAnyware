;;;; tests/smoke-startup-reresolution.lisp — leaf 050/070 done-when smoke.
;;;;
;;;; Run from the repo root (needs SDKROOT=macosx for the live ObjC classes):
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load generation/targets/sbcl/lib/runtime/tests/smoke-startup-reresolution.lisp
;;;;
;;;; Proves the mandatory startup re-resolution pass (ADR-0034 §6 / ADR-0038 §5). The
;;;; correctness invariant is "never reuse a baked pointer": a dumped image keeps the
;;;; baked Lisp metadata but loses every live `Class`/`SEL`/`objc_msgSend` SAP, so the
;;;; pass must re-derive them from baked STRING identity at process start. Coverage:
;;;;
;;;;   (A) IN-PROCESS simulated dump — zero `+objc-msgsend+`/`+objc-msgsend-super+`,
;;;;       clear the SEL/Class caches (exactly the stale state a dump leaves), run the
;;;;       pass, and show the SAME selectors dispatch again. Idempotent (run twice).
;;;;   (B) the opt-in ivar-offset re-resolution hook — a hand-constructed entry over a
;;;;       synthesized class+ivar re-derives a deliberately-wrong baked offset from the
;;;;       live `ivar_getOffset`; the empty table is inert (exercised in A).
;;;;   (C) a GENUINE `save-lisp-and-die` -> relaunch round-trip (sub-process): the
;;;;       revived image relies on the `*init-hooks*`-registered pass alone, then
;;;;       dispatches — the real reason this leaf exists (an in-process test can never
;;;;       re-stale a `dlopen`ed framework; only a fresh process can). It ALSO proves
;;;;       `define-objc-constant` re-resolution (060/pdfkit-viewer-k31): the dump
;;;;       deliberately `setf`s the baked Foundation `NSString` constant to nil, so it
;;;;       can ONLY be non-nil in the revived image if the pass re-ran its value form
;;;;       (a discriminator robust to the dyld shared cache mapping a framework at the
;;;;       same address across processes); the revived constant must match a fresh read.

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

;;; ===========================================================================
;;; A binding slice in the emitter's output shape (cross-checked against
;;; tests/golden), driven against LIVE Foundation classes.
;;; ===========================================================================

(aw-load-framework "Foundation")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("NS-STRING" "LENGTH" "NS-NUMBER" "INT-VALUE" "NUMBER-WITH-INT"))
    (export (intern n '#:ns) '#:ns)))

(defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-string "NSString" "NSObject")
(defclass ns:ns-number (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-number "NSNumber" "NSObject")

(defgeneric ns:length (receiver))
(defmethod ns:length ((self ns:ns-string))
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:unsigned-long
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "length")))

(defgeneric ns:int-value (receiver))
(defmethod ns:int-value ((self ns:ns-number))
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:signed 32)
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "intValue")))

(defgeneric ns:number-with-int (class value))
(defmethod ns:number-with-int ((class (eql (find-class 'ns:ns-number))) value)
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer
                                                 (sb-alien:signed 32)))
            (aw-class "NSNumber") (aw-sel "numberWithInt:") value)))

(defun dispatch-works-p ()
  "Exercise the re-resolved seam: a String length + a class-method-built number's value.
   Touches `+objc-msgsend+`, `aw-class`, `aw-sel`, and the Class/SEL caches."
  (and (eql 5 (ns:length (aw-wrap (aw-make-nsstring "hello") t)))
       (eql 42 (ns:int-value (ns:number-with-int (find-class 'ns:ns-number) 42)))))

;;; ===========================================================================
;;; (A) In-process simulated dump: stale the seam, run the pass, dispatch again.
;;; ===========================================================================

(format t "~%### --- (A) in-process simulated-dump re-resolution ---~%")
(check (dispatch-works-p) t)                       ; baseline (live, pre-stale)

;; Stale EXACTLY what a save-lisp-and-die leaves stale: zero the dispatch SAPs + drop
;; the per-process Class/SEL caches. (We cannot un-`dlopen` Foundation in-process — that
;; is what (C) proves — so this isolates the SAP + cache half of the pass.)
(let ((live-msgsend (sb-sys:foreign-symbol-sap "objc_msgSend")))
  (setf +objc-msgsend+ (sb-sys:int-sap 0)
        +objc-msgsend-super+ (sb-sys:int-sap 0))
  (clrhash *sel-cache*)
  (clrhash *class-cache*)
  (check (aw-null-sap-p +objc-msgsend+) t)         ; the seam is now broken...
  (check (hash-table-count *class-cache*) 0)

  (aw-startup-reresolve)                           ; ...and the pass repairs it.

  (check (aw-null-sap-p +objc-msgsend+) nil)
  (check (sb-sys:sap= +objc-msgsend+ live-msgsend) t)              ; re-resolved to the live symbol
  (check (sb-sys:sap= +objc-msgsend-super+
                      (sb-sys:foreign-symbol-sap "objc_msgSendSuper")) t)
  ;; the registered Class graph is back in the cache (eager re-resolution)
  (check (and (gethash "NSString" *class-cache*) t) t)
  (check (and (gethash "NSNumber" *class-cache*) t) t)
  ;; the metaclass `class-sap` slot 030 reads is repopulated too
  (check (sb-sys:sap= (objc-class-cached-sap (find-class 'ns:ns-string))
                      (aw-class "NSString")) t)
  (check (dispatch-works-p) t))                    ; the same selectors dispatch again

;; idempotent: a second pass is harmless and dispatch still works
(aw-startup-reresolve)
(aw-startup-reresolve)
(check (dispatch-works-p) t)

;;; ===========================================================================
;;; (B) The opt-in ivar-offset re-resolution hook (ADR-0034 §4 / §8).
;;; Empty-table inertness is already exercised by every pass in (A) (the table is
;;; empty there). Here: synthesize a real ObjC class with one int ivar, register a
;;; foreign slot carrying a DELIBERATELY WRONG baked offset, and prove the pass
;;; re-derives the true offset from the live `ivar_getOffset`.
;;; ===========================================================================

(format t "~%### --- (B) ivar-offset re-resolution hook ---~%")

(sb-alien:define-alien-routine ("class_addIvar" %class-add-ivar) sb-alien:char
  (cls sb-alien:system-area-pointer) (name sb-alien:c-string)
  (size sb-alien:size-t) (alignment sb-alien:unsigned-char) (types sb-alien:c-string))

;; Build "AwIvarProbe : NSObject" with a 4-byte int ivar "counter".
(let ((pair (%objc-allocate-class-pair (aw-class "NSObject") "AwIvarProbe" 0)))
  (check (aw-null-sap-p pair) nil)
  (check (/= 0 (%class-add-ivar pair "counter" 4 2 "i")) t)   ; alignment = log2(4) = 2
  (%objc-register-class-pair pair))

;; A CLOS probe whose foreign slot carries a wrong offset (999 bits), so re-resolution
;; is observable. `finalize-inheritance` computes the effective slot we re-derive into.
(defclass ivar-probe (ns:ns-object)
  ((counter :offset 999 :ctype :int))
  (:metaclass objc-class))
(sb-mop:finalize-inheritance (find-class 'ivar-probe))
(defparameter *probe-eslot*
  (find 'counter (sb-mop:class-slots (find-class 'ivar-probe))
        :key #'sb-mop:slot-definition-name))

(defparameter *true-offset-bits*
  (* 8 (%ivar-get-offset (%class-get-instance-variable (aw-class "AwIvarProbe") "counter"))))

(check (slot-offset *probe-eslot*) 999)            ; the wrong baked offset, pre-pass
(register-ivar-reresolve "AwIvarProbe" "counter" *probe-eslot*)
(aw-startup-reresolve)                             ; re-derives via ivar_getOffset
(check (slot-offset *probe-eslot*) *true-offset-bits*)   ; corrected to the live offset
(check (/= (slot-offset *probe-eslot*) 999) t)     ; and genuinely changed

;; an entry whose class/ivar is unresolvable is skipped, never fatal (safe-default path)
(register-ivar-reresolve "NoSuchClass" "nope" *probe-eslot*)
(check (progn (aw-reresolve-ivar-offsets) t) t)    ; runs clean; offset stays correct
(check (slot-offset *probe-eslot*) *true-offset-bits*)

;;; ===========================================================================
;;; (C) The genuine save-lisp-and-die -> relaunch round-trip (sub-process).
;;; ===========================================================================

(format t "~%### --- (C) genuine save-lisp-and-die round-trip ---~%")

;; A clean DIRECTORY pathname (built from `*here*`'s directory, NOT merged onto the
;; file pathname — that would inherit the .lisp name/type and mis-target cleanup).
(defparameter *tmp*
  (make-pathname :directory (append (pathname-directory cl-user::*here*) '("_roundtrip-tmp"))))
(ensure-directories-exist *tmp*)
(defparameter *core* (namestring (merge-pathnames "image.core" *tmp*)))
(defparameter *dump-lisp* (namestring (merge-pathnames "dump.lisp" *tmp*)))
(defparameter *revive-lisp* (namestring (merge-pathnames "revive.lisp" *tmp*)))

;; The dump image loads the FULL runtime, binds a live NSString length method, then
;; dumps. Crucially it does NOT instantiate anything (no finalizer thread spawned) so
;; the single-thread `save-lisp-and-die` precondition holds. Its `+objc-msgsend+` + the
;; NSString `Class` SAP are baked STALE into the core.
(with-open-file (s *dump-lisp* :direction :output :if-exists :supersede)
  (format s "(in-package :cl-user)~%~
             (load ~S)~%~
             (in-package #:apianyware-sbcl-impl)~%~
             (aw-load-framework \"Foundation\")~%~
             (eval-when (:compile-toplevel :load-toplevel :execute)~%~
               (export (intern \"NS-STRING\" '#:ns) '#:ns)~%~
               (export (intern \"LENGTH\" '#:ns) '#:ns))~%~
             (defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))~%~
             (register-objc-class 'ns:ns-string \"NSString\" \"NSObject\")~%~
             (defgeneric ns:length (r))~%~
             (defmethod ns:length ((self ns:ns-string))~%~
               (sb-alien:alien-funcall~%~
                (sb-alien:sap-alien +objc-msgsend+~%~
                  (sb-alien:function sb-alien:unsigned-long~%~
                    sb-alien:system-area-pointer sb-alien:system-area-pointer))~%~
                (aw-ptr self) (aw-sel \"length\")))~%~
             (define-objc-constant *rt-const*~%~
               (aw-wrap (sb-alien:extern-alien \"NSLocalizedDescriptionKey\"~%~
                          sb-alien:system-area-pointer)))~%~
             (setf *rt-const* nil)~%~
             (sb-ext:save-lisp-and-die ~S)~%"
          (namestring (merge-pathnames "generation/targets/sbcl/lib/runtime/load.lisp" cl-user::*repo-root*))
          *core*))

;; The revived image does NOT call the pass — it relies on the `*init-hooks*` entry
;; firing at startup (the production path). It first proves the pass actually ran (the
;; baked-stale SAP was re-resolved to the live symbol) then dispatches `-length`.
(with-open-file (s *revive-lisp* :direction :output :if-exists :supersede)
  (format s "(in-package #:apianyware-sbcl-impl)~%~
             (let ((live (sb-sys:foreign-symbol-sap \"objc_msgSend\")))~%~
               (if (and (not (aw-null-sap-p +objc-msgsend+))~%~
                        (sb-sys:sap= +objc-msgsend+ live)~%~
                        (= 5 (ns:length (aw-wrap (aw-make-nsstring \"hello\") t))))~%~
                   (format t \"### ROUNDTRIP OK~~%\")~%~
                   (format t \"### ROUNDTRIP FAIL~~%\")))~%~
             (let ((fresh (aw-wrap (sb-alien:extern-alien \"NSLocalizedDescriptionKey\"~%~
                                     sb-alien:system-area-pointer))))~%~
               (if (and *rt-const* fresh~%~
                        (plusp (ns:length *rt-const*))~%~
                        (= (ns:length *rt-const*) (ns:length fresh)))~%~
                   (format t \"### CONST OK~~%\")~%~
                   (format t \"### CONST FAIL~~%\")))~%~
             (sb-ext:exit)~%"))

(flet ((run (args)
         (let ((p (sb-ext:run-program "sbcl" args :search t
                                      :output :stream :error :output :wait t)))
           (values (with-output-to-string (o)
                     (loop for line = (read-line (sb-ext:process-output p) nil)
                           while line do (write-line line o)))
                   (sb-ext:process-exit-code p)))))
  ;; dump (quiet; just needs exit 0 + a core on disk)
  (multiple-value-bind (out code)
      (run (list "--non-interactive" "--no-sysinit" "--no-userinit" "--disable-debugger"
                 "--load" *dump-lisp*))
    (declare (ignore out))
    (check code 0)
    (check (and (probe-file *core*) t) t))
  ;; relaunch from the dumped core; the init-hook re-resolves before --load runs
  (multiple-value-bind (out code)
      (run (list "--core" *core* "--non-interactive" "--no-sysinit" "--no-userinit"
                 "--disable-debugger" "--load" *revive-lisp*))
    (format t "~A" out)
    (check code 0)
    (check (and (search "ROUNDTRIP OK" out) t) t)
    (check (and (search "CONST OK" out) t) t)))   ; define-objc-constant re-resolved post-revive

;; tidy up the sub-process artifacts (recursive — an "rm -rf" of the scratch dir)
(ignore-errors (sb-ext:delete-directory *tmp* :recursive t))

;;; ===========================================================================
(format t "~%")
(if (zerop *fails*)
    (format t "### SMOKE PASS — all checks green~%")
    (format t "### SMOKE FAIL — ~A check(s) failed~%" *fails*))
(sb-ext:exit :code (if (zerop *fails*) 0 1))
