;;;; events.lisp — UI Controls Gallery structured event log (sbcl target).
;;;;
;;;; The k87 logging contract
;;;; (apps/macos/ui-controls-gallery/docs/logging-contract.md): the three
;;;; hello-window lifecycle events plus the four [controls] state-change events
;;;; the spec §13 interaction assertions ride (the runner's `expect-ax` matches
;;;; role + exact title only — it has no value/state read):
;;;;   [lifecycle] startup                        — readiness probe (`wait-ready`)
;;;;   Controls Gallery opened. …                 — §3.6 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>            — terminate; reason ∈ {menu,signal,error}
;;;;   [controls] radio-selected option="…"       — radio action; post-state sole selection
;;;;   [controls] checkbox-changed state=on|off   — checkbox action; post-toggle state
;;;;   [controls] slider-changed value=<int>      — slider action; double → nearest int
;;;;   [controls] stepper-changed value=<int>     — stepper action; integral value
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading stdout:
;;;; `launch-via 'open` discards an app's stdout via LaunchServices. Reference emitters:
;;;; the hello-window events.lisp (this target's worked template) and the racket gallery
;;;; events.rkt (the k89 reference pattern).
;;;;
;;;; PURE Common Lisp — no AppKit / Foundation / dylib dependency — so it loads + unit-tests
;;;; in isolation (`sbcl --script` loads this file then calls the emitters; the only
;;;; non-ANSI surface is `sb-ext:posix-getenv`). ui-controls-gallery.lisp references it
;;;; through the `ucg-events` nickname; run.lisp / dump.lisp load this file first.
;;;;
;;;; Single writer: the Cocoa run loop serialises the main-thread callbacks that emit —
;;;; startup/launch before `-run`, the [controls] events from action callbacks, shutdown
;;;; on the terminate path — so one stream with a post-write `finish-output` suffices.

(defpackage #:apianyware-sbcl-ui-controls-gallery-events
  (:use #:cl)
  (:nicknames #:ucg-events)
  (:export #:events-init! #:emit-startup #:emit-opened #:emit-shutdown
           #:emit-radio-selected #:emit-checkbox-changed
           #:emit-slider-changed #:emit-stepper-changed
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-ui-controls-gallery-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same file
;; whether or not #:log-env (UI_CONTROLS_GALLERY_EVENTS_LOG) propagates through
;; LaunchServices.
(defparameter *default-events-path* "/tmp/ui-controls-gallery/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; UI_CONTROLS_GALLERY_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "UI_CONTROLS_GALLERY_EVENTS_LOG")))
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
(defun emit-opened ()  (emit-line "Controls Gallery opened. Quit with Cmd-Q."))
;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract mandates lowercase
;; `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The four [controls] events — each emitted from its control's action callback AFTER
;;; the state change it names is applied.

(defun emit-radio-selected (title)
  (emit-line (format nil "[controls] radio-selected option=~a" (quote-string title))))

(defun emit-checkbox-changed (on?)
  (emit-line (format nil "[controls] checkbox-changed state=~a" (if on? "on" "off"))))

;; The slider carries a double; the contract formats values as integers (round to
;; nearest) so the clamped ends are exactly 0/100.
(defun emit-slider-changed (value)
  (emit-line (format nil "[controls] slider-changed value=~d" (round value))))

;; Stepper values (0–10 step 1) are integral already; ROUND normalizes the double.
(defun emit-stepper-changed (value)
  (emit-line (format nil "[controls] stepper-changed value=~d" (round value))))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
