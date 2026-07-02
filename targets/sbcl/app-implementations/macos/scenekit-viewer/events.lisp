;;;; events.lisp — SceneKit Viewer structured event log (sbcl target).
;;;;
;;;; The k105 logging contract
;;;; (apps/macos/scenekit-viewer/docs/logging-contract.md): the three hello-window
;;;; lifecycle events plus the two [scene] state-transition events the spec §13 scene
;;;; assertions ride (the SCNView's rendered contents are pixel-level — invisible to
;;;; OCR and the AX tree, and the verb set has no drag or pixel-diff verb — so the
;;;; geometry swap and the colour that survives it are assertable only through these
;;;; log events):
;;;;   [lifecycle] startup                              — readiness probe (`wait-ready`)
;;;;   SceneKit Viewer opened. …                        — §3.6 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>                  — terminate; reason ∈ {menu,signal,error}
;;;;   [scene] geometry-changed shape="…" r=… g=… b=…   — picker handler; post swap + §7.2 re-apply
;;;;   [scene] color-changed r=… g=… b=…                — panel handler success path; post store+apply
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading
;;;; stdout: `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;;;; emitters: the pdfkit-viewer events.lisp (this target's k101 worked template) and
;;;; the racket scenekit-viewer events.rkt (the k107 reference pattern).
;;;;
;;;; Single writer: the Cocoa run loop serialises the main-thread callbacks that emit —
;;;; startup/launch before `-run`, the [scene] events from the picker's action callback
;;;; and the in-process colour panel's continuous action callback, shutdown on the
;;;; terminate path — so one stream with a post-write `finish-output` suffices.
;;;;
;;;; PURE Common Lisp — no AppKit / SceneKit / dylib dependency — so it loads +
;;;; unit-tests in isolation (`sbcl --script` loads this file then calls the emitters;
;;;; the only non-ANSI surface is `sb-ext:posix-getenv`). scenekit-viewer.lisp
;;;; references it through the `sv-events` nickname; run.lisp / dump.lisp load this
;;;; file first.

(defpackage #:apianyware-sbcl-scenekit-viewer-events
  (:use #:cl)
  (:nicknames #:sv-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-geometry-changed #:emit-color-changed
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-scenekit-viewer-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same
;; file whether or not #:log-env (SCENEKIT_VIEWER_EVENTS_LOG) propagates through
;; LaunchServices.
(defparameter *default-events-path* "/tmp/scenekit-viewer/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; SCENEKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "SCENEKIT_VIEWER_EVENTS_LOG")))
    (if (and env (plusp (length env))) env *default-events-path*)))

(defun events-log-path () *path*)

;; Open + truncate the events.log the runner tails. :supersede truncates an existing
;; file and creates the parent dir (via ensure-directories-exist). The runner also
;; truncates it between scenarios (setup-scenario!), so the two truncates compose
;; cleanly.
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

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(defun quote-string (s)
  (with-output-to-string (out)
    (write-char #\" out)
    (loop for ch across s
          do (case ch
               (#\\ (write-string "\\\\" out))
               (#\" (write-string "\\\"" out))
               (#\Newline (write-string "\\n" out))
               (t (write-char ch out))))
    (write-char #\" out)))

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §3 step 6 launch diagnostic — the bare line beginning `SceneKit Viewer` the
;; runner's `wait-for-log` matches; dual-emitted (the stdout print stays in
;; scenekit-viewer.lisp for unbundled runs). The sbcl wording differs from
;; racket/chez/gerbil by design — the contract asserts the prefix only.
(defun emit-launch-line ()
  (emit-line "SceneKit Viewer opened. Quit with Cmd-Q."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract mandates lowercase
;; `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The two [scene] events — each emitted AFTER the state change it names is fully
;;; applied (contract "Scene events"). `r`/`g`/`b` are the STORED current colour's
;;; device-RGB components ×255, rounded to nearest integer (bare integers 0–255) — the
;;; caller converts via colorUsingColorSpace: device-RGB at emit time and folds; the
;;; emitters take the already-folded integers.

;; `shape` is the applied catalogue title (Cube/Sphere/Torus/Cylinder) — identical to
;; the picker's selected-item title. Carries the post-swap colour so the §13 key
;; behaviour (colour persists across a swap) is a single-line assertion.
(defun emit-geometry-changed (shape r g b)
  (emit-line (format nil "[scene] geometry-changed shape=~a r=~d g=~d b=~d"
                     (quote-string shape) r g b)))

;; Success path only — a nil panel colour and a failed device-RGB conversion are
;; silent no-ops (no event, no error line; absence IS the contract).
(defun emit-color-changed (r g b)
  (emit-line (format nil "[scene] color-changed r=~d g=~d b=~d" r g b)))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
