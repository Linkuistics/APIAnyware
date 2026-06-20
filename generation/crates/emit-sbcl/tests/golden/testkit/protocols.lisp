(in-package #:apianyware-sbcl-impl)

;;; Generated TestKit bindings — protocol conformance surfaces (contract §3.5) — do not edit
;; --- TKCopying (TestKit) — protocol conformance surface (contract §3.5) ---
(defgeneric ns:copy-with-zone (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(register-objc-protocol "TKCopying"
  :required (("copyWithZone:" ns:copy-with-zone))
  :optional ())
;; --- TKDelegate (TestKit) — protocol conformance surface (contract §3.5) ---
(defgeneric ns:manager-did-finish (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(defgeneric ns:manager-should-continue (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(defgeneric ns:manager-will-return-result (receiver arg0) (:documentation "ObjC selector generic (1 arg)."))
(register-objc-protocol "TKDelegate"
  :required ()
  :optional (("managerDidFinish:" ns:manager-did-finish) ("managerShouldContinue:" ns:manager-should-continue) ("managerWillReturnResult:" ns:manager-will-return-result)))
