;;;; runtime/conditions.lisp — Cocoa errors as a flat `ns:objc-error` condition
;;;; hierarchy (ADR-0037, contract §3.7). Leaf 050/050.
;;;;
;;;; Cocoa errors surface as SIGNALLED CL conditions — `handler-case`/`restart-case`,
;;;; the CL idiom — NOT as returned `(values result error)` tuples (the chez ADR-0006
;;;; shape the contract rejected). The hierarchy is flat, split by SOURCE:
;;;;
;;;;   ns:objc-error : cl:error            the stable family-portable handler target
;;;;     ns:cocoa-error                    the NSError** out-param path
;;;;     ns:objc-exception                 the NSException path (secondary, ADR-0037)
;;;;
;;;; The condition TYPES are deliberately distinct symbols from the MOP-projected
;;;; classes `ns:ns-error` / `ns:ns-exception` (ADR-0034): the signalled CONDITION
;;;; wraps the bound OBJECT, it does not reuse its name.
;;;;
;;;; ONE signaller `signal-cocoa-error` serves BOTH the direct `NSError**` path
;;;; (`aw-with-error-cell`) AND the Swift-`throws` trampoline (`aw-swift-call/error`,
;;;; over 010's `ThrowsBridge`) — kept a single function so the two paths can never
;;;; diverge (ADR-0037's whole point). The two callers differ ONLY in OWNERSHIP of the
;;;; surfaced `NSError*` (direct = autoreleased, we borrow; bridge = +1, we release)
;;;; and in their FAILURE KEY (direct keys on the primary return nil/NO per Apple's
;;;; "check the return, not the error"; the bridge keys on the cell being written,
;;;; since it writes the error iff it caught). Needs 020 (the seam) + 010 (`ThrowsBridge`).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; The `ns:`-qualified condition surface (contract §3.7 — the named root condition
;;; type lives in the `ns:` package so app source `handler-case`s a portable name).
;;; Intern + export FIRST so the `define-condition` / `:reader` forms below read with
;;; single-colon `ns:` names (the objc.lisp `ns::ns-object` export pattern).
;;; ---------------------------------------------------------------------------

(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("OBJC-ERROR" "COCOA-ERROR" "OBJC-EXCEPTION"
               ;; readers — also the ObjC selector names, so `(ns:domain x)` reads a
               ;; condition OR (additively) a bound `ns:ns-error` once that binding loads
               "DOMAIN" "CODE" "USER-INFO" "LOCALIZED-DESCRIPTION" "NAME" "REASON"))
    (export (intern n '#:ns) '#:ns)))

(define-condition ns:objc-error (error) ()
  (:documentation
   "Root of every Cocoa-surfaced error condition (contract §3.7). The stable,
    family-portable `handler-case`/`handler-bind` target — app source handles this to
    catch both the `NSError**` and `NSException` paths regardless of CL impl."))

(define-condition ns:cocoa-error (ns:objc-error)
  ;; Fields extracted EAGERLY at signal time (`make-cocoa-error`) into Lisp values, so
  ;; the condition outlives the NSError* and its autorelease pool without a dangling
  ;; read — the gerbil `nserror<-ptr` approach. `error-ptr` keeps the raw NSError* for
  ;; the rare caller that needs more than the readers (lifetime is the caller's).
  ((domain :initarg :domain :reader ns:domain :initform nil)
   (code :initarg :code :reader ns:code :initform 0)
   (user-info :initarg :user-info :reader ns:user-info :initform nil)
   (localized-description :initarg :localized-description
                          :reader ns:localized-description :initform nil)
   (error-ptr :initarg :error-ptr :reader cocoa-error-ptr :initform nil))
  (:report (lambda (c stream)
             (format stream "Cocoa error [~A ~A]: ~A"
                     (ns:domain c) (ns:code c)
                     (or (ns:localized-description c) "<no description>"))))
  (:documentation
   "The `NSError**` out-parameter path (ADR-0037). `domain`/`code`/`localized-description`
    are read eagerly off the live `NSError*`; `user-info` (NSDictionary) is deferred
    (gerbil parity — TBD until a sample app needs the dictionary)."))

(define-condition ns:objc-exception (ns:objc-error)
  ((name :initarg :name :reader ns:name :initform nil)
   (reason :initarg :reason :reader ns:reason :initform nil)
   (user-info :initarg :user-info :reader ns:user-info :initform nil))
  (:report (lambda (c stream)
             (format stream "ObjC exception ~A: ~A"
                     (ns:name c) (or (ns:reason c) "<no reason>"))))
  (:documentation
   "The `NSException` path (ADR-0037, SECONDARY). The type exists + signals; CAPTURE
    (turning a live `@throw` into this) needs a native `@catch` shim and is the
    documented stub at the bottom of this file."))

;;; ---------------------------------------------------------------------------
;;; Reading an `NSError*` / `NSException*` — raw `objc_msgSend`, self-contained.
;;;
;;; The runtime must NOT depend on the generated `ns:ns-error` binding existing (it is
;;; emitted per-build, may be absent), so these read the fields directly through the
;;; seam (`+objc-msgsend+`), exactly as gerbil's `nserror<-ptr` does. Read-only: no
;;; retain/release here — ownership is the caller's (the two wrappers below).
;;; ---------------------------------------------------------------------------

(declaim (inline %msgsend-id-0/c %msgsend-long-0/c))

(defun %msgsend-id-0/c (receiver sel-name)
  "`id (id, SEL)` — a 0-arg id-returning send (a `-domain` / `-localizedDescription`
   accessor). Local to conditions to stay independent of objc.lisp's inline helpers."
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   receiver (aw-sel sel-name)))

(defun %msgsend-long-0/c (receiver sel-name)
  "`long (id, SEL)` — a 0-arg `NSInteger`-returning send (`-code`)."
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
                       (sb-alien:function sb-alien:long
                                          sb-alien:system-area-pointer
                                          sb-alien:system-area-pointer))
   receiver (aw-sel sel-name)))

(defun %read-nsstring-sel (receiver sel-name)
  "Send a 0-arg `NSString*`-returning selector + copy its bytes to a Lisp string (nil
   when the result is null). Does not consume a reference (the string bridge copies)."
  (let ((s (%msgsend-id-0/c receiver sel-name)))
    (and (not (aw-null-sap-p s)) (nsstring->string s))))

(defun make-cocoa-error (nserror-sap)
  "Build a `ns:cocoa-error` from a live `NSError*` SAP (null -> a degenerate condition
   with nil/0 readers, for a failure that set no error). Reads `domain`/`code`/
   `localizedDescription` EAGERLY; `userInfo` deferred."
  (if (aw-null-sap-p nserror-sap)
      (make-condition 'ns:cocoa-error :error-ptr nil)
      (make-condition 'ns:cocoa-error
                      :domain (%read-nsstring-sel nserror-sap "domain")
                      :code (%msgsend-long-0/c nserror-sap "code")
                      :localized-description (%read-nsstring-sel nserror-sap
                                                                 "localizedDescription")
                      :user-info nil
                      :error-ptr nserror-sap)))

;;; ---------------------------------------------------------------------------
;;; The ONE signaller (ADR-0037) — shared by the direct path and the ThrowsBridge.
;;; ---------------------------------------------------------------------------

(defun signal-cocoa-error (nserror-sap &key owned)
  "Build a `ns:cocoa-error` from NSERROR-SAP and signal it with the normative restarts.
   The SINGLE signaller for BOTH error sources (ADR-0037): OWNED nil = the direct
   `NSError**` path (Cocoa autoreleased the error — we only borrow it to read fields);
   OWNED t = the `ThrowsBridge` path (the bridge handed us a +1 we must `release` after
   extracting). Restarts: `use-value` (return a supplied substitute as the call's
   result), `continue` / `return-nil` (proceed with nil). Returns the substitute when a
   handler invokes a restart; otherwise the `error` transfers control to the handler."
  (let ((condition (make-cocoa-error nserror-sap)))   ; eager extract (read-only)
    (when (and owned (not (aw-null-sap-p nserror-sap)))
      (%objc-release nserror-sap))                     ; balance the bridge's +1
    (restart-case (error condition)
      (use-value (value)
        :report "Return a supplied value as the failed call's result."
        value)
      (continue ()
        :report "Proceed, treating the failed call's result as nil."
        nil)
      (return-nil ()
        :report "Return nil from the failed call."
        nil))))

;;; ---------------------------------------------------------------------------
;;; The two call-site wrappers. Both allocate a stack `NSError**` cell, bind VAR (the
;;; emitter names it `%err`) to the cell ADDRESS for the body to thread as the trailing
;;; `id*` actual, and converge on `signal-cocoa-error`. They differ only in failure key
;;; + ownership (see file header).
;;; ---------------------------------------------------------------------------

(defmacro aw-with-error-cell ((var) &body body)
  "The direct `NSError**` path (contract DISPATCH BODY, ADR-0037). Allocate a zeroed
   `id` cell, bind VAR to its address (the emitter passes VAR as the trailing `id*`
   actual of the `objc_msgSend` crossing), run BODY, and signal `ns:cocoa-error` ONLY
   when the primary return indicates FAILURE — nil for an object return, nil for a
   BOOL return whose `(boolean)` crossing maps NO->nil — per Apple's check-the-return
   rule. On success returns the primary value with no signal. The surfaced `NSError*`
   is autoreleased (Cocoa convention), so OWNED nil: we read its fields, never release."
  (let ((cell (gensym "ERRCELL")) (result (gensym "RESULT")))
    `(sb-alien:with-alien ((,cell sb-alien:system-area-pointer))
       (setf ,cell (aw-null-sap))                        ; zero the cell
       (let* ((,var (sb-alien:alien-sap (sb-alien:addr ,cell)))   ; cell ADDRESS as id*
              (,result (progn ,@body)))
         (if ,result
             ,result
             (signal-cocoa-error ,cell))))))             ; ,cell now holds the NSError*

(defmacro aw-swift-call/error ((var) &body body)
  "The Swift-`throws` trampoline path (ADR-0037, over 010's `ThrowsBridge`). Same cell
   plumbing as `aw-with-error-cell`, but keyed on the CELL being WRITTEN, not on the
   primary return: a `throws` trampoline returns a FALLBACK on throw that may coincide
   with a legitimate nil/0 result, so the cell — which `ThrowsBridge` writes iff it
   caught — is the reliable failure signal. The bridge writes a +1-retained `NSError*`,
   so OWNED t: `signal-cocoa-error` releases it after extracting. Same signaller — the
   two paths can never diverge."
  (let ((cell (gensym "ERRCELL")) (result (gensym "RESULT")))
    `(sb-alien:with-alien ((,cell sb-alien:system-area-pointer))
       (setf ,cell (aw-null-sap))
       (let* ((,var (sb-alien:alien-sap (sb-alien:addr ,cell)))
              (,result (progn ,@body)))
         (if (aw-null-sap-p ,cell)
             ,result
             (signal-cocoa-error ,cell :owned t))))))

;;; ---------------------------------------------------------------------------
;;; NSException capture — SECONDARY, the documented stub (ADR-0037).
;;;
;;; The `ns:objc-exception` type + this signaller exist; what is NOT wired is CAPTURE.
;;; Direct dispatch reaches ObjC straight through `objc_msgSend` (no native frame), so
;;; an ObjC `@throw` would unwind THROUGH Lisp frames — undefined behaviour. Catching
;;; it needs a native `@try/@catch` shim in `libAPIAnywareSbcl` that converts the live
;;; `NSException` to an `NSError*` (or invokes this signaller); that is at odds with the
;;; trampoline-elided direct-dispatch design and is genuinely secondary (the `NSError**`
;;; path is the load-bearing surface — ADR-0037). Deferred to an integration leaf if a
;;; real framework needs it. `signal-objc-exception` is ready for that wiring.
;;; ---------------------------------------------------------------------------

(defun signal-objc-exception (nsexception-sap)
  "Signal `ns:objc-exception` for a live `NSException*` (`name`/`reason` read eagerly).
   READY but UNCALLED: capture (a native `@catch` feeding this) is the deferred stub
   above. The same minimal restarts as the cocoa path."
  (let ((condition
          (if (aw-null-sap-p nsexception-sap)
              (make-condition 'ns:objc-exception)
              (make-condition 'ns:objc-exception
                              :name (%read-nsstring-sel nsexception-sap "name")
                              :reason (%read-nsstring-sel nsexception-sap "reason")
                              :user-info nil))))
    (restart-case (error condition)
      (continue () :report "Proceed past the exception with nil." nil)
      (return-nil () :report "Return nil." nil))))
