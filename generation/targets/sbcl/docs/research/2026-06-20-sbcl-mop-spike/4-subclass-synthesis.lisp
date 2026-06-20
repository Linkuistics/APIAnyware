;;;; Spike 4 — make-instance -> allocate-instance hook + real objc_allocateClassPair.
;;;; Run: sbcl --non-interactive --load 4-subclass-synthesis.lisp
(in-package :cl-user)
(sb-alien:define-alien-routine ("objc_getClass" objc-get-class)
    sb-alien:system-area-pointer (name sb-alien:c-string))
(sb-alien:define-alien-routine ("objc_allocateClassPair" objc-allocate-class-pair)
    sb-alien:system-area-pointer
  (superclass sb-alien:system-area-pointer) (name sb-alien:c-string) (extra sb-alien:size-t))
(sb-alien:define-alien-routine ("objc_registerClassPair" objc-register-class-pair)
    sb-alien:void (cls sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("class_getName" class-get-name)
    sb-alien:c-string (cls sb-alien:system-area-pointer))
(sb-alien:define-alien-routine ("class_getSuperclass" class-get-superclass)
    sb-alien:system-area-pointer (cls sb-alien:system-area-pointer))
(defun nullp (sap) (zerop (sb-sys:sap-int sap)))

;; (1) make-instance routes through allocate-instance specialized on the metaclass
(defclass objc-class (standard-class) ())
(defmethod sb-mop:validate-superclass ((c objc-class) (s standard-class)) t)
(defvar *alloc-ran* nil)
(defclass ns-object () ((ptr :initarg :ptr :accessor obj-ptr)))
(defclass ns-bar (ns-object) () (:metaclass objc-class))
(defmethod allocate-instance ((class objc-class) &rest initargs)
  (declare (ignore initargs)) (setf *alloc-ran* t) (call-next-method))
(make-instance 'ns-bar :ptr nil)
(format t "~&### allocate-instance hook fired on make-instance = ~a (expect T)~%" *alloc-ran*)

;; (2) real ObjC subclass synthesis from SBCL
(let ((nsobject (objc-get-class "NSObject")))
  (format t "### objc_getClass NSObject non-null = ~a~%" (not (nullp nsobject)))
  (let ((pair (objc-allocate-class-pair nsobject "AwSbclSpikeView" 0)))
    (format t "### objc_allocateClassPair non-null = ~a~%" (not (nullp pair)))
    (objc-register-class-pair pair)
    (let ((found (objc-get-class "AwSbclSpikeView")))
      (format t "### runtime finds the new class = ~a~%" (not (nullp found)))
      (format t "### class_getName = ~s~%" (class-get-name found))
      (format t "### superclass is NSObject = ~a~%"
              (= (sb-sys:sap-int (class-get-superclass found)) (sb-sys:sap-int nsobject))))))
(sb-ext:exit)
