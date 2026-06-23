;;; Generated TestKit bindings — TKManager — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- TKManager (TestKit) — metaclass-backed class (ADR-0034) ---
(defclass ns:tk-manager (ns:tk-object) () (:metaclass objc-class))
(register-objc-class 'ns:tk-manager "TKManager" "TKObject")

;; --- TKManager (TestKit) — dispatch (ADR-0034 §2) ---
(defmethod ns:load-resource_error_ ((self ns:tk-manager) name)
  (aw-with-error-cell (%err)
    (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "loadResource:error:") (aw-ptr name) %err)))
(defmethod ns:resource-named_ ((self ns:tk-manager) name)
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "resourceNamed:") (aw-ptr name))))
(defmethod ns:shared-manager ((class (eql (find-class 'ns:tk-manager))))
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "TKManager") (aw-sel "sharedManager"))))

