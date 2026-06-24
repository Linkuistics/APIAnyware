;;;; app-implementations/macos/_support/load-bindings.lisp — the dev binding-library loader for the SBCL
;;;; sample apps (leaf 060). Loads the runtime + named generated frameworks for an
;;;; interactive `sbcl --load` session, a `save-lisp-and-die` build, or the per-app
;;;; smoke. The production ASDF system + dylib relocation into a `.app` is
;;;; 070-distribution's job; this is the dev harness the 7-app ladder shares.
;;;;
;;;; Load order (per framework): facade FIRST (interns + exports the `ns:` surface so
;;;; construct files' single-colon references read), then generics, then every class
;;;; file in ARBITRARY directory order, then protocols/enums/constants/functions.
;;;; Class files need no topological sort: an `objc-class`-metaclass `defclass` whose
;;;; superclass is not yet defined creates a CLOS forward-referenced-class, upgraded
;;;; in place when the real `defclass` loads (ADR-0034 §1). So the whole graph — even
;;;; cross-framework parents — resolves regardless of file order; loading Foundation
;;;; before AppKit is convention, not a correctness requirement.

(in-package #:cl-user)

(defparameter *aw-sbcl-root*
  ;; This file is app-implementations/macos/_support/load-bindings.lisp; walk up
  ;; three dirs to the SBCL target root targets/sbcl/.
  (let ((here (or *load-truename* *load-pathname*)))
    (make-pathname :directory (butlast (pathname-directory here) 3)
                   :host (pathname-host here)
                   :device (pathname-device here)))
  "Absolute path of targets/sbcl/ — the SBCL target root.")

(defparameter *aw-bindings-root*
  ;; The §18 binding package root: runtime/ (hand-written) + the emitted generated/
  ;; tree as siblings, relocated here from the old generation/targets/sbcl/ root
  ;; by move-sbcl-material-k14.
  (merge-pathnames "bindings/macos/" *aw-sbcl-root*)
  "Absolute path of the SBCL binding package root.")

(defparameter *aw-generated*
  (merge-pathnames "generated/" *aw-bindings-root*)
  "Absolute path of the generated binding tree.")

;; The runtime (sb-alien seam, MOP metaclass, lifetime/threading/conditions, the
;; startup re-resolution pass wired into sb-ext:*init-hooks*).
(load (merge-pathnames "runtime/load.lisp" *aw-bindings-root*))

(in-package #:apianyware-sbcl-impl)

(defparameter *aw-construct-specials*
  '("generics" "protocols" "enums" "constants" "functions" "structs")
  "The per-framework files loaded out of class-file order (generics before classes,
   the rest after). `structs` (the ADR-0042 value-struct residual) is residual-gated like
   constants/functions.")

(defun aw-app-load-framework (name &key (dlopen t) (load-residual t))
  "Load the generated binding tree for framework NAME (its base name, e.g.
   \"Foundation\"). DLOPEN (default t) also `dlopen`s the system framework so its
   ObjC classes resolve for direct `objc_msgSend`. LOAD-RESIDUAL (default t) loads
   constants.lisp/functions.lisp + leaves the Swift-native residual `defmethod`s in
   the class files; pass nil for an app that needs neither (the residual
   `aw_sbcl_*` aliens then stay unresolved, harmless until called — but a build that
   does not load `libAPIAnywareSbcl` should pass nil to avoid undefined-alien noise)."
  (let* ((low (string-downcase name))
         (dir (merge-pathnames (format nil "~A/" low) cl-user::*aw-generated*))
         (facade (merge-pathnames (format nil "~A.lisp" low) cl-user::*aw-generated*)))
    (when dlopen (aw-load-framework name))
    (handler-bind ((warning #'muffle-warning))
      (load facade)
      (flet ((maybe (f) (let ((p (merge-pathnames f dir))) (when (probe-file p) (load p)))))
        (maybe "generics.lisp")
        (dolist (p (directory (merge-pathnames "*.lisp" dir)))
          (unless (member (pathname-name p) *aw-construct-specials* :test #'string=)
            (load p)))
        (maybe "protocols.lisp")
        (maybe "enums.lisp")
        (when load-residual
          (maybe "constants.lisp")
          (maybe "functions.lisp")
          ;; structs.lisp (ADR-0042): the value-struct residual. After generics (its
          ;; defmethods extend them) + the value-struct root (runtime); entirely
          ;; Swift-native, so residual-gated like functions.lisp.
          (maybe "structs.lisp"))))
    name))

(export 'aw-app-load-framework '#:apianyware-sbcl-impl)
