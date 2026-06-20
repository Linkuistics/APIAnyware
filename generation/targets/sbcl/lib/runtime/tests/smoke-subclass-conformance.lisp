;;;; tests/smoke-subclass-conformance.lisp — leaf 050/040 done-when smoke.
;;;;
;;;; Run from the repo root:
;;;;   sbcl --non-interactive --disable-debugger \
;;;;        --load generation/targets/sbcl/lib/runtime/tests/smoke-subclass-conformance.lisp
;;;;
;;;; The enriched IR is gitignored, so `generate --target sbcl` cannot run locally; this
;;;; hand-authors the contract macros (`define-objc-subclass` / `define-objc-method`) the
;;;; way an app would write them and drives them against LIVE Foundation. It proves the
;;;; three done-when bars:
;;;;   (1) `define-objc-subclass` + `define-objc-method` synthesize a REAL ObjC class
;;;;       (objc_getClass finds it; class_getSuperclass is right) and sending the
;;;;       overridden selector runs the Lisp method (the value crosses back);
;;;;   (2) a FRAMEWORK calls back into an installed IMP — NSNotificationCenter posts a
;;;;       notification synchronously; the observer's Lisp method runs ON THE MAIN THREAD;
;;;;   (3) `class_addProtocol` conformance — a synthesized class conforms to NSCopying,
;;;;       `class_conformsToProtocol` is true, and the `protocol_*`-derived encoding
;;;;       installs so `copyWithZone:` routes into Lisp.

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

;;; --- load Foundation + the native dylib, register the forwarding dispatcher ---
(aw-load-framework "Foundation")
(setf *native-dylib-path*
      (namestring (merge-pathnames
                   "swift/.build/arm64-apple-macosx/debug/libAPIAnywareSbcl.dylib"
                   cl-user::*repo-root*)))
(aw-load-native-dylib)
(aw-init-subclass-dispatcher)

