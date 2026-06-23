;;; Generated Foundation bindings — NSData — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- NSData (Foundation) — metaclass-backed class (ADR-0034) ---
(defclass ns:ns-data (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-data "NSData" "NSObject")

;; --- NSData (Foundation) — dispatch (ADR-0034 §2) ---
(defmethod ns:length ((self ns:ns-data))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:unsigned 64) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "length")))
(defmethod ns:bytes ((self ns:ns-data))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "bytes")))
(defmethod ns:description ((self ns:ns-data))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "description")) t))
(defmethod ns:encode-with-coder_ ((self ns:ns-data) coder)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "encodeWithCoder:") (aw-ptr coder)))
(defmethod ns:supports-secure-coding ((class (eql (find-class 'ns:ns-data))))
  (declare (ignore class))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "NSData") (aw-sel "supportsSecureCoding")))

