;;;; runtime/ffi.lisp — the `sb-alien` FFI seam + the core dispatch helpers the
;;;; emitted CLOS bindings call (node BRIEF, "Runtime contract fixed by 040/020",
;;;; the seam half). Leaf 050/020.
;;;;
;;;; Compiled FFI (ADR-0015): typed `sb-alien`, not CFFI — the same compiled-FFI
;;;; shape the Swift-native residual uses (swift-trampoline.lisp). This unit is the
;;;; foundation every later Lisp leaf sits on; it carries NO MOP detail (the
;;;; `objc-class` metaclass + the `register-objc-class` populator are 050/030's —
;;;; here `*objc-class-registry*` is an empty hash table `aw-wrap` consults).
;;;;
;;;; The seam reaches ObjC DIRECTLY: `objc_msgSend` is taken once as a raw SAP
;;;; (`+objc-msgsend+`) and re-cast per call site to the exact C function type — the
;;;; only shape that binds a selector-polymorphic, ABI-correct `objc_msgSend` (it is
;;;; `variadic-by-cast`, so no single `define-alien-routine` can stand in). Classes
;;;; and selectors are resolved LAZILY from their baked STRINGS and cached, never
;;;; baked as pointers — a dumped image loses every live `Class`/`SEL` (ADR-0034 §6),
;;;; so 050/070's startup pass clears the caches + re-`resolve`s from these helpers.

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; libobjc primitives — always-mapped (libobjc loads with the process), so these
;;; `define-alien-routine`s resolve with no framework `dlopen`.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-routine ("objc_getClass" %objc-get-class)
    sb-alien:system-area-pointer
  (name sb-alien:c-string))

