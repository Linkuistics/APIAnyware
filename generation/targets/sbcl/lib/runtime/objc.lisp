;;;; runtime/objc.lisp — the MOP object model: ObjC projected into CLOS through
;;;; `sb-mop` (ADR-0034 §1-5). Leaf 050/030 — the headline.
;;;;
;;;; Not a single wrapper class (gerbil pre-rejected as "vacuous", ADR-0018), not a
;;;; manifest `defclass` graph WITHOUT the MOP (gerbil's shape, ADR-0020) — a real
;;;; metaobject projection: every bound ObjC class is a CLOS class of the `objc-class`
;;;; metaclass, dispatch rides the reified class graph, ivars are foreign slots. All
;;;; the `sb-mop` hooks this needs were verified to exist + specialize FIRST-HAND on
;;;; SBCL 2.6.5/arm64 (the design spikes 1/3/4); this leaf WIRES them, never re-spikes.
;;;;
;;;; This sits on 050/020's seam (`aw-class`/`aw-sel`/`aw-ptr`/`aw-wrap` + the
;;;; `+objc-msgsend+` dispatch shape + `*objc-class-registry*`). It owns the metaclass,
;;;; the root, the foreign-slot mechanism, and `make-instance` -> alloc/init. Lifetime
;;;; (the retain + finalizer on a wrapped +1) is 050/050 — here `aw-wrap` is the 020
;;;; stub (resolve + construct, no finalizer yet).

