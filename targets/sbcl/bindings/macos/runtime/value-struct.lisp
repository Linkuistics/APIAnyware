;;;; runtime/value-struct.lisp — the population-B value-struct object model (ADR-0042).
;;;;
;;;; The dual of objc.lisp's ObjC-class projection, for Swift **value structs**
;;;; (`objc_exposed == false`, e.g. `IndexSet`, `CharacterSet`, `Data`). A value struct
;;;; has NO ObjC `Class` behind it — it crosses the C ABI only as the opaque
;;;; `AwSbclValueBox` handle a trampoline produces (swift-trampoline.lisp). But in SBCL's
;;;; single `ns:` package a value-struct method named like an ObjC selector (`ns:contains`)
;;;; MUST be a `defmethod` extending the shared generic — a bare `defun ns:contains` cannot
;;;; coexist with the `defgeneric ns:contains` of an ObjC dispatch (one symbol, one function
;;;; cell). So a value struct is projected as a CLOS class to specialize those methods on
;;;; (ADR-0042; gerbil keeps them procedural because Scheme has no such collision).
;;;;
;;;; The emitter generates one `(defclass ns:<struct> (ns:value-struct) ())` per bindable
;;;; value struct (emit-sbcl `emit_struct.rs`, into `structs.lisp`). This file owns the
;;;; runtime-owned ROOT `ns:value-struct` they all derive from:
;;;;
;;;;   - a PLAIN `standard-class` (NOT the `objc-class` metaclass — none of the MOP hooks
;;;;     objc.lisp installs apply: no alloc/init, no foreign ivar offsets, no subclass
;;;;     synthesis);
;;;;   - carrying the box handle in a `ptr` slot — the SAME slot name `ns:ns-object` uses,
;;;;     so the existing `aw-ptr` (ffi.lisp, `(slot-value … 'ptr)`) reads it unchanged. A
;;;;     value-struct method's `(defmethod … ((self ns:<struct>) …))` coerces its receiver
;;;;     through `(aw-ptr self)` exactly like a class owner, and a value-struct argument
;;;;     coerces through the same `(aw-ptr arg)` — the unbox + mutating write-back live
;;;;     entirely in the `@_cdecl` Swift side, so the Lisp side needs no value-specific path;
;;;;   - with a finalizer that frees the box (`aw-box-free` → `aw_sbcl_box_free`).
;;;;
;;;; A value-struct constructor (`ns:make-<struct>`) wraps its produced box into an instance
;;;; — `(make-instance 'ns:<struct> :ptr <box>)` — so the returned value dispatches through
;;;; the struct's `defmethod`s (the §3.3 `make-instance`→alloc/init path is objc.lisp's, NOT
;;;; this — a value struct is constructed by the trampoline, never ObjC `alloc`).
;;;;
;;;; Needs the 050/020 seam (`aw-null-sap-p`, the `ptr` slot convention) + swift-trampoline's
;;;; `aw-box-free`; hence loaded after them.

(in-package #:apianyware-sbcl-impl)

;;; The root name must be EXTERNAL in `ns` before any generated `structs.lisp` reads it
;;; single-colon (`ns:value-struct`), exactly as objc.lisp exports `ns:ns-object`.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export (intern "VALUE-STRUCT" '#:ns) '#:ns))

(defclass ns::value-struct ()
  ((ptr :initarg :ptr :initform nil :reader value-struct-box
        :documentation "The opaque `AwSbclValueBox` handle SAP. Named `ptr` so the shared
                        `aw-ptr` (ffi.lisp) reads it as the receiver/argument handle."))
  (:documentation
   "The runtime-owned root of every bound Swift value struct (ADR-0042). A PLAIN
    `standard-class` (no `objc-class` metaclass): a value struct is a boxed Swift value,
    not an ObjC object, so none of the ObjC MOP hooks apply."))

;;; ---------------------------------------------------------------------------
;;; Box lifetime: free on finalization.
;;;
;;; UNLIKE a wrapped ObjC `id` (lifetime.lisp / ADR-0036), a value box has NO UI affinity
;;; — `aw_sbcl_box_free` just releases the Swift box's `Unmanaged` retain; no AppKit
;;; `dealloc` runs. So it is safe to free DIRECTLY on the off-main SBCL finalizer thread,
;;; with no main-thread release-queue bounce. The finalizer captures ONLY the box pointer
;;; (as an integer value copy — never the instance, which would re-root it and prevent
;;; collection) and is `:dont-save t`: a `save-lisp-and-die` image's box pointers are stale
;;; (050/070), so a revived process must not free garbage.
;;; ---------------------------------------------------------------------------

(defmethod initialize-instance :after ((self ns::value-struct) &key)
  (let ((box (slot-value self 'ptr)))
    (when (and box (not (aw-null-sap-p box)))
      (let ((box-int (sb-sys:sap-int box)))   ; value copy — NOT the instance
        (sb-ext:finalize self
                         (lambda () (aw-box-free (sb-sys:int-sap box-int)))
                         :dont-save t)))))
