;;; Generated TestKit bindings — TKView — class + dispatch (ADR-0034) — do not edit
(in-package #:apianyware-sbcl-impl)

;; --- TKView (TestKit) — metaclass-backed class (ADR-0034) ---
(defclass ns:tk-view (ns:tk-object) () (:metaclass objc-class))
(register-objc-class 'ns:tk-view "TKView" "TKObject")

;; --- TKView (TestKit) — dispatch (ADR-0034 §2) ---
(defmethod ns:title ((self ns:tk-view))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "title"))))
(defmethod ns:set-title_ ((self ns:tk-view) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "setTitle:") (aw-ptr value)))
(defmethod ns:hidden ((self ns:tk-view))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "hidden")))
(defmethod ns:set-hidden_ ((self ns:tk-view) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:boolean 8))) (aw-ptr self) (aw-sel "setHidden:") value))
(defmethod ns:tag ((self ns:tk-view))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:signed 64) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "tag")))
(defmethod ns:set-tag_ ((self ns:tk-view) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:signed 64))) (aw-ptr self) (aw-sel "setTag:") value))
(defmethod ns:frame ((self ns:tk-view))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function (sb-alien:struct ns-rect) sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "frame")))
(defmethod ns:set-frame_ ((self ns:tk-view) value)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:struct ns-rect))) (aw-ptr self) (aw-sel "setFrame:") value))
(defmethod ns:set-needs-display ((self ns:tk-view))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "setNeedsDisplay")))
(defmethod ns:animate-with-duration_animations_ ((self ns:tk-view) duration animations)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:double sb-alien:system-area-pointer)) (aw-ptr self) (aw-sel "animateWithDuration:animations:") duration (aw-block animations)))
(defmethod ns:appearance ((class (eql (find-class 'ns:tk-view))))
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer)) (aw-class "TKView") (aw-sel "appearance"))))
(register-objc-init 'ns:tk-view "initWithFrame:" (:init-with-frame) (lambda (%alloced %args) (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+ (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:struct ns-rect))) %alloced (aw-sel "initWithFrame:") (getf %args :init-with-frame))))

