(in-package #:apianyware-sbcl-impl)

;;; Generated C function bindings for TestKit — do not edit

(sb-alien:define-alien-routine ("TKComputeDistance" ns:tk-compute-distance) sb-alien:double
  (x sb-alien:double)
  (y sb-alien:double))
(sb-alien:define-alien-routine ("TKTransformPoint" ns:tk-transform-point) (sb-alien:struct ns-point)
  (point (sb-alien:struct ns-point)))
(sb-alien:define-alien-routine ("TKReset" ns:tk-reset) sb-alien:void)
(sb-alien:define-alien-routine ("TKCreateBuffer" ns:tk-create-buffer) sb-alien:system-area-pointer
  (name sb-alien:system-area-pointer)
  (size (sb-alien:unsigned 32)))
(sb-alien:define-alien-routine ("TKGetName" ns:tk-get-name) sb-alien:c-string
  (id (sb-alien:unsigned 32)))
(sb-alien:define-alien-routine ("TKRegisterCallback" ns:tk-register-callback) sb-alien:void
  (context sb-alien:system-area-pointer)
  (callback sb-alien:system-area-pointer))
