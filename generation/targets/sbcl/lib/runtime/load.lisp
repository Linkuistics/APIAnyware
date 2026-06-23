;;;; runtime/load.lisp — the dev load order for the SBCL runtime (leaf 050/020).
;;;;
;;;; Loads the runtime units in dependency order for an interactive `sbcl --load`
;;;; session and the smoke tests. This is the DEV loader; the production loader (an
;;;; ASDF system that also sequences the generated facade + construct files, and the
;;;; bundler wiring) is 050/070's + 070-distribution's job. As later leaves add
;;;; units (objc.lisp for the metaclass, conditions.lisp, …) they extend this list.

(in-package #:cl-user)

(let ((here (or *load-truename* *load-pathname*)))
  (flet ((unit (name)
           (load (merge-pathnames name here))))
    (unit "packages.lisp")          ; the `ns` + `apianyware-sbcl-impl` packages
    (unit "ffi.lisp")               ; the sb-alien seam + core helpers + string bridge
    (unit "objc.lisp")              ; the MOP object model: metaclass + hooks + make-instance
    (unit "swift-trampoline.lisp")  ; the Swift-native residual binding shape
    (unit "value-struct.lisp")      ; the population-B value-struct object model (ADR-0042)
    (unit "subclass.lisp")          ; ObjC subclass synthesis + protocol conformance
    (unit "lifetime.lisp")          ; sb-ext:finalize + main-thread release queue + entry pool
    (unit "conditions.lisp")        ; the ns:objc-error hierarchy + signal-cocoa-error
    (unit "threading.lisp")         ; aw-block + the foreign->main bounce + sb-thread boundary
    (unit "startup.lisp")           ; the mandatory startup re-resolution pass (ADR-0034 §6)
    (unit "reader-syntax.lisp")))   ; the contract §3.2 @"…" NSString reader macro (060/020)
