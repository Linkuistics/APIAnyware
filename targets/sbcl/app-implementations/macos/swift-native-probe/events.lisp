;;;; events.lisp — Swift-Native Probe structured event log (sbcl target).
;;;;
;;;; The k141 logging contract (apps/macos/swift-native-probe/docs/logging-contract.md):
;;;; the hello-window lifecycle triad plus the [probe] events that carry THIS app's actual
;;;; coverage proof — one [probe] result per probed shape (each with an explicit ok-check vs
;;;; a known-good expected) and a [probe] complete summary whose all-ok=#t is the single
;;;; target-agnostic coverage assertion scenario 01 consumes:
;;;;   [lifecycle] startup                                   — readiness probe (`wait-ready`)
;;;;   [probe] result shape=<s> name="<sym>" ok=<#t|#f> value=<v>  — once per shape
;;;;   [probe] complete count=<n> ok=<n> all-ok=<#t|#f>      — the coverage assertion (01)
;;;;   Swift-Native Probe opened.                            — window key+front; BARE line
;;;;   [lifecycle] shutdown reason=<r>                       — terminate; reason ∈ {menu,signal,error}
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading stdout:
;;;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference emitters: the
;;;; hello-window events.lisp (the lifecycle triad + the `hw-events` package shape) and the
;;;; drawing-canvas events.lisp (this target's k137 sibling). Unlike those, this app's
;;;; [probe] events carry STRING values (name always; scanner/value-box values), so the
;;;; contract's double-quote-with-escapes form is produced by CL `~s` (prin1) — re-readable,
;;;; escaping `"`/`\` (our values carry no newline).
;;;;
;;;; Booleans emit Scheme-style `#t`/`#f` (the contract's `ok`/`all-ok` alphabet), NOT CL
;;;; T/NIL — the runner's matcher is `all-ok=#t`. Shapes downcase via `~(~a~)` (CL's default
;;;; *print-case* is :upcase, so a bare ~a on 'value-box would emit VALUE-BOX).
;;;;
;;;; PURE Common Lisp — no AppKit / Foundation / dylib dependency — so it loads + unit-tests
;;;; in isolation; the only non-ANSI surface is `sb-ext:posix-getenv`. swift-native-probe.lisp
;;;; references it through the `snp-events` nickname; run.lisp / dump.lisp load this file first.
;;;;
;;;; Single writer: the probe computes on the main thread before the run loop, and the only
;;;; later writes are the launch line and the shutdown line (also main thread) — one stream
;;;; with a post-write `finish-output` suffices, no lock.

(defpackage #:apianyware-sbcl-swift-native-probe-events
  (:use #:cl)
  (:nicknames #:snp-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-probe-result #:emit-probe-complete
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-swift-native-probe-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same file
;; whether or not #:log-env (SWIFT_NATIVE_PROBE_EVENTS_LOG) propagates through LaunchServices.
(defparameter *default-events-path* "/tmp/swift-native-probe/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; SWIFT_NATIVE_PROBE_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "SWIFT_NATIVE_PROBE_EVENTS_LOG")))
    (if (and env (plusp (length env))) env *default-events-path*)))

(defun events-log-path () *path*)

;; Open + truncate the events.log the runner tails. :supersede truncates an existing file
;; and creates the parent dir (via ensure-directories-exist). The runner also truncates it
;; between scenarios (setup-scenario!), so the two truncates compose cleanly.
(defun events-init! ()
  (close-events!)
  (let ((target (resolve-path)))
    (ensure-directories-exist target)
    (setf *port* (open target :direction :output
                              :if-exists :supersede :if-does-not-exist :create
                              :external-format :utf-8)
          *path* target)
    target))

(defun emit-line (line)
  (when *port*
    ;; Swallow only I/O-level failures (out-of-disk, closed-stream races on shutdown).
    ;; A genuine programmer error still surfaces during dev.
    (handler-case
        (progn
          (write-string line *port*)
          (terpri *port*)
          (finish-output *port*))
      ((or stream-error file-error) () nil))))

;; Scheme-style boolean literal for the contract's ok/all-ok alphabet.
(defun bool->hash (b) (if b "#t" "#f"))

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §step-6 launch diagnostic — the bare (unbracketed) line the runner's `wait-for-log`
;; matches; dual-emitted (the stdout print stays in swift-native-probe.lisp for unbundled
;; runs). Identical wording across all four impls (the contract's stable launch line).
(defun emit-launch-line () (emit-line "Swift-Native Probe opened."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; One coverage-set shape's result. SHAPE is a bare symbol (function/constant/init/method/
;;; value-box), NAME the probed symbol (emitted double-quoted via ~s), OK a generalized
;;; boolean (emitted #t/#f), VALUE-REPR the ALREADY-rendered value string — the caller
;;; renders numbers bare and strings ~s-quoted (contract "value semantics"), since only the
;;; call site knows each shape's live type.
(defun emit-probe-result (shape name ok value-repr)
  (emit-line (format nil "[probe] result shape=~(~a~) name=~s ok=~a value=~a"
                     shape name (bool->hash ok) value-repr)))

;;; The coverage summary scenario 01 asserts. ALL-OK must be #t iff OK = COUNT.
(defun emit-probe-complete (count ok all-ok)
  (emit-line (format nil "[probe] complete count=~d ok=~d all-ok=~a"
                     count ok (bool->hash all-ok))))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
