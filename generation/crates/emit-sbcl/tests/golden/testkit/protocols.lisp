(in-package #:apianyware-sbcl-impl)

;;; Generated TestKit bindings — protocol conformance surfaces (contract §3.5) — do not edit
;; --- TKCopying (TestKit) — protocol conformance surface (contract §3.5) ---
(defgeneric ns:copy-with-zone_ (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(register-objc-protocol "TKCopying"
  :required (("copyWithZone:" ns:copy-with-zone_))
  :optional ())
;; --- TKDelegate (TestKit) — protocol conformance surface (contract §3.5) ---
(defgeneric ns:manager-did-finish_ (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(defgeneric ns:manager-should-continue_ (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(defgeneric ns:manager-will-return-result_ (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(register-objc-protocol "TKDelegate"
  :required ()
  :optional (("managerDidFinish:" ns:manager-did-finish_) ("managerShouldContinue:" ns:manager-should-continue_) ("managerWillReturnResult:" ns:manager-will-return-result_)))
