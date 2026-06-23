(in-package #:apianyware-sbcl-impl)

;;; Generated constant definitions for TestKit — do not edit

(define-objc-constant ns:tk-version-string (aw-wrap (sb-alien:extern-alien "TKVersionString" sb-alien:system-area-pointer)))
(define-objc-constant ns:tk-default-timeout (sb-alien:extern-alien "TKDefaultTimeout" sb-alien:double))
(define-objc-constant ns:tk-status-attribute (aw-wrap (aw-make-nsstring "TKStatus") t))