(in-package #:apianyware-sbcl-impl)

;;; ===========================================================================
;;; The `objc-class` metaclass (ADR-0034 §1, spike 1-amop-conformance).
;;; ===========================================================================

(defclass objc-class (standard-class)
  ((objc-name
    :initform nil :accessor objc-class-name-string
    :documentation "The ObjC class name string (e.g. \"NSString\"), set by
                    `register-objc-class`. Backs `aw-class` lookup + 050/070 re-resolution.")
   (objc-super-name
    :initform nil :accessor objc-class-super-name
    :documentation "The ObjC superclass name string, or nil for an ObjC root. Backs the
                    040 subclass-synthesis bridge (retained here for it).")
   (class-sap
    :initform nil :accessor objc-class-cached-sap
    :documentation "The live `Class` SAP, cached lazily / re-resolved by 050/070."))
  (:documentation
   "The metaclass backing every bound ObjC class. A `standard-class` subclass so the
    full CLOS machinery (dispatch, method combination, `call-next-method`) applies
    over a class graph that mirrors the ObjC one."))

;; `objc-class` is itself a `standard-class` subclass, so an `objc-class` SUPER also
;; matches `(super standard-class)` here — one method covers the plain root
;; `ns:ns-object` AND `objc-class`-to-`objc-class` chaining. (spike 1.)
(defmethod validate-superclass ((class objc-class) (super standard-class))
  t)

;;; ===========================================================================
;;; Foreign ivar slots (ADR-0034 §4, spike 3-slot-mechanism).
;;;
;;; An OPT-IN fast path: a slot spec `(<name> :offset <BITS> :ctype <:kw>)` reads the
;;; ivar straight out of the ObjC object at the baked bit-offset; a plain slot (no
;;; `:offset`, e.g. the `ptr` handle) falls through to standard CLOS storage. The IR
;;; surfaces no ivar layout yet, so the table is EMPTY in practice — this wires the
;;; mechanism + proves the empty-table path is inert. Open item §8 (SDK drift): a
;;; baked offset is SDK-version-sensitive; mitigate by re-resolving via `ivar_getOffset`
;;; at startup or pinning the SDK — the accessor-selector method path is the always-safe
;;; default, so foreign slots are never on the critical path.
;;; ===========================================================================

(defclass objc-direct-slot (standard-direct-slot-definition)
  ((offset :initarg :offset :reader slot-offset)
   (ctype  :initarg :ctype  :reader slot-ctype)))

(defclass objc-effective-slot (standard-effective-slot-definition)
  ((offset :accessor slot-offset)   ; unbound => plain Lisp slot (falls through)
   (ctype  :accessor slot-ctype)))

(defmethod direct-slot-definition-class ((class objc-class) &rest initargs)
  ;; A `:offset` in the slug spec marks a foreign ivar slot.
  (if (getf initargs :offset)
      (find-class 'objc-direct-slot)
      (call-next-method)))

(defmethod effective-slot-definition-class ((class objc-class) &rest initargs)
  (declare (ignore initargs))
  (find-class 'objc-effective-slot))

(defmethod compute-effective-slot-definition ((class objc-class) name dsds)
  (declare (ignore name))
  (let ((eslot (call-next-method))
        (dslot (find-if (lambda (d) (typep d 'objc-direct-slot)) dsds)))
    (when dslot
      (setf (slot-offset eslot) (slot-offset dslot)
            (slot-ctype eslot)  (slot-ctype dslot)))
    eslot))

(declaim (inline foreign-slot-p))
(defun foreign-slot-p (eslot)
  "True when EFFECTIVE-SLOT carries a baked `:offset` (a foreign ivar), false for a
   plain Lisp slot like `ptr`."
  (slot-boundp eslot 'offset))

(defun %foreign-slot-ref (sap eslot)
  (let ((byte (truncate (slot-offset eslot) 8)))   ; bit offset -> byte (spike 3)
    (ecase (slot-ctype eslot)
      (:bool   (/= 0 (sb-sys:sap-ref-8 sap byte)))
      (:char   (sb-sys:signed-sap-ref-8 sap byte))
      (:short  (sb-sys:signed-sap-ref-16 sap byte))
      (:int    (sb-sys:signed-sap-ref-32 sap byte))
      (:long   (sb-sys:signed-sap-ref-64 sap byte))
      (:float  (sb-sys:sap-ref-single sap byte))
      (:double (sb-sys:sap-ref-double sap byte)))))

(defun (setf %foreign-slot-ref) (new sap eslot)
  (let ((byte (truncate (slot-offset eslot) 8)))
    (ecase (slot-ctype eslot)
      (:bool   (setf (sb-sys:sap-ref-8 sap byte) (if new 1 0)))
      (:char   (setf (sb-sys:signed-sap-ref-8 sap byte) new))
      (:short  (setf (sb-sys:signed-sap-ref-16 sap byte) new))
      (:int    (setf (sb-sys:signed-sap-ref-32 sap byte) new))
      (:long   (setf (sb-sys:signed-sap-ref-64 sap byte) new))
      (:float  (setf (sb-sys:sap-ref-single sap byte) new))
      (:double (setf (sb-sys:sap-ref-double sap byte) new)))
    new))

(defmethod slot-value-using-class ((class objc-class) instance (eslot objc-effective-slot))
  (if (foreign-slot-p eslot)
      (%foreign-slot-ref (slot-value instance 'ptr) eslot)
      (call-next-method)))

(defmethod (setf slot-value-using-class) (new (class objc-class) instance
                                          (eslot objc-effective-slot))
  (if (foreign-slot-p eslot)
      (setf (%foreign-slot-ref (slot-value instance 'ptr) eslot) new)
      (call-next-method)))

;;; ===========================================================================
;;; The runtime-owned root `ns:ns-object` (ADR-0034 §1).
;;;
;;; A PLAIN `standard-class` (its metaclass-backed subclasses are `objc-class`). It
;;; carries the foreign `ptr` slot — the ObjC `id`, the only state every bound object
;;; holds. Never emitted by 040: every emitted `defclass` roots on it (`ns:ns-object`,
;;; single-colon), so the name must be EXTERNAL in the `ns` package before any
;;; generated file reads it — interned + exported here first.
;;; ===========================================================================

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export (intern "NS-OBJECT" '#:ns) '#:ns))

(defclass ns::ns-object ()
  ((ptr :initarg :ptr :initform nil :reader ns-object-ptr
        :documentation "The raw ObjC `id` SAP. `aw-ptr` reads it; `aw-wrap` sets it."))
  (:documentation "The runtime-owned root of the bound class graph (ADR-0034 §1)."))

;;; ===========================================================================
;;; The baked tables 040 emits + the runtime consumes (node BRIEF, BAKED TABLES).
;;; ===========================================================================

(defvar *objc-init-registry* (make-hash-table :test 'eq)
  "Bound CLOS class -> a list of (init-selector-string . (keyword …)) entries, the
   `make-instance` alloc/init initarg mapping. Populated by `register-objc-init`.")

(defun register-objc-class (clos-name objc-name objc-super-name)
  "Record a bound class (node BRIEF): stamp the metaclass metadata + add the
   `*objc-class-registry*` entry `aw-wrap` resolves through + the Class string-table
   entry 050/070's startup pass re-resolves. An empty super string = an ObjC root /
   a synthesized bare node. Called at load of each generated class file."
  (let ((class (find-class clos-name)))
    (when (typep class 'objc-class)
      (setf (objc-class-name-string class) objc-name
            (objc-class-super-name class)
            (if (string= objc-super-name "") nil objc-super-name)))
    (setf (gethash objc-name *objc-class-registry*) class)
    class))

(defmacro register-objc-init (clos-name init-selector keywords &optional applier)
  "Record one explicit ObjC `init` selector for CLOS-NAME (node BRIEF): its selector
   string + one keyword per selector component (the data `make-instance` maps initargs
   through) + an optional **typed applier** closure (ADR-0040, 060/010). `init` itself
   needs no entry — the bare alloc/init default covers it.

   A MACRO, not a function: the runtime contract emits KEYWORDS as an UNQUOTED literal
   list `(:kw …)` (a `defclass`-style data clause), so a function would try to *call*
   `(:init-with-frame)`. The macro quotes that literal data; CLOS-NAME is spliced (the
   emitter writes it `'ns:<cls>`) and the selector is a string. APPLIER is NOT quoted —
   it is a `(lambda (alloced args) …)` the emitter renders with the init's literal
   `sb-alien` argument types (an `alien-funcall` needs compile-time types, so the typed
   crossing cannot be built from runtime data). The entry is `(selector keywords applier)`;
   APPLIER is nil for a legacy 3-arg form (hand-authored smoke fixtures), which then take
   the 0/1-arg id fallback in `aw-apply-init`."
  `(push (list ,init-selector ',keywords ,applier)
         (gethash (find-class ,clos-name) *objc-init-registry*)))

;; `NSObject` is runtime-owned (the emitter never registers `ns:ns-object`), so seed
;; the registry here — the `aw-wrap` superclass-walk always bottoms out in a bound type.
(setf (gethash "NSObject" *objc-class-registry*) (find-class 'ns::ns-object))

;;; ===========================================================================
;;; `define-objc-constant` — the bound-constant surface (contract §3, emitted by
;;; `emit_constants` / the constant-trampoline residual into every `constants.lisp`).
;;;
;;; A generated `constants.lisp` reads each global ONCE at load through its emitter-
;;; chosen foreign read: an `(aw-wrap (sb-alien:extern-alien "Sym" …))` object, an
;;; `(aw-swift-string-result …)` Swift-native string, an `(aw-make-nsstring …)` macro
;;; literal, or a bare scalar `extern-alien`. The macro is `defparameter`, NOT
;;; `defconstant`: the value is a LIVE foreign read (a SAP-backed instance, a freshly
;;; bridged string), so it is neither compile-time-constant nor `eql`-stable across
;;; reloads — `defconstant` would error on the second load. An object/SAP-backed
;;; constant is stale across a `save-lisp-and-die` dump (its foreign pointer — e.g. a
;;; framework `NSString *` notification name — dies with the generating process). The
;;; macro therefore ALSO registers a re-evaluator: the value form is re-runnable, so
;;; the mandatory startup pass (startup.lisp) re-derives the constant surface in a
;;; revived image, AFTER frameworks are re-`dlopen`ed. (060/pdfkit-viewer-k31 — the
;;; first ladder app to need a framework string constant, `PDFViewPageChangedNotification`,
;;; inside a dumped image — surfaced this; previously deferred to 070-distribution.) The
;;; re-eval is inert for a dev `sbcl --load` / the 080 integration smoke: `*init-hooks*`
;;; ran at boot before any constant registered, and the load-time read is already exact.
;;; ===========================================================================

(defvar *objc-constant-reresolvers* '()
  "An alist (NAME . THUNK) of `define-objc-constant` re-evaluators. Each THUNK re-runs
   the constant's foreign value form and re-`setf`s its `defparameter`, so an object/
   SAP-backed constant is re-derived from the live (re-`dlopen`ed) framework in a revived
   `save-lisp-and-die` image rather than holding a pointer into the dead generating
   process. Populated as `constants.lisp` files load; replayed by the startup pass.
   Keyed by NAME so a re-load replaces rather than duplicates.")

(defmacro define-objc-constant (name value-form)
  "Bind the `ns:`-qualified constant NAME to VALUE-FORM, read once at load, AND register
   a re-evaluator (see the section comment) so the startup pass re-derives NAME in a
   revived dumped image. A `defparameter` over the emitter's foreign read (object /
   string / scalar). Returns NAME so a generated file's toplevel reads cleanly."
  `(progn
     (defparameter ,name ,value-form)
     (setf *objc-constant-reresolvers*
           (cons (cons ',name (lambda () (setf ,name ,value-form)))
                 (remove ',name *objc-constant-reresolvers* :key #'car)))
     ',name))

(defun aw-reresolve-objc-constants ()
  "Re-run every registered `define-objc-constant` value form, re-`setf`ing its
   `defparameter`. The startup pass runs this AFTER frameworks are re-`dlopen`ed (so the
   `extern-alien` globals resolve). Each re-eval is guarded: a constant whose symbol no
   longer resolves keeps its (stale) baked value rather than killing the image —
   mirroring `aw-reresolve-classes`'s skip-on-miss. Empty (inert) until a `constants.lisp`
   loads, so a residual-free app pays nothing."
  (dolist (entry *objc-constant-reresolvers*)
    (handler-case (funcall (cdr entry))
      (error (e)
        (warn "aw: constant ~A failed to re-resolve at startup: ~A" (car entry) e)))))

(aw-register-startup-hook :objc-constants (lambda () (aw-reresolve-objc-constants)))

;;; ===========================================================================
;;; `make-instance` -> alloc/init (contract §3.3, ADR-0034 §5).
;;;
;;; Realized as a metaclass `make-instance` method (not `allocate-instance`): it cleanly
;;; separates the two callers — `aw-wrap` building a shell around an EXISTING id vs an
;;; app CONSTRUCTING a new ObjC object — and keeps an explicit-init's foreign initargs
;;; from leaking into CLOS slot initialization. (spike 4 proved `allocate-instance` is
;;; reachable as the hook; this routes through the same metaclass, the ADR's intent.)
;;; ===========================================================================

(declaim (inline %msgsend-id-0 %msgsend-id-1))

(defun %msgsend-id-0 (receiver sel)
  "`id (id, SEL)` — the 0-arg id-returning objc_msgSend (alloc / init / new)."
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   receiver sel))

(defun %msgsend-id-1 (receiver sel arg)
  "`id (id, SEL, id)` — the 1-arg id-arg id-returning objc_msgSend (initWith<Obj>:)."
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   receiver sel arg))

(defun init-keys-match-p (registered-keys supplied-keys)
  "True when the REGISTERED keyword list (a selector's components) is exactly the set
   of SUPPLIED initarg keys (order-independent)."
  (null (set-exclusive-or registered-keys supplied-keys)))

(defun aw-apply-init (class alloced initargs)
  "Map INITARGS (a plist) to a registered explicit init + send it on ALLOCED, returning
   the raw +1 `id` (the caller wraps). The matched entry's **typed applier** (ADR-0040)
   performs the crossing — it carries the init's literal `sb-alien` arg types, so it
   handles ANY arity + by-value structs / scalars / bools / ids (e.g. NSWindow's
   `initWithContentRect:styleMask:backing:defer:`). A legacy entry with no applier (nil —
   hand-authored smoke fixtures) falls back to the 0/1-arg id path."
  (let* ((keys (loop for (k nil) on initargs by #'cddr collect k))
         (entry (find-if (lambda (e) (init-keys-match-p (second e) keys))
                         (gethash class *objc-init-registry*))))
    (unless entry
      (error "make-instance: ~S has no registered init for initargs ~S"
             (class-name class) keys))
    (destructuring-bind (selector kw-list applier) entry
      (if applier
          (funcall applier alloced initargs)
          (let ((sel (aw-sel selector)))
            (ecase (length kw-list)
              (0 (%msgsend-id-0 alloced sel))
              (1 (%msgsend-id-1 alloced sel (aw-ptr (getf initargs (first kw-list)))))))))))

(defun aw-alloc-init (class initargs)
  "`alloc` an instance of CLASS's ObjC class then send its init selector; return the
   raw +1 `id`. No initargs -> bare `-init`. Initargs -> the registered explicit init."
  (let* ((objc-cls (aw-class (or (objc-class-name-string class)
                                 (error "make-instance: ~S carries no ObjC name — no ~
                                         `register-objc-class` form loaded?"
                                        (class-name class)))))
         (alloced (%msgsend-id-0 objc-cls (aw-sel "alloc"))))
    (if (null initargs)
        (%msgsend-id-0 alloced (aw-sel "init"))
        (aw-apply-init class alloced initargs))))

(defmethod make-instance ((class objc-class) &rest initargs
                          &key (ptr nil ptr-supplied) &allow-other-keys)
  "Contract §3.3, two modes keyed on a `:ptr` initarg:
   - `:ptr` supplied -> WRAP an existing `id` (the `aw-wrap` path): standard CLOS make.
   - no `:ptr`       -> CONSTRUCT: ObjC `alloc` + the (mapped) `init`, then wrap the +1."
  (declare (ignore ptr))
  (if ptr-supplied
      (call-next-method)
      (aw-wrap (aw-alloc-init class initargs) t)))
