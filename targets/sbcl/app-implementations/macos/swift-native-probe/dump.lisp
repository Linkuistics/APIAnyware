;;;; dump.lisp — `save-lisp-and-die` the swift-native-probe standalone executable (060/030).
;;;;
;;;; The FIRST ladder app to dump WITH libAPIAnywareSbcl: it embeds the SBCL runtime, the
;;;; loaded binding library (runtime + Foundation/CoreGraphics/AppKit residual), and the
;;;; app. Per ADR-0038 §5 the dylib is NOT embedded — `save-lisp-and-die` keeps it in
;;;; `*shared-objects*`, so the revived image auto-reopens it (re-linking every `aw_sbcl_*`
;;;; residual symbol for free) by the path it was loaded from. We therefore load it from a
;;;; FIXED path — `/tmp/libAPIAnywareSbcl.dylib` (build.sh stages the copy there) — so the
;;;; VM only needs that one dylib provisioned at that path (the dev shape; `bundle-sbcl`
;;;; (070) relocates into Contents/Frameworks + re-resolves exe-relative — see the hello-
;;;; window 070 findings). At revive, `sb-ext:*init-hooks*` runs the mandatory startup
;;;; re-resolution pass (ADR-0034 §6 / ADR-0038 §5) — re-dlopen frameworks, re-resolve
;;;; objc_msgSend, re-mask FP traps — BEFORE the toplevel.
;;;;
;;;; Invoked by build.sh:
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;     --load .../apps/swift-native-probe/dump.lisp -- <output-exe-path> <dylib-path>

(in-package #:cl-user)

(defparameter *app-dir*
  (make-pathname :name nil :type nil :defaults (or *load-truename* *load-pathname*)))

;; Post-`--` args: 1 = output exe path, 2 = dylib path to record for revive.
(defparameter *post-args* (rest (member "--" sb-ext:*posix-argv* :test #'string=)))
(defparameter *out-exe*
  (or (first *post-args*) (namestring (merge-pathnames "swift-native-probe" *app-dir*))))
(defparameter *dylib*
  (or (second *post-args*) "/tmp/libAPIAnywareSbcl.dylib"))

(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))

(in-package #:apianyware-sbcl-impl)

(setf *native-dylib-path* cl-user::*dylib*)
(aw-load-native-dylib)

(aw-app-load-framework "Foundation" :load-residual t)
(aw-app-load-framework "CoreGraphics" :load-residual t)
(aw-app-load-framework "AppKit" :load-residual t)

;; events.lisp first (pure CL — the snp-events package swift-native-probe.lisp references).
(load (merge-pathnames "events.lisp" cl-user::*app-dir*))
(load (merge-pathnames "swift-native-probe.lisp" cl-user::*app-dir*))

(format t "~&== dumping ~A (dylib recorded: ~A) ==~%" cl-user::*out-exe* cl-user::*dylib*)
(finish-output)

(sb-ext:save-lisp-and-die cl-user::*out-exe*
  :executable t
  :save-runtime-options t          ; standalone GUI: do not parse argv as SBCL options
  :toplevel (lambda ()
              ;; Env AW_PROBE_SMOKE makes the REVIVED image a construction smoke: it calls
              ;; every Swift-native trampoline + builds the UI (so the startup re-resolution
              ;; pass AND the §6d residual dylib auto-reopen are exercised in the dumped
              ;; image) then exits 0 without the run loop — a host revive smoke before the VM.
              (let ((smoke (sb-ext:posix-getenv "AW_PROBE_SMOKE")))
                (handler-case (swift-native-probe-main :run (not smoke))
                  (error (e)
                    (format *error-output* "swift-native-probe fatal: ~A~%" e)
                    (finish-output *error-output*)
                    (sb-ext:exit :code 1)))
                (when smoke
                  (format t "### revived swift-native-probe construction OK~%")
                  (finish-output)))
              (sb-ext:exit :code 0)))