;; The DYNAMIC class of a live instance — backs the class-aware `aw-wrap`.
(sb-alien:define-alien-routine ("object_getClass" %object-get-class)
    sb-alien:system-area-pointer
  (obj sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("class_getName" %class-get-name)
    sb-alien:c-string
  (cls sb-alien:system-area-pointer))

;; Walk to the nearest bound ancestor when an instance's exact class is unbound.
(sb-alien:define-alien-routine ("class_getSuperclass" %class-get-superclass)
    sb-alien:system-area-pointer
  (cls sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("sel_registerName" %sel-register-name)
    sb-alien:system-area-pointer
  (name sb-alien:c-string))

(sb-alien:define-alien-routine ("sel_getName" %sel-get-name)
    sb-alien:c-string
  (sel sb-alien:system-area-pointer))

;; ARC primitives (lifetime is 050; the string bridge needs `objc_retain` for the
;; +0-autoreleased → +1-owned promotion, and `objc_release` to balance a transient).
(sb-alien:define-alien-routine ("objc_retain" %objc-retain)
    sb-alien:system-area-pointer
  (obj sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("objc_release" %objc-release)
    sb-alien:void
  (obj sb-alien:system-area-pointer))

;;; ---------------------------------------------------------------------------
;;; Null-SAP helpers.
;;; ---------------------------------------------------------------------------

(declaim (inline aw-null-sap aw-null-sap-p))

(defun aw-null-sap ()
  "The null `id`/`Class`/`SEL` SAP."
  (sb-sys:int-sap 0))

(defun aw-null-sap-p (sap)
  "True when SAP is the null pointer (a nil object, an unresolved class …)."
  (zerop (sb-sys:sap-int sap)))

;;; ---------------------------------------------------------------------------
;;; The `objc_msgSend` seam (`+objc-msgsend+`).
;;;
;;; A SAP, not an `extern-alien` — the emitted `defmethod` bodies `sap-alien` it
;;; to the per-selector `(function <ret> sap sap <args>…)` type. MUST be
;;; re-resolved at image startup (ADR-0038 §5): `save-lisp-and-die` keeps this Lisp
;;; var but its address is meaningless in the revived process until re-resolved.
;;; ---------------------------------------------------------------------------

;; arm64 needs NO `objc_msgSend_stret` / `_fpret` variant (verified 050/020): the
;; symbols still EXIST in libobjc for x86 source-compat, but the arm64 ABI routes
;; struct + fp returns through the plain entry (indirect-result register x8), so a
;; struct-returning call cast straight off `+objc-msgsend+` is correct — confirmed
;; by `-rangeOfString:` returning a live `NSRange` {location 6, length 5} through it.
;; The emitter therefore casts every shape (scalar, struct, fp) off this one SAP.
(defvar +objc-msgsend+ (sb-sys:int-sap 0)
  "SAP of `objc_msgSend`. Re-resolved at startup by 050/070 (ADR-0038 §5).")

(defun aw-resolve-objc-msgsend ()
  "Resolve (or re-resolve) `+objc-msgsend+` from the live `objc_msgSend` symbol.
   Called at load for a dev `sbcl --load`, and again by 050/070's startup pass."
  (setf +objc-msgsend+ (sb-sys:foreign-symbol-sap "objc_msgSend")))

(aw-resolve-objc-msgsend)

;;; ---------------------------------------------------------------------------
;;; Framework loading — `dlopen` a system framework so its ObjC classes resolve.
;;; 050/070's startup re-resolution pass reuses this over the baked framework set;
;;; here it backs the dev smoke and `aw-class`'s "is the framework loaded?" error.
;;; ---------------------------------------------------------------------------

(defun aw-load-framework (name)
  "`dlopen` the system framework NAME (its base name, e.g. \"Foundation\") so its
   ObjC classes become resolvable. Idempotent — dyld refcounts the handle."
  (sb-alien:load-shared-object
   (format nil "/System/Library/Frameworks/~A.framework/~A" name name)))

;;; ---------------------------------------------------------------------------
;;; Selector + class resolution — lazy, cached, string-keyed (ADR-0034 §6).
;;; The caches hold live SAPs, so 050/070's startup pass clears them after a dump.
;;; ---------------------------------------------------------------------------

(defvar *sel-cache* (make-hash-table :test 'equal)
  "Selector-string -> live `SEL` SAP. Cleared + repopulated by 050/070 per process.")

(defvar *class-cache* (make-hash-table :test 'equal)
  "ObjC-class-name -> live `Class` SAP. Cleared + repopulated by 050/070 per process.")

(defun aw-sel (name)
  "Resolve the selector named NAME to its live `SEL` SAP, cached. `sel_registerName`
   is idempotent + lives in always-mapped libobjc, so this needs no framework load."
  (or (gethash name *sel-cache*)
      (setf (gethash name *sel-cache*) (%sel-register-name name))))

(defun aw-class (name)
  "Resolve the ObjC class named NAME to its live `Class` SAP, cached. Signals if the
   class is unresolved — its owning framework has not been `dlopen`ed yet."
  (or (gethash name *class-cache*)
      (let ((cls (%objc-get-class name)))
        (when (aw-null-sap-p cls)
          (error "ObjC class ~S not found — is its framework dlopened? ~
                  (050/070's startup pass loads the baked framework set.)" name))
        (setf (gethash name *class-cache*) cls))))

;;; ---------------------------------------------------------------------------
;;; The object boundary — `aw-ptr` (outbound) / `aw-wrap` (inbound).
;;;
;;; SEAM-LEVEL but bridging to the object model: the only object-model touchpoints
;;; are the `ptr` slot (the documented contract: `ns:ns-object` "carries the foreign
;;; ptr slot") and `make-instance`. The metaclass that makes `ns:ns-object` real is
;;; 050/030's; until then the registry is empty and `aw-wrap` is dormant — exactly
;;; what the seam smoke needs (it round-trips scalars + strings, not bound objects).
;;; ---------------------------------------------------------------------------

(defvar *objc-class-registry* (make-hash-table :test 'equal)
  "ObjC-class-name string -> the bound CLOS class object. Defined here (the seam);
   POPULATED by 050/030's `register-objc-class`. `aw-wrap` consults it.")

(defun aw-ptr (instance)
  "Outbound object coercion (the contract's `->ptr`): a bound instance | nil -> its
   `id` SAP, nil -> the null SAP. Reads the documented `ptr` slot (a plain Lisp slot
   that falls through to standard storage — spike 3)."
  (if (null instance)
      (aw-null-sap)
      (slot-value instance 'ptr)))

(defun aw-resolve-bound-class (id-sap)
  "Map a live `id` to its nearest bound CLOS class: `object_getClass`, then walk
   `class_getSuperclass` until a baked name hits `*objc-class-registry*`."
  (loop for cls = (%object-get-class id-sap) then (%class-get-superclass cls)
        until (aw-null-sap-p cls)
        for bound = (gethash (%class-get-name cls) *objc-class-registry*)
        when bound return bound
        finally (error "no bound CLOS class for id ~A (no ancestor registered)" id-sap)))

(defun aw-wrap (id-sap &optional retained)
  "Inbound wrap: a raw `id` SAP -> the exact bound CLOS instance (null -> nil).
   RETAINED t marks the `id` as already +1 (init/copy/new families, copy
   properties); the balancing release/finalizer is 050's lifetime concern — here
   the flag is accepted + ignored so generated `(aw-wrap … t)` forms load + run."
  (declare (ignore retained))
  (if (aw-null-sap-p id-sap)
      nil
      (make-instance (aw-resolve-bound-class id-sap) :ptr id-sap)))

;;; ---------------------------------------------------------------------------
;;; The String bridge — `NSString` <-> Lisp string, UTF-8 (design §4).
;;;
;;; UTF-8 is PINNED (`:external-format :utf-8`) rather than left to the host locale:
;;; the gerbil target hit a real bug where the C-locale path (ISO-8859-1) failed to
;;; convert a non-ASCII button title ("Color…"); pinning UTF-8 makes the round trip
;;; codepoint-exact for the full Unicode range.
;;; ---------------------------------------------------------------------------

(defun aw-make-nsstring (lisp-string)
  "Lisp string -> a +1-retained `NSString` `id` SAP (caller owns the +1).
   `+[NSString stringWithUTF8String:]` is +0 autoreleased, so retain to +1; the
   050 lifetime layer (via `aw-wrap … t`) registers the balancing release."
  (let ((ns (sb-alien:alien-funcall
             (sb-alien:sap-alien +objc-msgsend+
                                 (sb-alien:function sb-alien:system-area-pointer
                                                    sb-alien:system-area-pointer
                                                    sb-alien:system-area-pointer
                                                    (sb-alien:c-string :external-format :utf-8)))
             (aw-class "NSString") (aw-sel "stringWithUTF8String:") lisp-string)))
    (%objc-retain ns)))

(defun nsstring->string (id-sap)
  "An `NSString` `id` SAP -> a Lisp string (null -> nil), via `-UTF8String`, UTF-8.
   Does NOT consume a reference — copying the bytes leaves the `NSString` untouched."
  (if (aw-null-sap-p id-sap)
      nil
      (sb-alien:alien-funcall
       (sb-alien:sap-alien +objc-msgsend+
                           (sb-alien:function (sb-alien:c-string :external-format :utf-8)
                                              sb-alien:system-area-pointer
                                              sb-alien:system-area-pointer))
       id-sap (aw-sel "UTF8String"))))
