;;; Generated TestKit bindings — TKObject — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- TKObject (TestKit) — metaclass-backed class (ADR-0034) ---
(defclass ns:tk-object (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:tk-object "TKObject" "")

;; --- TKObject (TestKit) — dispatch (ADR-0034 §2) ---
(defmethod ns:dealloc ((self ns:tk-object))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "dealloc")))
(defmethod ns:description ((self ns:tk-object))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "description"))))

