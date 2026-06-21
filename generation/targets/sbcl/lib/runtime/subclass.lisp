;;;; runtime/subclass.lisp — ObjC subclass synthesis + protocol conformance
;;;; (ADR-0034 §5, ADR-0038 §4, contract §3.4/§3.5). Leaf 050/040.
;;;;
;;;; *Deriving in CLOS = deriving in ObjC.* `define-objc-subclass` defines a CLOS
;;;; class whose `objc-class` effective class IS a real ObjC subclass — synthesized
;;;; via `objc_allocateClassPair` / `objc_registerClassPair`, driven Lisp-side with
;;;; `sb-alien` (lifted from spike 4-subclass-synthesis). `define-objc-method`
;;;; overrides a framework selector with a CLOS `defmethod`; the macOS frameworks
;;;; dispatch their callbacks into that method. Conformance to a real ObjC protocol
;;;; (`:protocols`) is `class_addProtocol` + per-selector IMP install, reading each
;;;; method's ABI signature from the LIVE protocol (`protocol_copyMethodDescription…`)
;;;; — "the runtime drives conformance" (040 bakes only names).
;;;;
;;;; ## The IMP is the dylib's bounce-shim, NEVER a raw `define-alien-callable`
;;;;
;;;; A `define-alien-callable` installed AS an IMP would run Lisp on whatever (foreign)
;;;; thread the framework calls back on — the GC-unsafe attachment the ADR-0035 spike
;;;; crashed on 5/5. So per overridden selector we install libobjc's `_objc_msgForward`
;;;; (via the dylib's `aw_sbcl_subclass_add_forward`); the dylib's `forwardInvocation:`
;;;; override BOUNCES TO MAIN (CallbackBounce) and only THEN calls back into this
;;;; runtime's ONE dispatcher (`aw-forward-dispatcher`) — on the main thread, GC-safe.
;;;; The dispatcher IS a `define-alien-callable`, but it is invoked post-bounce on main,
;;;; not handed to libobjc as an IMP. DO NOT "simplify" by class_addMethod-ing a
;;;; `define-alien-callable` directly — that reintroduces the ADR-0035 crash.
;;;;
;;;; Sits on 050/020's seam (`aw-class`/`aw-sel`/`aw-ptr`/`aw-wrap`, `+objc-msgsend+`,
;;;; the registries) + 050/030's metaclass (`objc-class`, `make-instance`). The bounce
;;;; shim + NSInvocation forwarding half is 050/010's `SubclassSynth.swift`; this is the
;;;; Lisp driver that installs into it. Super-chaining is explicit `call-super` /
;;;; `call-super-id` (objc_msgSendSuper), matching the racket/gerbil precedent — CLOS
;;;; `call-next-method` cannot mean ObjC-super (a bound method sends `objc_msgSend` to
;;;; SELF, which re-enters this forwarding path → infinite recursion).

