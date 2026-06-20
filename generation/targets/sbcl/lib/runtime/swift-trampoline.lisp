;;;; runtime/swift-trampoline.lisp — the Swift-native residual binding shape
;;;; (ADR-0038 §3; ADR-0015 Lisp-side marshalling). Leaf 050/020.
;;;;
;;;; The Swift-native delta — the `objc_exposed == false` methods/inits/functions
;;;; ObjC's `objc_msgSend` cannot reach — is re-exported behind a flat C ABI by
;;;; `libAPIAnywareSbcl`'s generated `@_cdecl` trampolines (`aw_sbcl_*`, ADR-0038).
;;;; The generated `functions.lisp` / `constants.lisp` of a framework with any such
;;;; residual bind those entries with a per-signature `sb-alien` crossing — the SAME
;;;; compiled-FFI shape as the direct `objc_msgSend` dispatch (ffi.lisp). Object
;;;; returns wrap to their exact bound CLOS class via `aw-wrap` (the ADR-0034 MOP
;;;; registry, the gerbil ADR-0029 §2 analogue); string returns coerce via the
;;;; existing string bridge.
;;;;
;;;; This leaf (050/020) lands the *shape*: the dylib loader + the one uniform
;;;; `aw_sbcl_box_free` binding + the residual String coercers. The `throws`/NSError
;;;; coercer (`aw-swift-call/error`) is 050's conditions leaf (050/050) — it raises a
;;;; `ns:cocoa-error`, which the condition hierarchy must exist first.

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; Loading `libAPIAnywareSbcl` (the SBCL target's sole native unit, ADR-0038).
;;;
;;; Eager-load + auto-reopen posture (gerbil §4, NOT chez's lazy-load forcing
;;; reference): the dylib is loaded up front so every `aw_sbcl_*` symbol resolves,
;;; and `save-lisp-and-die` auto-reopens it (it stays in `*shared-objects*`), so the
;;; residual symbols re-link for free in a revived image (ADR-0038 §5) — no
;;; `aw_sbcl_revive` entry, the dylib stays passive.
;;; ---------------------------------------------------------------------------

(defvar *native-dylib-path* nil
  "Filesystem path to `libAPIAnywareSbcl.dylib`. Set by the loader / bundler before
   `aw-load-native-dylib`; the bundler relocates it into `Contents/Frameworks/` and
   points this at the `@executable_path/..` copy (ADR-0038 §6).")

(defvar *native-dylib-loaded* nil
  "True once `aw-load-native-dylib` has succeeded this process.")

(defun aw-load-native-dylib (&optional (path *native-dylib-path*))
  "`load-shared-object` `libAPIAnywareSbcl` from PATH (defaulting to
   `*native-dylib-path*`). Idempotent at the dyld level. Must run before any
   `aw_sbcl_*` crossing is CALLED; the `define-alien-routine` forms below define
   lazily, so loading this file does not itself require the dylib."
  (unless path
    (error "aw-load-native-dylib: no path (set *native-dylib-path* or pass one)."))
  (sb-alien:load-shared-object path)
  (setf *native-dylib-loaded* t))

;;; ---------------------------------------------------------------------------
;;; The one uniform value-handle free (OpaqueHandle.swift `aw_sbcl_box_free`).
;;;
;;; The canonical `aw_sbcl_*` binding shape: a typed `sb-alien` crossing, one per
;;; trampoline signature. A non-bridged Swift value return (a `struct`, payload
;;; `enum`, tuple …) crosses as an opaque +1-retained handle; this frees it.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-routine ("aw_sbcl_box_free" aw-box-free)
    sb-alien:void
  (handle sb-alien:system-area-pointer))

;;; ---------------------------------------------------------------------------
;;; Residual String coercers (the marshalling stays Lisp-side, ADR-0015 — only the
;;; opaque-box + throws shapes are hermetic Swift). Mirror the gerbil
;;; `aw-swift-string-arg` / `aw-swift-string-result`.
;;; ---------------------------------------------------------------------------

(defun aw-swift-string-arg (s)
  "A `String` argument crossing INTO a trampoline: a Lisp string bridged to a
   +1-retained `NSString` `id` for the `@_cdecl` body's `… as String`; nil -> null."
  (if (null s)
      (aw-null-sap)
      (aw-make-nsstring s)))

(defun aw-swift-string-result (id-sap)
  "A `String` result coming BACK from a trampoline: the `@_cdecl` handed us a
   +1-retained `NSString` `id`. Copy its bytes, release the +1, null -> nil."
  (if (aw-null-sap-p id-sap)
      nil
      (prog1 (nsstring->string id-sap)
        (%objc-release id-sap))))
