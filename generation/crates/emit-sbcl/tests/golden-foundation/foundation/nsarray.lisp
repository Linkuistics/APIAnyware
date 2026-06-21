;;; Generated Foundation bindings — NSArray — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- NSArray (Foundation) — metaclass-backed class (ADR-0034) ---
(defclass ns:ns-array (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-array "NSArray" "NSObject")

;; --- NSArray (Foundation) — dispatch (ADR-0034 §2) ---
(defmethod ns:count ((self ns:ns-array))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:unsigned 64) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "count")))
(defmethod ns:description ((self ns:ns-array))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "description")) t))
(defmethod ns:first-object ((self ns:ns-array))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "firstObject"))))
(defmethod ns:last-object ((self ns:ns-array))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "lastObject"))))
(defmethod ns:sorted-array-hint ((self ns:ns-array))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "sortedArrayHint")) t))
(defmethod ns:object-at-index_ ((self ns:ns-array) index)
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:unsigned 64))) (aw-ptr self) (aw-sel "objectAtIndex:") index)))
(defmethod ns:encode-with-coder_ ((self ns:ns-array) coder)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "encodeWithCoder:") (aw-ptr coder)))
(defmethod ns:supports-secure-coding ((class (eql (find-class 'ns:ns-array))))
  (declare (ignore class))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "NSArray") (aw-sel "supportsSecureCoding")))
(register-objc-init 'ns:ns-array "initWithCoder:" (:init-with-coder) (lambda (%alloced %args) (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) %alloced (aw-sel "initWithCoder:") (aw-ptr (getf %args :init-with-coder)))))

;; --- NSArray (Foundation) — Swift-native residual (receiver-handle trampolines, ADR-0038) ---
(defmethod ns:make-iterator ((self ns:ns-array))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:extern-alien "aw_sbcl_swift_m_Foundation_NSArray_makeIterator" (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self)) t))

