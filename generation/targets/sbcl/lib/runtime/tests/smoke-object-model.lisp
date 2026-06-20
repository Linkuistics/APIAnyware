;;;; tests/smoke-object-model.lisp — leaf 050/030 done-when smoke (the MOP headline).
;;;;
;;;; Run from the repo root:
;;;;   sbcl --non-interactive --disable-debugger \
;;;;        --load generation/targets/sbcl/lib/runtime/tests/smoke-object-model.lisp
;;;;
;;;; The enriched IR is gitignored, so `generate --target sbcl` cannot run locally for a
;;;; real framework. Instead this hand-authors a small binding slice in the emitter's
;;;; EXACT output shape (cross-checked against tests/golden/testkit/*.lisp — `defclass …
;;;; (:metaclass objc-class)`, `register-objc-class`, `defgeneric`, and the
;;;; `(alien-funcall (sap-alien +objc-msgsend+ (function …)) (aw-ptr self) (aw-sel …) …)`
;;;; dispatch body) — but drives it against LIVE, REAL ObjC classes (NSString / NSArray /
;;;; NSMutableArray / NSNumber). It proves the runtime MECHANISM the done-when names:
;;;;   - metaclass + root load; `validate-superclass` accepts a bound `defclass`;
;;;;   - `make-instance` (alloc/init); dispatch via emitted generics; a value read back;
;;;;   - inherited dispatch + `call-next-method` up the reified chain;
;;;;   - class methods (receiver-specialized on the class metaobject);
;;;;   - covariant return wraps to the EXACT bound class (class-cluster superclass walk);
;;;;   - the foreign-slot mechanism (hand-built `:offset`/`:ctype`); empty-table inert.

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
;;; A hand-authored binding slice in the emitter's output shape.
;;; ===========================================================================
(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("NS-STRING" "NS-ARRAY" "NS-MUTABLE-ARRAY" "NS-NUMBER"
               "LENGTH" "UPPERCASE-STRING" "COUNT" "OBJECT-AT-INDEX" "ADD-OBJECT"
               "INT-VALUE" "NUMBER-WITH-INT" "ARRAY" "SELF" "TAGGED-COUNT"))
    (export (intern n '#:ns) '#:ns)))

;; --- classes (the metaclass-backed graph) + the baked Class string table ---
(defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-string "NSString" "NSObject")
(defclass ns:ns-array (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-array "NSArray" "NSObject")
(defclass ns:ns-mutable-array (ns:ns-array) () (:metaclass objc-class))
(register-objc-class 'ns:ns-mutable-array "NSMutableArray" "NSArray")
(defclass ns:ns-number (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-number "NSNumber" "NSObject")

;; --- generics + dispatch (one defgeneric per selector; defmethod per class×selector) ---
(defgeneric ns:length (receiver))
(defmethod ns:length ((self ns:ns-string))
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:unsigned-long
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "length")))

(defgeneric ns:uppercase-string (receiver))
(defmethod ns:uppercase-string ((self ns:ns-string))   ; covariant: returns an NSString
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer))
            (aw-ptr self) (aw-sel "uppercaseString"))))

(defgeneric ns:count (receiver))
(defmethod ns:count ((self ns:ns-array))               ; inherited by ns:ns-mutable-array
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:unsigned-long
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "count")))

(defgeneric ns:object-at-index (receiver index))
(defmethod ns:object-at-index ((self ns:ns-array) index)
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer
                                                 sb-alien:unsigned-long))
            (aw-ptr self) (aw-sel "objectAtIndex:") index)))

(defgeneric ns:add-object (receiver obj))
(defmethod ns:add-object ((self ns:ns-mutable-array) obj)
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer
                                        sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "addObject:") (aw-ptr obj)))

(defgeneric ns:int-value (receiver))
(defmethod ns:int-value ((self ns:ns-number))
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:signed 32)
                                        sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr self) (aw-sel "intValue")))

(defgeneric ns:self (receiver))
(defmethod ns:self ((self ns:ns-object))               ; on the root: every class inherits
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer))
            (aw-ptr self) (aw-sel "self"))))

;; class methods — receiver-specialized on the class metaobject (node BRIEF, the body's
;; receiver is the literal `(aw-class "<ObjCName>")`; the `class` formal is ignored).
(defgeneric ns:array (class))
(defmethod ns:array ((class (eql (find-class 'ns:ns-mutable-array))))
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer))
            (aw-class "NSMutableArray") (aw-sel "array"))))

(defgeneric ns:number-with-int (class value))
(defmethod ns:number-with-int ((class (eql (find-class 'ns:ns-number))) value)
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer sb-alien:system-area-pointer
                                                 (sb-alien:signed 32)))
            (aw-class "NSNumber") (aw-sel "numberWithInt:") value)))

;; a synthetic generic whose ns-mutable-array override calls call-next-method up the
;; reified chain, so the +1000 makes the super-reach OBSERVABLE (pure CLOS combination
;; over the objc-class graph — the mechanism the done-when's call-next-method tests).
(defgeneric ns:tagged-count (receiver))
(defmethod ns:tagged-count ((self ns:ns-array)) (ns:count self))
(defmethod ns:tagged-count ((self ns:ns-mutable-array)) (+ 1000 (call-next-method)))

;;; ===========================================================================
;;; Exercise it.
;;; ===========================================================================

;; (1) metaclass + root + validate-superclass: the reified chain is real
(check (typep (find-class 'ns:ns-mutable-array) 'objc-class) t)
(check (subtypep 'ns:ns-mutable-array 'ns:ns-array) t)
(check (subtypep 'ns:ns-array 'ns:ns-object) t)

;; (2) make-instance (alloc/init) of a real class + dispatch + read-back
(let* ((arr (make-instance 'ns:ns-mutable-array))           ; alloc/init -> empty NSMutableArray
       (n42 (ns:number-with-int (find-class 'ns:ns-number) 42))   ; class method
       (n7  (ns:number-with-int (find-class 'ns:ns-number) 7)))
  (check (class-of arr) (find-class 'ns:ns-mutable-array))
  (check (ns:count arr) 0)
  (ns:add-object arr n42)
  (ns:add-object arr n7)
  (check (ns:count arr) 2)                                  ; inherited ns-array dispatch
  (check (ns:int-value (ns:object-at-index arr 0)) 42)      ; covariant wrap -> ns-number
  (check (class-of (ns:object-at-index arr 0)) (find-class 'ns:ns-number))
  ;; (3) call-next-method up the chain: 1000 + (count = 2) = 1002
  (check (ns:tagged-count arr) 1002)
  ;; (4) covariant return wraps to the EXACT bound class (cluster superclass walk)
  (check (class-of (ns:self arr)) (find-class 'ns:ns-mutable-array)))

;; (5) string slice: alloc/init empty string + a real method via the bridge
(let* ((s (aw-wrap (aw-make-nsstring "héllo") t)))          ; wrap a real NSString
  (check (class-of s) (find-class 'ns:ns-string))           ; exact class (covariant)
  (check (ns:length s) 5)
  (check (nsstring->string (aw-ptr (ns:uppercase-string s))) "HÉLLO"))

;; (6) foreign-slot mechanism (spike-3 shape) over a malloc'd buffer
(defclass foreign-probe (ns:ns-object)
  ((counter :offset 0  :ctype :int)
   (scale   :offset 64 :ctype :double))
  (:metaclass objc-class))
(sb-alien:define-alien-routine ("malloc" %malloc) sb-alien:system-area-pointer (n sb-alien:size-t))
(let* ((buf (%malloc 128))
       (inst (make-instance 'foreign-probe :ptr buf)))
  (setf (sb-sys:sap-ref-32 buf 0) 4242)
  (setf (sb-sys:sap-ref-double buf 8) 3.5d0)
  (check (slot-value inst 'counter) 4242)                   ; foreign read at offset 0
  (check (slot-value inst 'scale) 3.5d0)                    ; foreign read at offset 64 bits
  (setf (slot-value inst 'counter) 99)
  (check (sb-sys:sap-ref-32 buf 0) 99))                     ; foreign write reflected raw

;; empty-table path: ns:ns-string has NO foreign slots — its `ptr` reads as a plain slot
(let ((s (aw-wrap (aw-make-nsstring "x") t)))
  (check (sb-sys:sap= (slot-value s 'ptr) (aw-ptr s)) t))

(if (zerop *fails*)
    (format t "~&### SMOKE PASS — all checks green~%")
    (format t "~&### SMOKE FAIL — ~A check(s) failed~%" *fails*))
(sb-ext:exit :code (if (zerop *fails*) 0 1))
