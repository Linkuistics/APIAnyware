;;;; runtime/startup.lisp — the mandatory startup re-resolution pass (leaf 050/070,
;;;; ADR-0034 §6 / ADR-0038 §5).
;;;;
;;;; A `save-lisp-and-die` core preserves all the baked LISP metadata — the class
;;;; graph, the selector strings, the opt-in ivar offsets — but every live foreign
;;;; pointer that metadata referenced (`Class`/`SEL`/`objc_msgSend` SAPs) is an
;;;; address in the GENERATING process and is meaningless in the revived one. The
;;;; entire correctness invariant of the binding is therefore: NEVER reuse a baked
;;;; pointer — re-derive each one at every process start from baked STRING identity.
;;;; This pass is that re-derivation. It is load-bearing for 070-distribution: a
;;;; dumped executable is dead without it (spike 5 proved a Foundation `Class` is
;;;; invalid in the revived image until Foundation is re-`dlopen`ed).
;;;;
;;;; SPLIT WITH THE DYLIB (ADR-0038 §5): SBCL auto-reopens `libAPIAnywareSbcl` (it
;;;; stays in `*shared-objects*`), so the `aw_sbcl_*` residual symbols re-link for
;;;; free, and dyld re-loads the **residual-owning** frameworks the dylib links — the
;;;; dylib stays passive, no `aw_sbcl_revive` entry. This Lisp pass owns exactly the
;;;; complement: the **direct-msgSend** frameworks (`*loaded-frameworks*`) plus EVERY
;;;; `Class`/`SEL`/`objc_msgSend` SAP. Other subsystems that cache a live foreign
;;;; pointer across a dump (the release queue, the synthesized-class pairs, the dylib
;;;; block-dispatcher registration) drop their stale state through the
;;;; `*startup-reresolve-hooks*` seam (ffi.lisp); this pass runs them last.

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; libobjc ivar primitives — the opt-in baked-offset re-resolution path (§8 SDK
;;; drift). Always-mapped libobjc, so they need no framework load.
;;; ---------------------------------------------------------------------------

(sb-alien:define-alien-routine ("class_getInstanceVariable" %class-get-instance-variable)
    sb-alien:system-area-pointer
  (cls  sb-alien:system-area-pointer)
  (name sb-alien:c-string))

;; `ivar_getOffset` returns a BYTE offset (`ptrdiff_t`); the slot stores a BIT offset
;; (spike 3 — `%foreign-slot-ref` divides by 8), so re-resolution multiplies by 8.
(sb-alien:define-alien-routine ("ivar_getOffset" %ivar-get-offset)
    (sb-alien:signed 64)
  (ivar sb-alien:system-area-pointer))

;;; ---------------------------------------------------------------------------
;;; The opt-in ivar-offset re-resolution table (ADR-0034 §4 / §8).
;;;
;;; A baked bit-offset is SDK-version-sensitive: an offset captured at generation
;;; time can drift if the app runs against a different SDK. The mitigation is to
;;; re-derive it from the LIVE class at startup via `ivar_getOffset`. The IR surfaces
;;; no ivar layout today, so this table is EMPTY in practice and the pass step over
;;; it is inert — but the mechanism is wired (and exercised by the smoke's
;;; hand-constructed entry) so a future emitter that DOES bake offsets gets startup
;;; re-resolution for free by emitting a matching `register-ivar-reresolve` next to
;;; each foreign slot.
;;; ---------------------------------------------------------------------------