(in-package #:apianyware-sbcl-impl)

;;; ===========================================================================
;;; libobjc class-pair + protocol + super primitives (always-mapped libobjc).
;;; `objc_getClass`/`object_getClass`/`class_getSuperclass`/`class_getName`/
;;; `sel_registerName`/`sel_getName` are already in ffi.lisp — reused, not redefined.
;;; ===========================================================================

(sb-alien:define-alien-routine ("objc_allocateClassPair" %objc-allocate-class-pair)
    sb-alien:system-area-pointer
  (superclass sb-alien:system-area-pointer)
  (name sb-alien:c-string)
  (extra sb-alien:size-t))

(sb-alien:define-alien-routine ("objc_registerClassPair" %objc-register-class-pair)
    sb-alien:void
  (cls sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("objc_getProtocol" %objc-get-protocol)
    sb-alien:system-area-pointer
  (name sb-alien:c-string))

(sb-alien:define-alien-routine ("class_addProtocol" %class-add-protocol)
    sb-alien:char                       ; BOOL (signed char)
  (cls sb-alien:system-area-pointer)
  (protocol sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("class_conformsToProtocol" %class-conforms-to-protocol)
    sb-alien:char                       ; BOOL
  (cls sb-alien:system-area-pointer)
  (protocol sb-alien:system-area-pointer))

;; Returns a malloc'd C array of `objc_method_description {SEL name; char *types}`
;; (two pointers, 16 bytes each), or NULL; `*out-count` is filled. We read it by hand
;; (sap-ref) to dodge an arm64 by-value-struct return; `free` releases it.
(sb-alien:define-alien-routine ("protocol_copyMethodDescriptionList" %protocol-copy-method-descriptions)
    sb-alien:system-area-pointer
  (protocol sb-alien:system-area-pointer)
  (required sb-alien:char)
  (instance sb-alien:char)
  (out-count (sb-alien:* sb-alien:unsigned-int)))

;; The inherited method (searches superclasses) — encoding source for an OVERRIDE of
;; a framework selector not declared in a conformed protocol.
(sb-alien:define-alien-routine ("class_getInstanceMethod" %class-get-instance-method)
    sb-alien:system-area-pointer
  (cls sb-alien:system-area-pointer)
  (sel sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("method_getTypeEncoding" %method-get-type-encoding)
    sb-alien:c-string
  (method sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("free" %libc-free)
    sb-alien:void
  (ptr sb-alien:system-area-pointer))

;; Size (bytes) of an ObjC type encoding — sizes the NSInvocation arg/return buffers.
(sb-alien:define-alien-routine ("NSGetSizeAndAlignment" %ns-get-size-and-alignment)
    sb-alien:system-area-pointer
  (enc sb-alien:c-string)
  (sizep (sb-alien:* sb-alien:unsigned-long))
  (alignp (sb-alien:* sb-alien:unsigned-long)))

(defun aw-encoding-size (enc)
  "Byte size of ObjC type-encoding string ENC (via `NSGetSizeAndAlignment`)."
  (sb-alien:with-alien ((sz sb-alien:unsigned-long)
                        (al sb-alien:unsigned-long))
    (%ns-get-size-and-alignment enc (sb-alien:addr sz) (sb-alien:addr al))
    sz))

(defun aw-sap->string (sap)
  "A non-null `char*` SAP -> a Lisp string; null -> nil."
  (unless (aw-null-sap-p sap)
    (sb-alien:cast (sb-alien:sap-alien sap (sb-alien:* sb-alien:char)) sb-alien:c-string)))

;;; ===========================================================================
;;; The two `SubclassSynth.swift` dylib entries (ADR-0038 §4) — bound via sb-alien.
;;; `aw_sbcl_subclass_register_dispatcher` registers our ONE forwarding dispatcher;
;;; `aw_sbcl_subclass_add_forward` installs `_objc_msgForward` for one selector + the
;;; two NSObject forwarding-hook IMPs on the class (idempotent per class).
;;; ===========================================================================

(sb-alien:define-alien-routine ("aw_sbcl_subclass_register_dispatcher" %aw-register-dispatcher)
    sb-alien:void
  (dispatcher sb-alien:system-area-pointer))

(sb-alien:define-alien-routine ("aw_sbcl_subclass_add_forward" %aw-subclass-add-forward)
    sb-alien:void
  (cls sb-alien:system-area-pointer)
  (sel sb-alien:system-area-pointer)
  (types sb-alien:c-string))

;;; ===========================================================================
;;; Registries (the dispatch table + the synthesized-class / instance back-refs).
;;; ===========================================================================

(defvar *synth-classes* (make-hash-table :test 'eq)
  "Bound CLOS subclass object -> its live synthesized `Class` SAP. Marks a class as
   Lisp-synthesized (vs an emitted bound class), keys instance back-ref recording, and
   carries the `Class` `define-objc-method` adds IMPs to.")

;; The synthesized-instance back-ref `*subclass-instances*` is defined in ffi.lisp (the
;; seam, so `aw-wrap` is authoritative for synth instances) and POPULATED here at
;; construction. Strong + unpruned: a synthesized instance (custom view/delegate, few +
;; app-lifetime) is retained for the process — the gerbil ADR-0019 model.
;; `setDelegate:`/`target` do NOT retain, so the app must anyway keep it reachable; a
;; `dealloc`-driven reclaim is the natural future refinement (050/050).

(defvar *override-table* (make-hash-table :test 'equal)
  "(synth-Class-SAP-int . selector-string) -> the `ns:` generic-function NAME (a
   symbol) the forwarding dispatcher routes the call through. CLOS then dispatches to
   the subclass's `defmethod`. This IS the node BRIEF's \"dispatch table keyed by
   (synthesized-class . selector) -> Lisp closure the shim consults\".")

(defvar *subclass-protocols* (make-hash-table :test 'eq)
  "Bound CLOS subclass object -> list of conformed `Protocol` SAPs. The encoding source
   `define-objc-method` reads live (`protocol_copyMethodDescriptionList`) for a
   protocol method.")

(defvar *subclass-counter* 0
  "Monotonic suffix making each synthesized ObjC class name unique within the process.")

;; 050/070 startup reset: every synthesized `Class` pair was `objc_allocateClassPair`ed
;; in the GENERATING process and does not survive a dump — and these tables are keyed on
;; (or hold) its now-stale `Class`/`Protocol`/instance SAPs. Clearing them lets the app's
;; `define-objc-subclass` toplevel re-synthesize cleanly in the revived image (without the
;; clear, `aw-synthesize-subclass` would early-return the stale pair). Counter back to 0 so
;; the re-minted ObjC names match the pre-dump run. The matching `*objc-class-registry*`
;; synth entries are left inert (their old names `objc_getClass` to null, so they never
;; resolve; re-synthesis adds fresh ones).
(aw-register-startup-hook
 :synthesized-classes
 (lambda ()
   (clrhash *synth-classes*)
   (clrhash *override-table*)
   (clrhash *subclass-protocols*)
   (clrhash *subclass-instances*)
   (setf *subclass-counter* 0)))

;;; ===========================================================================
;;; Baked protocol table consumption (`register-objc-protocol`, emitted by 040/030).
;;; The runtime reads ABI signatures LIVE; this table only records the selector<->
;;; generic mapping + the required/optional split for app introspection.
;;; ===========================================================================

(defvar *objc-protocol-registry* (make-hash-table :test 'equal)
  "ObjC protocol name -> a plist (:required ((sel . generic)…) :optional (…)). Baked by
   `emit_protocol` (040/030); names only — never ABI signatures.")

(defmacro register-objc-protocol (objc-name &key required optional)
  "Record a bound ObjC protocol (node BRIEF): its required/optional (selector `ns:`
   generic) pairs. Consumed for selector<->generic lookup; the conformance machinery
   reads each method's encoding from the LIVE protocol, not from here.

   A MACRO, not a function: the node BRIEF's runtime contract emits the required/optional
   pair lists UNQUOTED `((sel ns:gen) …)`, so a function would try to *call*
   `(\"copyWithZone:\" ns:copy-with-zone)`. The macro quotes the literal data; OBJC-NAME
   is a string the emitter writes literally."
  `(progn
     (setf (gethash ,objc-name *objc-protocol-registry*)
           (list :required ',required :optional ',optional))
     ,objc-name))

;;; ===========================================================================
;;; selector <-> `ns:` generic name (the emitter's naming convention, the slice we
;;; need: strip colons, camelCase -> kebab-case). Used to name the `defmethod`'s
;;; generic when `define-objc-method` is given the literal ObjC selector string.
;;; ===========================================================================

(defun aw-selector->generic-name (selector)
  "ObjC SELECTOR string (e.g. \"drawRect:\", \"tableView:objectValueForColumn:\") ->
   the `ns:` generic-function symbol (e.g. `ns:draw-rect`). Drops colons; inserts a
   hyphen before each interior uppercase run; downcases. The emitter's full naming uses
   an acronym table; this is the colon/kebab slice `define-objc-method` needs and is
   stable for the override + delegate selectors a subclass implements."
  (let ((out (make-string-output-stream))
        (prev-lower nil))
    (loop for ch across selector
          do (cond
               ((char= ch #\:) (setf prev-lower nil))   ; selector-part boundary
               ((upper-case-p ch)
                (when prev-lower (write-char #\- out))
                (write-char (char-downcase ch) out)
                (setf prev-lower nil))
               (t (write-char ch out)
                  (setf prev-lower t))))
    (intern (string-upcase (get-output-stream-string out)) '#:ns)))

;;; ===========================================================================
;;; The ONE forwarding dispatcher (ADR-0034 §5, ADR-0035). Invoked by the dylib's
;;; `forwardInvocation:` AFTER it has bounced to the main thread — so entering Lisp
;;; here is GC-safe. Reads the call's ABI shape LIVE off the `NSInvocation`'s
;;; `NSMethodSignature`, marshals args, routes through the `ns:` generic (CLOS picks
;;; the subclass method), marshals the return back.
;;; ===========================================================================

;; objc_msgSend shapes the dispatcher needs to drive NSInvocation / NSMethodSignature
;; (all id-receiver). Cast off `+objc-msgsend+` per the ffi.lisp seam.
(declaim (inline %inv-selector %inv-method-signature %sig-num-args
                 %sig-arg-type %sig-return-type %inv-get-argument %inv-set-return))

(defun %inv-selector (inv)              ; [inv selector] -> SEL
  (%msgsend-id-0 inv (aw-sel "selector")))

(defun %inv-method-signature (inv)      ; [inv methodSignature] -> NSMethodSignature
  (%msgsend-id-0 inv (aw-sel "methodSignature")))

(defun %sig-num-args (sig)              ; [sig numberOfArguments] -> NSUInteger
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:unsigned-long
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   sig (aw-sel "numberOfArguments")))

(defun %sig-arg-type (sig idx)         ; [sig getArgumentTypeAtIndex:idx] -> char*
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:c-string
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:unsigned-long))
   sig (aw-sel "getArgumentTypeAtIndex:") idx))

(defun %sig-return-type (sig)          ; [sig methodReturnType] -> char*
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:c-string
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   sig (aw-sel "methodReturnType")))

(defun %inv-get-argument (inv buf idx) ; [inv getArgument:buf atIndex:idx]
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:void
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:long))
   inv (aw-sel "getArgument:atIndex:") buf idx))

(defun %inv-set-return (inv buf)       ; [inv setReturnValue:buf]
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:void
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   inv (aw-sel "setReturnValue:") buf))

(defun aw-encoding-head (enc)
  "First significant char of ObjC type-encoding ENC, skipping the leading ABI
   qualifiers (`r n N o R V A`). Decides the marshal kind."
  (loop for i below (length enc)
        for ch = (char enc i)
        unless (member ch '(#\r #\n #\N #\o #\R #\V #\A))
          return ch))

(defun aw-read-arg (buf enc)
  "Marshal one argument out of BUF (a SAP holding the bytes `getArgument:` wrote) per
   its ObjC encoding ENC, into a Lisp value. Objects wrap (borrowed: the framework owns
   the arg for the call's duration); a struct is handed back as the raw BUF SAP."
  (case (aw-encoding-head enc)
    ((#\@) (aw-wrap (sb-sys:sap-ref-sap buf 0)))      ; id (borrowed)
    ((#\#) (sb-sys:sap-ref-sap buf 0))                ; Class
    ((#\:) (sb-sys:sap-ref-sap buf 0))                ; SEL
    ((#\^) (sb-sys:sap-ref-sap buf 0))                ; pointer
    ((#\*) (aw-sap->string (sb-sys:sap-ref-sap buf 0))) ; char*
    ((#\B #\c #\C) (/= 0 (sb-sys:sap-ref-8 buf 0)))   ; bool / ObjC BOOL
    ((#\s) (sb-sys:signed-sap-ref-16 buf 0))
    ((#\S) (sb-sys:sap-ref-16 buf 0))
    ((#\i) (sb-sys:signed-sap-ref-32 buf 0))
    ((#\I) (sb-sys:sap-ref-32 buf 0))
    ((#\l #\q) (sb-sys:signed-sap-ref-64 buf 0))      ; long/long-long (LP64: 8 bytes)
    ((#\L #\Q) (sb-sys:sap-ref-64 buf 0))
    ((#\f) (sb-sys:sap-ref-single buf 0))
    ((#\d) (sb-sys:sap-ref-double buf 0))
    (t buf)))                                          ; struct / unknown -> raw SAP

(defun aw-ptr-or-sap (value)
  "VALUE -> an `id` SAP: a bound instance via `aw-ptr`, a raw SAP as-is, nil -> null."
  (cond ((null value) (aw-null-sap))
        ((sb-sys:system-area-pointer-p value) value)
        (t (aw-ptr value))))

(defun aw-write-return (buf enc value)
  "Marshal VALUE back into BUF per the return encoding ENC (for `setReturnValue:`).
   `void` is handled by the caller (no buffer write). A struct return whose VALUE is a
   SAP is left to the caller to copy (rare; the leaf's surface is scalar/object/bool)."
  (case (aw-encoding-head enc)
    ((#\@ #\#) (setf (sb-sys:sap-ref-sap buf 0) (aw-ptr-or-sap value)))
    ((#\: #\^) (setf (sb-sys:sap-ref-sap buf 0) (if value value (aw-null-sap))))
    ((#\B #\c #\C) (setf (sb-sys:sap-ref-8 buf 0) (if value 1 0)))
    ((#\s #\S) (setf (sb-sys:sap-ref-16 buf 0) (logand value #xffff)))
    ((#\i #\I) (setf (sb-sys:sap-ref-32 buf 0) (logand value #xffffffff)))
    ((#\l #\q #\L #\Q) (setf (sb-sys:sap-ref-64 buf 0) (logand value #xffffffffffffffff)))
    ((#\f) (setf (sb-sys:sap-ref-single buf 0) (float value 1.0)))
    ((#\d) (setf (sb-sys:sap-ref-double buf 0) (float value 1.0d0)))
    (t (when (sb-sys:system-area-pointer-p value)     ; struct-by-value return
         (sb-kernel:system-area-ub8-copy value 0 buf 0 (aw-encoding-size enc))))))

(defun aw-dispatch-forwarded (self-sap inv-sap)
  "The body of the forwarding dispatcher. Routes one forwarded ObjC call (already on
   the main thread) into the matching CLOS `defmethod`. Returns nothing; writes the
   ObjC return value back through the NSInvocation."
  (let* ((sel      (%inv-selector inv-sap))
         (sel-name (%sel-get-name sel))
         (cls      (%object-get-class self-sap))
         (gname    (gethash (cons (sb-sys:sap-int cls) sel-name) *override-table*)))
    (unless gname
      (error "aw-forward-dispatcher: no override for ~S on class ~S"
             sel-name (aw-sap->string (%class-get-name cls))))
    (let* ((instance (or (gethash (sb-sys:sap-int self-sap) *subclass-instances*)
                         (aw-wrap self-sap)))         ; fallback: borrowed wrap
           (sig      (%inv-method-signature inv-sap))
           (nargs    (%sig-num-args sig))
           (bufs     '())
           (args     '()))
      (unwind-protect
           (progn
             ;; index 0 = self, 1 = _cmd; real args start at 2.
             (loop for i from 2 below nargs
                   for enc = (%sig-arg-type sig i)
                   for size = (max 8 (aw-encoding-size enc))
                   for buf = (sb-alien:make-alien (sb-alien:unsigned 8) size)
                   for sap = (sb-alien:alien-sap buf)
                   do (push buf bufs)
                      (dotimes (b size) (setf (sb-sys:sap-ref-8 sap b) 0))
                      (%inv-get-argument inv-sap sap i)
                      (push (aw-read-arg sap enc) args))
             (let* ((args (nreverse args))
                    (result (apply (fdefinition gname) instance args))
                    (ret-enc (%sig-return-type sig)))
               (unless (char= (aw-encoding-head ret-enc) #\v)   ; void: nothing to set
                 (let* ((rsize (max 8 (aw-encoding-size ret-enc)))
                        (rbuf  (sb-alien:make-alien (sb-alien:unsigned 8) rsize))
                        (rsap  (sb-alien:alien-sap rbuf)))
                   (push rbuf bufs)
                   (dotimes (b rsize) (setf (sb-sys:sap-ref-8 rsap b) 0))
                   (aw-write-return rsap ret-enc result)
                   (%inv-set-return inv-sap rsap)))))
        (dolist (b bufs) (sb-alien:free-alien b))))))

;; ADR-0035: this `define-alien-callable` is the post-bounce Lisp entry. It is handed
;; to the dylib via `aw_sbcl_subclass_register_dispatcher` and called by
;; `forwardInvocation:` ONLY AFTER the main-thread bounce — it is NEVER class_addMethod'd
;; as an IMP. A toplevel `handler-case` keeps any Lisp error from unwinding into ObjC.
(sb-alien:define-alien-callable aw-forward-dispatcher sb-alien:void
    ((self sb-alien:system-area-pointer)
     (inv  sb-alien:system-area-pointer))
  (handler-case (aw-dispatch-forwarded self inv)
    (error (e)
      (format *error-output* "~&aw-forward-dispatcher: ~A~%" e))))

(defvar *dispatcher-registered* nil)

(defun aw-init-subclass-dispatcher ()
  "Register our ONE forwarding dispatcher with the dylib (idempotent). Must run once
   after `aw-load-native-dylib`, before any synthesized instance receives a forwarded
   selector. 050/070's startup pass calls this; the dev smoke calls it explicitly."
  (unless *dispatcher-registered*
    (%aw-register-dispatcher
     (sb-alien:alien-sap (sb-alien:alien-callable-function 'aw-forward-dispatcher)))
    (setf *dispatcher-registered* t)))

;;; ===========================================================================
;;; Subclass synthesis (ADR-0034 §5, lifted from spike 4-subclass-synthesis).
;;; ===========================================================================

(defun aw-class-objc-name (clos-class)
  "The ObjC class name backing CLOS-CLASS: the metaclass slot for an `objc-class`
   (an emitted bound class or a synthesized subclass), or \"NSObject\" for the plain
   `standard-class` root `ns:ns-object`. nil if the class carries no ObjC identity."
  (cond ((typep clos-class 'objc-class) (objc-class-name-string clos-class))
        ((eq clos-class (find-class 'ns::ns-object)) "NSObject")
        (t nil)))

(defun aw-unique-objc-name (clos-name)
  "A process-unique ObjC class name for a synthesized CLOS class CLOS-NAME — `AW_SBCL_`
   + the CLOS name + a counter, bumped until `objc_getClass` does not already know it."
  (loop for n = (prog1 *subclass-counter* (incf *subclass-counter*))
        for candidate = (format nil "AW_SBCL_~A_~D"
                                (substitute #\_ #\- (string-upcase (symbol-name clos-name))) n)
        when (aw-null-sap-p (%objc-get-class candidate)) return candidate))

(defun aw-synthesize-subclass (clos-class super-objc-name protocol-names)
  "Synthesize the real ObjC subclass backing CLOS-CLASS (a freshly-defined
   `objc-class`): `objc_allocateClassPair` under SUPER-OBJC-NAME, `class_addProtocol`
   each of PROTOCOL-NAMES (conformance declared BEFORE registration), then
   `objc_registerClassPair`. Stamps the metaclass metadata + registers the synthesized
   ObjC name so `aw-class` / `aw-wrap` resolve it. Idempotent: a re-eval of the
   `defclass` reuses the already-synthesized class."
  (let ((existing (gethash clos-class *synth-classes*)))
    (when existing (return-from aw-synthesize-subclass existing)))
  (let ((super (aw-class super-objc-name))
        (objc-name (aw-unique-objc-name (class-name clos-class))))
    (when (aw-null-sap-p super)
      (error "define-objc-subclass: ObjC superclass ~S not found (framework loaded?)"
             super-objc-name))
    (let ((pair (%objc-allocate-class-pair super objc-name 0)))
      (when (aw-null-sap-p pair)
        (error "define-objc-subclass: objc_allocateClassPair failed for ~S" objc-name))
      ;; conformance is declared on the un-registered pair (the safe ordering).
      (let ((protos '()))
        (dolist (pname protocol-names)
          (let ((proto (%objc-get-protocol pname)))
            (when (aw-null-sap-p proto)
              (error "define-objc-subclass: protocol ~S not found (framework loaded?)" pname))
            (%class-add-protocol pair proto)
            (push proto protos)))
        (setf (gethash clos-class *subclass-protocols*) (nreverse protos)))
      (%objc-register-class-pair pair)
      ;; metaclass metadata + registry, so make-instance/aw-class/aw-wrap resolve it.
      (setf (objc-class-name-string clos-class) objc-name
            (objc-class-super-name clos-class) super-objc-name
            (objc-class-cached-sap clos-class) pair
            (gethash objc-name *objc-class-registry*) clos-class
            (gethash objc-name *class-cache*) pair
            (gethash clos-class *synth-classes*) pair)
      pair)))

;; Construct a synthesized-subclass instance, and record its back-reference so the
;; forwarding dispatcher recovers the SAME typed instance (with its Lisp slots) rather
;; than a fresh borrowed wrap. A synthesized class carries BOTH an ObjC object and
;; Lisp-side CLOS slots, so its construction differs from a bound class's
;; alloc/init-keyword mapping (objc.lisp): bare `alloc`/`init` the ObjC object, then do
;; standard CLOS make with the Lisp initargs + the fresh `ptr`. (Explicit ObjC inits on
;; a user subclass — rare — are deferred; the inherited bare init covers the common
;; delegate/view case.) Only synthesized classes take this branch (`*synth-classes*`);
;; emitted bound classes and the `:ptr` wrap path fall through to objc.lisp.
(defmethod make-instance :around ((class objc-class) &rest initargs
                                  &key (ptr nil ptr-supplied) &allow-other-keys)
  (declare (ignore ptr))
  (cond
    ((and (gethash class *synth-classes*) (not ptr-supplied))
     (let* ((objc-cls (aw-class (objc-class-name-string class)))
            (objptr (%msgsend-id-0 (%msgsend-id-0 objc-cls (aw-sel "alloc")) (aw-sel "init")))
            (inst (apply #'call-next-method class :ptr objptr initargs)))
       (setf (gethash (sb-sys:sap-int objptr) *subclass-instances*) inst)
       inst))
    (t
     (let ((inst (call-next-method)))
       (when (and (gethash class *synth-classes*)
                  (typep inst 'ns::ns-object)
                  (slot-value inst 'ptr)
                  (not (aw-null-sap-p (slot-value inst 'ptr))))
         (setf (gethash (sb-sys:sap-int (slot-value inst 'ptr)) *subclass-instances*) inst))
       inst))))

;;; ===========================================================================
;;; Method override install (ADR-0034 §5; the IMP is the dylib's bounce-shim).
;;; ===========================================================================

(defun aw-resolve-method-encoding (clos-class selector num-params)
  "The ObjC type encoding for SELECTOR on CLOS-CLASS, resolved LIVE — the runtime
   drives conformance. Order: a conformed protocol's declaration (required then
   optional), else the inherited superclass method, else a synthesized default
   (`v@:` + one `@` per Lisp parameter — the void-return/object-arg shape of
   target-action, notification, and the common delegate selectors)."
  ;; (1) conformed protocols — read the live description list.
  (dolist (proto (gethash clos-class *subclass-protocols*))
    (dolist (req '(1 0))                                ; required first, then optional
      (sb-alien:with-alien ((cnt sb-alien:unsigned-int))
        (let ((lst (%protocol-copy-method-descriptions proto req 1 (sb-alien:addr cnt))))
          (unless (aw-null-sap-p lst)
            (unwind-protect
                 (dotimes (i cnt)
                   (let* ((base (* i 16))
                          (msel (sb-sys:sap-ref-sap lst base))
                          (mtypes (aw-sap->string (sb-sys:sap-ref-sap lst (+ base 8)))))
                     (when (string= (%sel-get-name msel) selector)
                       (return-from aw-resolve-method-encoding mtypes))))
              (%libc-free lst)))))))
  ;; (2) an inherited framework method.
  (let* ((objc-cls (objc-class-name-string clos-class))
         (cls-sap (and objc-cls (aw-class objc-cls)))
         (m (and cls-sap (%class-get-instance-method cls-sap (aw-sel selector)))))
    (when (and m (not (aw-null-sap-p m)))
      (let ((enc (%method-get-type-encoding m)))
        (when enc (return-from aw-resolve-method-encoding enc)))))
  ;; (3) synthesized default: void return, object args.
  (with-output-to-string (s)
    (write-string "v@:" s)
    (dotimes (_ num-params) (write-char #\@ s))))

(defun aw-install-override (clos-class selector generic-name num-params)
  "Install one method override on the synthesized CLOS-CLASS: resolve SELECTOR's
   encoding live, route (synth-Class . SELECTOR) -> GENERIC-NAME in the dispatch table,
   and `aw_sbcl_subclass_add_forward` it (installs `_objc_msgForward` + the forwarding
   hooks). ADR-0035: the installed IMP is the dylib's NATIVE bounce shim — never a raw
   `define-alien-callable` (that would run Lisp on the framework's foreign thread)."
  (aw-init-subclass-dispatcher)
  (let ((cls (or (gethash clos-class *synth-classes*)
                 (error "define-objc-method: ~S is not a define-objc-subclass class"
                        (class-name clos-class))))
        (enc (aw-resolve-method-encoding clos-class selector num-params)))
    (setf (gethash (cons (sb-sys:sap-int cls) selector) *override-table*) generic-name)
    (%aw-subclass-add-forward cls (aw-sel selector) enc)
    selector))

;;; ===========================================================================
;;; Super-dispatch (objc_msgSendSuper) — explicit `call-super` / `call-super-id`.
;;; CLOS `call-next-method` cannot mean ObjC-super (see the file header); these are the
;;; recursion-safe super chain, matching racket `objc-subclass.rkt` / gerbil
;;; `subclass.ss`. Zero-arg void + id shapes (the common `[super viewDidLoad]` /
;;; lifecycle chains); argument-passing super-sends need per-signature crossings (defer).
;;; ===========================================================================

(defvar +objc-msgsend-super+ (sb-sys:int-sap 0)
  "SAP of `objc_msgSendSuper`. Re-resolved at startup by 050/070 alongside `objc_msgSend`.")

(defun aw-resolve-objc-msgsend-super ()
  (setf +objc-msgsend-super+ (sb-sys:foreign-symbol-sap "objc_msgSendSuper")))
(aw-resolve-objc-msgsend-super)

(defun %super-struct (instance)
  "A heap `struct objc_super { id receiver; Class super_class }` for INSTANCE; the
   caller frees it. `super_class` is the synthesized class's ObjC superclass — method
   lookup begins there, skipping the override IMP (no re-forward)."
  (let* ((self (aw-ptr instance))
         (cls  (%object-get-class self))
         (super (%class-get-superclass cls))
         (buf (sb-alien:make-alien (sb-alien:unsigned 8) 16))
         (sap (sb-alien:alien-sap buf)))
    (setf (sb-sys:sap-ref-sap sap 0) self
          (sb-sys:sap-ref-sap sap 8) super)
    (values buf sap)))

(defun call-super (instance selector)
  "Send SELECTOR (a string) to INSTANCE's ObjC superclass via `objc_msgSendSuper`
   (void return, no args) — the inherited framework behaviour an override extends."
  (multiple-value-bind (buf sap) (%super-struct instance)
    (unwind-protect
         (sb-alien:alien-funcall
          (sb-alien:sap-alien +objc-msgsend-super+
                              (sb-alien:function sb-alien:void
                                                 sb-alien:system-area-pointer
                                                 sb-alien:system-area-pointer))
          sap (aw-sel selector))
      (sb-alien:free-alien buf))))

(defun call-super-id (instance selector)
  "Like `call-super` but for an `id`-returning inherited method; wraps the result."
  (multiple-value-bind (buf sap) (%super-struct instance)
    (unwind-protect
         (aw-wrap
          (sb-alien:alien-funcall
           (sb-alien:sap-alien +objc-msgsend-super+
                               (sb-alien:function sb-alien:system-area-pointer
                                                  sb-alien:system-area-pointer
                                                  sb-alien:system-area-pointer))
           sap (aw-sel selector)))
      (sb-alien:free-alien buf))))

;;; ===========================================================================
;;; The contract macros (§3.4/§3.5). App source writes these; they expand to a
;;; metaclass-backed `defclass` + the synthesis/override runtime calls above. App
;;; source MUST NOT write `(:metaclass objc-class)` directly (non-portable, §3.4).
;;; ===========================================================================

(defmacro define-objc-subclass (name (&rest superclasses) &body clauses)
  "Define CLOS class NAME as a REAL ObjC subclass of SUPERCLASSES (contract §3.4).
   Clauses: `(:slots SLOT…)` Lisp-side CLOS slots; `(:protocols \"ObjCName\"…)` ObjC
   protocols to conform to; `(:ivars …)` reserved (foreign ivars — not yet wired, the
   IR surfaces no layout). Expands to a `(:metaclass objc-class)` `defclass` plus a
   load-time `aw-synthesize-subclass`. The single CLOS superclass carries the ObjC
   superclass identity (its `objc-class-name-string`)."
  (let* ((slots      (cdr (assoc :slots clauses)))
         (protocols  (cdr (assoc :protocols clauses)))
         (super1     (first superclasses)))
    (unless (= (length superclasses) 1)
      (error "define-objc-subclass: exactly one superclass required, got ~S" superclasses))
    `(progn
       (defclass ,name (,@superclasses) (,@slots) (:metaclass objc-class))
       (aw-synthesize-subclass
        (find-class ',name)
        (or (aw-class-objc-name (find-class ',super1))
            (error "define-objc-subclass: superclass ~S has no ObjC name" ',super1))
        ',protocols)
       (find-class ',name))))

(defmacro define-objc-method ((subclass selector) (&rest lambda-list) &body body)
  "Define an ObjC method override on the synthesized SUBCLASS (contract §3.5). SELECTOR
   is the literal ObjC selector string (e.g. \"drawRect:\"). Expands to a CLOS
   `defmethod` on the `ns:` generic for that selector — specialized on SUBCLASS as the
   first parameter — plus an `aw-install-override` that routes the framework's callbacks
   into it (via the dylib's bounce-shim IMP). ObjC super-chaining is `call-super` /
   `call-super-id`, NOT `call-next-method` (see the file header)."
  ;; ObjC is single-dispatch: only the RECEIVER specializes (ADR-0034 §2). The contract
  ;; permits type decls on the other params for documentation, but the method specializes
  ;; on SUBCLASS alone — strip the rest to plain names (a marshalled arg may not be an
  ;; instance of its declared CLOS type, e.g. a struct arrives as a raw SAP).
  (let* ((generic    (aw-selector->generic-name selector))
         (names      (mapcar (lambda (p) (if (consp p) (first p) p)) lambda-list))
         (receiver   (first names))
         (rest-names (rest names))
         (num-params (length rest-names)))
    `(progn
       (unless (fboundp ',generic) (defgeneric ,generic ,names))
       (defmethod ,generic ((,receiver ,subclass) ,@rest-names) ,@body)
       (aw-install-override (find-class ',subclass) ,selector ',generic ,num-params)
       ',generic)))
