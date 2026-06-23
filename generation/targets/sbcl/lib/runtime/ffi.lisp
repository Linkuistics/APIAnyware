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
;;; Geometry struct typedefs — the by-value `(sb-alien:struct …)` types the emitted
;;; bindings reference by bare name (`SbclFfiTypeMapper::map_geometry_alias`). The
;;; emitter spells a geometry return/arg as `(sb-alien:struct ns-rect)` and DELEGATES
;;; the matching `define-alien-type` to the runtime (ffi_type_mapping.rs: "the matching
;;; `define-alien-type` is the runtime's job (leaf 050), which must also confirm
;;; `sb-alien` by-value struct passing for these"). Without these, ANY geometry-using
;;; binding — `-[NSView frame]`, `-[NSView setFrame:]`, `-[NSString rangeOfString:]`,
;;; … — fails to LOAD ("unknown alien type"). Pervasive in AppKit (all 7 sample apps
;;; are GUI apps), so these sit in the seam every binding loads on. Surfaced by the
;;; 050/080 integration smoke (the first thing to load emitted geometry methods).
;;;
;;; arm64/LP64 layout: `CGFloat` = `double`; `NSUInteger` = `(unsigned 64)`. The names
;;; mirror the emitter's `map_geometry_alias` set exactly (NS-spelled, CG aliased onto
;;; it where they share an ABI). Nested members reference the struct types defined
;;; above them (`ns-point`/`ns-size` before `ns-rect`). arm64 routes a by-value struct
;;; return through the indirect-result register (x8), so a cast straight off
;;; `+objc-msgsend+` is ABI-correct (ffi.lisp's `objc_msgSend` note) — the integration
;;; smoke confirms it end-to-end against live `NSValue`/`NSString` geometry returns.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-point (x sb-alien:double) (y sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-size (width sb-alien:double) (height sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-rect
    (origin (sb-alien:struct ns-point))
    (size   (sb-alien:struct ns-size))))

;; NSRange members are `NSUInteger`, not `CGFloat` (the one non-double geometry struct).
(sb-alien:define-alien-type nil
  (sb-alien:struct ns-range
    (location (sb-alien:unsigned 64))
    (length   (sb-alien:unsigned 64))))

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-edge-insets
    (top sb-alien:double) (left sb-alien:double)
    (bottom sb-alien:double) (right sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-directional-edge-insets
    (top sb-alien:double) (leading sb-alien:double)
    (bottom sb-alien:double) (trailing sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct ns-affine-transform-struct
    (m11 sb-alien:double) (m12 sb-alien:double)
    (m21 sb-alien:double) (m22 sb-alien:double)
    (t-x sb-alien:double) (t-y sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct cg-affine-transform
    (a sb-alien:double) (b sb-alien:double)
    (c sb-alien:double) (d sb-alien:double)
    (tx sb-alien:double) (ty sb-alien:double)))

(sb-alien:define-alien-type nil
  (sb-alien:struct cg-vector (dx sb-alien:double) (dy sb-alien:double)))

;;; ---------------------------------------------------------------------------
;;; By-value geometry CONSTRUCTORS (surfaced 060/010). The emitter spells a geometry
;;; arg as a by-value `(sb-alien:struct ns-rect)` etc., so an app passing one to a
;;; method or `make-instance` init (e.g. NSWindow's `initWithContentRect:…`) must hand
;;; it an alien struct VALUE. These `with-` macros STACK-allocate it (`with-alien`, no
;;; leak) and bind it for the BODY — the C call copies it by value, so the binding need
;;; only outlive the call. Components coerce to `double` so an app can write integer
;;; literals. (A value-returning `make-rect` would have to `make-alien` (malloc) and
;;; leak; the scoped macro is the non-leaking primitive the ladder uses.)
;;; ---------------------------------------------------------------------------

(defmacro aw-with-point ((var x y) &body body)
  "Bind VAR to a stack `(sb-alien:struct ns-point)` {X Y} (coerced to double) for BODY."
  `(sb-alien:with-alien ((,var (sb-alien:struct ns-point)))
     (setf (sb-alien:slot ,var 'x) (coerce ,x 'double-float)
           (sb-alien:slot ,var 'y) (coerce ,y 'double-float))
     ,@body))

(defmacro aw-with-size ((var w h) &body body)
  "Bind VAR to a stack `(sb-alien:struct ns-size)` {W H} (coerced to double) for BODY."
  `(sb-alien:with-alien ((,var (sb-alien:struct ns-size)))
     (setf (sb-alien:slot ,var 'width) (coerce ,w 'double-float)
           (sb-alien:slot ,var 'height) (coerce ,h 'double-float))
     ,@body))

(defmacro aw-with-rect ((var x y w h) &body body)
  "Bind VAR to a stack `(sb-alien:struct ns-rect)` with origin {X Y} + size {W H}
   (coerced to double) for BODY — the by-value rect a `make-instance`/method call takes."
  `(sb-alien:with-alien ((,var (sb-alien:struct ns-rect)))
     (setf (sb-alien:slot (sb-alien:slot ,var 'origin) 'x) (coerce ,x 'double-float)
           (sb-alien:slot (sb-alien:slot ,var 'origin) 'y) (coerce ,y 'double-float)
           (sb-alien:slot (sb-alien:slot ,var 'size) 'width) (coerce ,w 'double-float)
           (sb-alien:slot (sb-alien:slot ,var 'size) 'height) (coerce ,h 'double-float))
     ,@body))

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
;;; Floating-point trap masking — REQUIRED for any Cocoa code (surfaced 060/010).
;;;
;;; SBCL is unusual in ENABLING the IEEE FP traps (:invalid / :divide-by-zero /
;;; :overflow) by default; almost every other runtime masks them. AppKit/CoreGraphics
;;; routinely produce NaN/∞ intermediates during ordinary layout and geometry (even a
;;; bare `[[NSWindow alloc] init]` trips :invalid), so an unmasked SBCL crashes any GUI
;;; app with `FLOATING-POINT-INVALID-OPERATION`. The Lisp-Cocoa bridges (CCL, cl-objc)
;;; all clear the traps; we do the same. Set at load AND re-set in 050/070's startup
;;; hook — FP modes are thread-local and do NOT survive a `save-lisp-and-die` revive.
;;; ---------------------------------------------------------------------------

(defun aw-mask-fp-traps ()
  "Clear the IEEE FP traps SBCL enables by default, so Cocoa's NaN/∞ intermediates do
   not signal `floating-point-*` in Lisp. Idempotent; thread-local (run on each thread
   that calls into Cocoa — the main thread here, the only one entering AppKit)."
  (sb-int:set-floating-point-modes :traps '()))

(aw-mask-fp-traps)

;;; ---------------------------------------------------------------------------
;;; Framework loading — `dlopen` a system framework so its ObjC classes resolve.
;;; 050/070's startup re-resolution pass reuses this over the baked framework set;
;;; here it backs the dev smoke and `aw-class`'s "is the framework loaded?" error.
;;; ---------------------------------------------------------------------------

(defvar *loaded-frameworks* '()
  "Framework base names explicitly `dlopen`ed via `aw-load-framework`, newest-first.
   This is the **direct-msgSend** framework set 050/070's startup pass re-`dlopen`s
   after a dump: a `save-lisp-and-die` core keeps these STRINGS but loses the live
   `dlopen` handles (and with them every framework `Class`), so the pass replays the
   list to re-register the classes. The dylib-linked **residual-owning** frameworks
   are NOT here — dyld auto-reopens them with the dylib (ADR-0038 §5), so the Lisp
   pass intentionally owns only the direct set. Plain string data, so it survives the
   dump untouched; re-`dlopen` is idempotent, so any incidental overlap is harmless.")

(defun aw-load-framework (name)
  "`dlopen` the system framework NAME (its base name, e.g. \"Foundation\") so its
   ObjC classes become resolvable. Idempotent — dyld refcounts the handle. Records
   NAME in `*loaded-frameworks*` so 050/070's startup pass can re-`dlopen` it after a
   `save-lisp-and-die` (the live handle does not survive the dump; the name does)."
  (sb-alien:load-shared-object
   (format nil "/System/Library/Frameworks/~A.framework/~A" name name))
  (pushnew name *loaded-frameworks* :test #'string=)
  name)

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

(defvar *subclass-instances* (make-hash-table)
  "Synthesized-instance `id` (as int) -> the typed CLOS instance (a STRONG back-ref).
   Defined here (the seam) so `aw-wrap` is authoritative for synthesized instances;
   POPULATED by 050/040's subclass construction. Lets every wrap site (the forwarding
   dispatcher, a trampoline `id` return, a covariant method return) recover the SAME
   typed instance — with its Lisp slots + methods — instead of a fresh borrowed shell.")

(defvar *release-finalizer-installer* nil
  "nil until 050/050's lifetime layer installs a function (instance -> ) that registers
   the main-thread release finalizer on a +1-owned wrap (ADR-0036). Defined here (the
   seam) so `aw-wrap` stays the single wrap site that arms lifetime; POPULATED by
   lifetime.lisp's `aw-register-release`. nil keeps the 020 seam smoke finalizer-free —
   the same seam-defines-hook / leaf-populates pattern as `*subclass-instances*`.")

;;; ---------------------------------------------------------------------------
;;; Startup re-resolution hooks (050/070). The 070 pass owns the ObjC identity
;;; re-resolution itself (frameworks, `objc_msgSend`, every `Class`/`SEL`); every
;;; OTHER subsystem that caches a live foreign pointer across a dump registers a
;;; "drop my stale foreign state" thunk here, so the pass need not know each
;;; subsystem's internals. Same seam-defines-hook / leaf-populates pattern as the
;;; two hooks above — defined at the seam, populated by the owning leaf
;;; (lifetime.lisp's release queue, subclass.lisp's synthesized-class caches,
;;; threading.lisp's dylib dispatcher registration).
;;; ---------------------------------------------------------------------------

(defvar *startup-reresolve-hooks* '()
  "An alist (name . thunk) of subsystem reset thunks the 050/070 startup pass runs
   AFTER its own ObjC re-resolution. Keyed by name so a re-load replaces rather than
   duplicates. Each thunk drops one subsystem's stale-across-dump foreign state.")

(defun aw-register-startup-hook (name thunk)
  "Register (or replace, by NAME) a subsystem reset THUNK the 050/070 startup pass
   runs. Idempotent in NAME so reloading a runtime unit does not stack duplicates."
  (setf *startup-reresolve-hooks*
        (cons (cons name thunk)
              (remove name *startup-reresolve-hooks* :key #'car))))

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
   RETAINED t marks the `id` as already +1 (init/copy/new families, copy properties),
   so the wrap TAKES that ownership and (once 050/050 installs the hook) arms a
   main-thread release finalizer to balance it (ADR-0036). RETAINED nil is a +0
   autoreleased transient: the wrap owns nothing — the entry-point pool drains it — so
   no finalizer is armed."
  (if (aw-null-sap-p id-sap)
      nil
      ;; A synthesized instance resolves to its STRONG back-ref (preserving its Lisp
      ;; slots + methods, and already lifetime-managed by 040 — never re-armed here);
      ;; any other `id` builds a fresh shell on its bound class.
      (or (gethash (sb-sys:sap-int id-sap) *subclass-instances*)
          (let ((instance (make-instance (aw-resolve-bound-class id-sap) :ptr id-sap)))
            (when (and retained *release-finalizer-installer*)
              (funcall *release-finalizer-installer* instance))
            instance))))

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
