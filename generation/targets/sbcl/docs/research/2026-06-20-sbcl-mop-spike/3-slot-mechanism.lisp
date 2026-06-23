;;;; Spike 3 — project ObjC ivars as foreign CLOS slots reachable via slot-value.
;;;; Re-derives the mechanism first-hand (research §5.1 refuted the assumed hook
;;;; FOR CCL; this proves it works for SBCL). Run: sbcl --non-interactive --load 3-slot-mechanism.lisp
(in-package :cl-user)
(defclass objc-class (standard-class) ())
(defmethod sb-mop:validate-superclass ((c objc-class) (s standard-class)) t)

;; foreign slot-definition classes carry a baked bit-offset + foreign C-type
(defclass objc-direct-slot (sb-mop:standard-direct-slot-definition)
  ((offset :initarg :offset :reader slot-offset)
   (ctype  :initarg :ctype  :reader slot-ctype)))
(defclass objc-effective-slot (sb-mop:standard-effective-slot-definition)
  ((offset :accessor slot-offset)   ; unbound => plain Lisp slot, fall through
   (ctype  :accessor slot-ctype)))

(defmethod sb-mop:direct-slot-definition-class ((c objc-class) &rest initargs)
  (if (getf initargs :offset) (find-class 'objc-direct-slot) (call-next-method)))
(defmethod sb-mop:effective-slot-definition-class ((c objc-class) &rest initargs)
  (declare (ignore initargs)) (find-class 'objc-effective-slot))
(defmethod sb-mop:compute-effective-slot-definition ((c objc-class) name dsds)
  (let ((e (call-next-method)) (d (find-if (lambda (x) (typep x 'objc-direct-slot)) dsds)))
    (when d (setf (slot-offset e) (slot-offset d) (slot-ctype e) (slot-ctype d)))
    e))

(defclass objc-object () ((ptr :initarg :ptr :accessor obj-ptr)))
(defun foreign-slot-p (slotd) (slot-boundp slotd 'offset))

(defmethod sb-mop:slot-value-using-class ((c objc-class) inst (s objc-effective-slot))
  (if (foreign-slot-p s)
      (let ((sap (obj-ptr inst)) (byte (truncate (slot-offset s) 8)))
        (ecase (slot-ctype s) (:int (sb-sys:sap-ref-32 sap byte))
               (:double (sb-sys:sap-ref-double sap byte))))
      (call-next-method)))
(defmethod (setf sb-mop:slot-value-using-class) (new (c objc-class) inst (s objc-effective-slot))
  (if (foreign-slot-p s)
      (let ((sap (obj-ptr inst)) (byte (truncate (slot-offset s) 8)))
        (ecase (slot-ctype s) (:int (setf (sb-sys:sap-ref-32 sap byte) new))
               (:double (setf (sb-sys:sap-ref-double sap byte) new))))
      (call-next-method)))

(defclass ns-foo (objc-object)
  ((counter :offset 0 :ctype :int) (scale :offset 64 :ctype :double))
  (:metaclass objc-class))

(sb-alien:define-alien-routine "malloc" sb-alien:system-area-pointer (n sb-alien:size-t))
(let* ((buf (malloc 128)) (inst (make-instance 'ns-foo :ptr buf)))
  (setf (sb-sys:sap-ref-32 buf 0) 4242)
  (setf (sb-sys:sap-ref-double buf 8) 3.5d0)
  (format t "~&### slot-value counter = ~a (expect 4242)~%" (slot-value inst 'counter))
  (format t "### slot-value scale   = ~a (expect 3.5)~%" (slot-value inst 'scale))
  (setf (slot-value inst 'counter) 99)
  (format t "### after setf, raw sap-ref-32 = ~a (expect 99)~%" (sb-sys:sap-ref-32 buf 0))
  (format t "### plain-Lisp ptr slot fell through, bound = ~a~%" (slot-boundp inst 'ptr)))
(sb-ext:exit)
