;;; Generated TestKit bindings — TKHelper — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- TKHelper (TestKit) — metaclass-backed class (ADR-0034) ---
(defclass ns:tk-helper (ns:tk-object) () (:metaclass objc-class))
(register-objc-class 'ns:tk-helper "TKHelper" "TKObject")

;; --- TKHelper (TestKit) — dispatch (ADR-0034 §2) ---
(defmethod ns:version-string ((class (eql (find-class 'ns:tk-helper))))
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "TKHelper") (aw-sel "versionString"))))
(defmethod ns:maximum-count ((class (eql (find-class 'ns:tk-helper))))
  (declare (ignore class))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:signed 64) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "TKHelper") (aw-sel "maximumCount")))

