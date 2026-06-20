;;; Generated TestKit bindings — TKButton — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- TKButton (TestKit) — metaclass-backed class (ADR-0034) ---
(defclass ns:tk-button (ns:tk-view) () (:metaclass objc-class))
(register-objc-class 'ns:tk-button "TKButton" "TKView")

;; --- TKButton (TestKit) — dispatch (ADR-0034 §2) ---
(defmethod ns:label ((self ns:tk-button))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "label"))))
(defmethod ns:set-label ((self ns:tk-button) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "setLabel:") (aw-ptr value)))
(defmethod ns:enabled ((self ns:tk-button))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "enabled")))
(defmethod ns:set-enabled ((self ns:tk-button) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:boolean 8))) (aw-ptr self) (aw-sel "setEnabled:") value))
(defmethod ns:set-target-action ((self ns:tk-button) target action)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "setTarget:action:") (aw-ptr target) (aw-sel action)))
(defmethod ns:is-highlighted ((self ns:tk-button))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "isHighlighted")))