;; A tiny libobjc/Foundation slice the test drives directly (the emitter would emit
;; these as bound classes; hand-rolled here so the smoke is self-contained).
(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("NS-STRING")) (export (intern n '#:ns) '#:ns)))
(defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-string "NSString" "NSObject")

;; raw objc_msgSend helper for the test's own framework calls (id, SEL [, id]).
(defun send0 (recv sel) (%msgsend-id-0 recv (aw-sel sel)))
(defun send1 (recv sel arg) (%msgsend-id-1 recv (aw-sel sel) arg))

;;; ===========================================================================
;;; (1) Subclass synthesis + a method override that returns a value.
;;;     AwGreeter : NSObject, overriding -description (inherited; encoding @@:) to
;;;     return a Lisp-built NSString.
;;; ===========================================================================
(define-objc-subclass aw-greeter (ns:ns-object)
  (:slots (who :initarg :who :initform "world" :accessor greeter-who)))

(define-objc-method (aw-greeter "description") ((self aw-greeter))
  (aw-wrap (aw-make-nsstring (format nil "hello, ~A" (greeter-who self))) t))

;; the synthesized ObjC class is real + correctly parented
(let ((objc-name (objc-class-name-string (find-class 'aw-greeter))))
  (format t "### synthesized ObjC name = ~S~%" objc-name)
  (check (aw-null-sap-p (%objc-get-class objc-name)) nil)            ; runtime finds it
  (check (sb-sys:sap= (%class-get-superclass (aw-class objc-name))   ; super is NSObject
                      (aw-class "NSObject")) t))

;; instantiate + send the overridden selector -> the Lisp method runs, value crosses back
(let* ((g (make-instance 'aw-greeter :who "clos"))
       (desc (send0 (aw-ptr g) "description")))    ; [g description] -> forwards to Lisp
  (check (typep g 'aw-greeter) t)
  (check (nsstring->string desc) "hello, clos"))

;; default :who too (a second instance with its own Lisp slot state)
(let* ((g2 (make-instance 'aw-greeter))
       (desc (send0 (aw-ptr g2) "description")))
  (check (nsstring->string desc) "hello, world"))

;;; ===========================================================================
;;; (2) A FRAMEWORK callback into an installed IMP, on the main thread.
;;;     AwObserver : NSObject with a brand-new selector handleNote: (encoding
;;;     synthesized v@:@). Register with NSNotificationCenter; postNotificationName:
;;;     dispatches the selector SYNCHRONOUSLY into the Lisp method.
;;; ===========================================================================
(defvar *note-fired* nil)
(defvar *note-on-main* nil)
(defvar *note-name-seen* nil)

(sb-alien:define-alien-routine ("aw_sbcl_is_main_thread" %is-main-thread) sb-alien:int)

(define-objc-subclass aw-observer (ns:ns-object)
  (:slots (tag :initarg :tag :initform :unset :accessor observer-tag)))

(define-objc-method (aw-observer "handleNote:") ((self aw-observer) note)
  (setf *note-fired* (observer-tag self)
        *note-on-main* (= 1 (%is-main-thread))
        ;; read the NSNotification arg back out — proves the id arg marshalled
        *note-name-seen* (nsstring->string (send0 (aw-ptr note) "name"))))

(let* ((observer (make-instance 'aw-observer :tag :greeted))
       (center (send0 (aw-class "NSNotificationCenter") "defaultCenter"))
       (note-name (aw-make-nsstring "AwSbclTestNote")))
  ;; [center addObserver:observer selector:@selector(handleNote:) name:@"…" object:nil]
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:void
                                          sb-alien:system-area-pointer sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer sb-alien:system-area-pointer))
   center (aw-sel "addObserver:selector:name:object:")
   (aw-ptr observer) (aw-sel "handleNote:") note-name (aw-null-sap))
  ;; [center postNotificationName:@"…" object:nil] — synchronous; fires handleNote:
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:void
                                          sb-alien:system-area-pointer sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer sb-alien:system-area-pointer))
   center (aw-sel "postNotificationName:object:") note-name (aw-null-sap))
  (send1 center "removeObserver:" (aw-ptr observer)))

(check *note-fired* :greeted)        ; the framework dispatched into Lisp
(check *note-on-main* t)             ; ADR-0035: the bounce delivered it on main
(check *note-name-seen* "AwSbclTestNote")   ; the id arg marshalled correctly

;;; ===========================================================================
;;; (3) Protocol conformance — AwCopyable : NSObject <NSCopying>.
;;;     class_addProtocol makes class_conformsToProtocol true; the live
;;;     protocol_*-derived encoding installs so [obj copyWithZone:nil] routes to Lisp.
;;; ===========================================================================
(defvar *copied* nil)

(define-objc-subclass aw-copyable (ns:ns-object)
  (:slots (label :initarg :label :initform "orig" :accessor copyable-label))
  (:protocols "NSCopying"))

(define-objc-method (aw-copyable "copyWithZone:") ((self aw-copyable) zone)
  (declare (ignore zone))
  (setf *copied* t)
  ;; return a fresh AwCopyable carrying a derived label (its own +1 id)
  (aw-ptr (make-instance 'aw-copyable :label (format nil "copy-of-~A" (copyable-label self)))))

(let* ((obj (make-instance 'aw-copyable :label "x"))
       (proto (%objc-get-protocol "NSCopying"))
       (cls (aw-class (objc-class-name-string (find-class 'aw-copyable)))))
  (check (/= 0 (%class-conforms-to-protocol cls proto)) t)   ; conformance declared
  ;; [obj copyWithZone:nil] -> forwards into the Lisp copyWithZone:
  (let* ((copy-id (send1 (aw-ptr obj) "copyWithZone:" (aw-null-sap)))
         (copy (aw-wrap copy-id)))
    (check *copied* t)
    (check (typep copy 'aw-copyable) t)
    (check (copyable-label copy) "copy-of-x")))

;;; --- super-dispatch: call-super-id reaches the framework's -description -------
;;; AwSuperDemo overrides -description but chains to NSObject's via call-super-id
;;; (objc_msgSendSuper, recursion-safe) and appends to it.
(define-objc-subclass aw-super-demo (ns:ns-object) ())
(define-objc-method (aw-super-demo "description") ((self aw-super-demo))
  (let ((inherited (call-super-id self "description")))   ; NSObject's "<AW_SBCL_…: 0x…>"
    (aw-wrap (aw-make-nsstring
              (format nil "wrapped[~A]" (nsstring->string (aw-ptr inherited)))) t)))

(let* ((d (make-instance 'aw-super-demo))
       (desc (nsstring->string (send0 (aw-ptr d) "description"))))
  (format t "### super-chained description = ~S~%" desc)
  (check (and (search "wrapped[" desc) (search "AW_SBCL_AW_SUPER_DEMO" desc) t) t))

;;; --- verdict ----------------------------------------------------------------
(if (zerop *fails*)
    (format t "~&### SMOKE PASS — all checks green~%")
    (format t "~&### SMOKE FAIL — ~A check(s) failed~%" *fails*))
(sb-ext:exit :code (if (zerop *fails*) 0 1))
