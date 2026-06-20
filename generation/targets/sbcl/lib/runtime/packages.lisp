;;;; runtime/packages.lisp — the SBCL target's two packages (node BRIEF, PACKAGE MODEL).
;;;;
;;;; The CL-family contract (§3.1, ADR-0033) presents every bound Cocoa name in the
;;;; `ns:` package; the binding implementation lives in a separate impl package the
;;;; generated files are read in. This file is loaded FIRST — every other runtime
;;;; unit and every generated binding file assumes both packages already exist.
;;;;
;;;; Owned by leaf 050/020 (the FFI seam is the foundation); the metaclass + object
;;;; model that fill the impl package land in 050/030.

(in-package #:cl-user)

;;; The contract surface package: a PURE HOLDER of bound Cocoa symbols (class names
;;; `ns:ns-string`, generic-fn names `ns:length`, constants `ns:tk-version-string`).
;;; It `(:use)` NOTHING — application source writes `ns:`-qualified names and must
;;; never accidentally inherit a `cl:` symbol here. The runtime + the generated
;;; facades intern and `export` symbols into it; nothing is defined by `:use`.
(defpackage #:ns
  (:use)
  (:documentation
   "The CL-family contract surface (ADR-0033 §3.1): bound ObjC class names, the
    per-selector generic functions, and bound constants, all `ns:`-qualified.
    Uses no package — a pure holder so app source inherits nothing implicit."))

;;; The runtime / implementation package. Every generated binding file opens with
;;; `(in-package #:apianyware-sbcl-impl)` and references the runtime helpers bare
;;; (`aw-ptr`, `aw-wrap`, `aw-sel`, `+objc-msgsend+`, `register-objc-class`, the
;;; `objc-class` metaclass …) while writing bound names `ns:`-qualified and
;;; `sb-alien:` operators fully qualified.
;;;
;;; `(:use #:cl #:sb-mop)` — CL plus the SBCL MOP, so 050/030's metaclass hooks
;;; (`slot-value-using-class`, `validate-superclass`, `direct-slot-definition-class`
;;; …) are written with bare names. Verified to compose with no symbol conflict on
;;; SBCL 2.6.5 (the two packages were designed to be `:use`d together).
(defpackage #:apianyware-sbcl-impl
  (:use #:cl #:sb-mop)
  (:documentation
   "The SBCL binding runtime + the package every generated file is read in.
    Owns the `aw-*` FFI helpers, the `+objc-msgsend+` seam, the `objc-class`
    metaclass + `ns:ns-object` root (050/030), and the baked-table consumers.
    Bound Cocoa names stay `ns:`-qualified; this package is below the contract."))