(defvar *ivar-reresolve-table* '()
  "A list of (OBJC-CLASS-NAME IVAR-NAME EFFECTIVE-SLOT) entries the startup pass
   re-derives via `ivar_getOffset`. Empty unless the emitter bakes ivar offsets.")

(defun register-ivar-reresolve (objc-class-name ivar-name effective-slot)
  "Record that EFFECTIVE-SLOT's baked offset should be re-derived from the live ivar
   IVAR-NAME of OBJC-CLASS-NAME at every startup. The fast-path companion to a baked
   `:offset` slot — emitted next to it when (and only when) offsets are baked."
  (pushnew (list objc-class-name ivar-name effective-slot) *ivar-reresolve-table*
           :test #'equal))

(defun aw-reresolve-ivar-offsets ()
  "Re-derive every registered foreign-slot offset from its live ivar (`ivar_getOffset`,
   bytes -> bits). Skips an entry whose class or ivar is not resolvable (the
   accessor-selector method path is the always-safe default, so a missing offset is
   never fatal). Inert when the table is empty."
  (dolist (entry *ivar-reresolve-table*)
    (destructuring-bind (objc-name ivar-name eslot) entry
      (let ((cls (%objc-get-class objc-name)))
        (unless (aw-null-sap-p cls)
          (let ((ivar (%class-get-instance-variable cls ivar-name)))
            (unless (aw-null-sap-p ivar)
              (setf (slot-offset eslot) (* 8 (%ivar-get-offset ivar))))))))))

;;; ---------------------------------------------------------------------------
;;; The pass.
;;; ---------------------------------------------------------------------------

(defun aw-reresolve-classes ()
  "Re-resolve every registered `Class` from its baked ObjC name (`objc_getClass`),
   re-populating the `aw-class` cache + the metaclass `class-sap` slot 030 reads. A
   name that does not resolve is SKIPPED (not cached as null): it is either a
   synthesized subclass not yet re-created by its `define-objc-subclass` toplevel, or
   a framework not loaded — both recover lazily, never with a poisoned cache entry."
  (maphash (lambda (objc-name clos-class)
             (let ((cls (%objc-get-class objc-name)))
               (unless (aw-null-sap-p cls)
                 (setf (gethash objc-name *class-cache*) cls)
                 (when (typep clos-class 'objc-class)
                   (setf (objc-class-cached-sap clos-class) cls)))))
           *objc-class-registry*))

(defun aw-startup-reresolve ()
  "The mandatory startup re-resolution pass (ADR-0034 §6 / ADR-0038 §5). Idempotent —
   safe to run at every image start AND to re-run by hand. Ordered: frameworks are
   re-`dlopen`ed FIRST so their classes are registered before any `objc_getClass`.

   1. re-`dlopen` each direct-msgSend framework (`*loaded-frameworks*`);
   2. re-resolve `+objc-msgsend+` / `+objc-msgsend-super+` from their live symbols;
   3. clear the `SEL`/`Class` caches (their baked SAPs are stale; SELs re-resolve
      lazily from baked strings, libobjc being always-mapped);
   4. re-resolve every registered framework `Class` (repopulating both caches);
   5. re-derive any baked ivar offsets (inert when the table is empty);
   6. run each subsystem reset thunk (`*startup-reresolve-hooks*`)."
  ;; (1) frameworks BEFORE classes (spike 5: a Foundation Class is invalid until
  ;; Foundation is re-loaded; libobjc's NSObject is always valid). Replay in load
  ;; order; re-`dlopen` is idempotent.
  (dolist (name (reverse *loaded-frameworks*))
    (aw-load-framework name))
  ;; (2) the dispatch SAPs.
  (aw-resolve-objc-msgsend)
  (aw-resolve-objc-msgsend-super)
  ;; (2a) re-mask the FP traps (thread-local; do NOT survive the dump — 060/010). A
  ;; revived image on the main thread must clear them before any AppKit call, else the
  ;; first layout NaN signals FLOATING-POINT-INVALID-OPERATION.
  (aw-mask-fp-traps)
  ;; (3) drop stale per-process caches.
  (clrhash *sel-cache*)
  (clrhash *class-cache*)
  ;; (4) eagerly re-resolve the baked Class graph (SELs stay lazy).
  (aw-reresolve-classes)
  ;; (5) the opt-in ivar fast path.
  (aw-reresolve-ivar-offsets)
  ;; (6) every other subsystem's stale-foreign-state reset.
  (dolist (entry *startup-reresolve-hooks*)
    (funcall (cdr entry)))
  t)

;;; ---------------------------------------------------------------------------
;;; Image-startup wiring. `sb-ext:*init-hooks*` runs BEFORE the toplevel of a dumped
;;; image, so the re-resolution is complete before any app form dispatches. The full
;;; `save-lisp-and-die :toplevel`/`:executable t` packaging is 070-distribution's
;;; job; this leaf provides the callable pass + registers it on `*init-hooks*` (the
;;; var itself survives the dump, carrying the registration into the revived image).
;;; Pushing the SYMBOL (not the function) dedups across re-loads and survives a
;;; redefinition of the pass.
;;; ---------------------------------------------------------------------------

(pushnew 'aw-startup-reresolve sb-ext:*init-hooks*)
