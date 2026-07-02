;;;; events.lisp — Mini Browser structured event log (sbcl target).
;;;;
;;;; The k114 logging contract
;;;; (apps/macos/mini-browser/docs/logging-contract.md): the three hello-window
;;;; lifecycle events plus the three [nav] navigation-state events the spec §13
;;;; assertions ride (loads resolve on WebKit's schedule — completion/failure are not
;;;; assertable without a log record — and the ◀/▶ history enabled flags are dropped by
;;;; the AX-snapshot transform, so the log is their operative channel):
;;;;   [lifecycle] startup                          — readiness probe (`wait-ready`)
;;;;   Mini Browser opened. …                       — §3 step 7 launch diagnostic; BARE line
;;;;   [lifecycle] shutdown reason=<r>              — terminate; reason ∈ {menu,signal,error}
;;;;   [nav] started url="…"                        — didStartProvisionalNavigation, post-state
;;;;   [nav] finished url="…" title="…" can-go-back=<b> can-go-forward=<b>
;;;;                                                — didFinishNavigation, after the whole §7.2 refresh
;;;;   [nav] failed phase=<request|load> message="…" — both failure callbacks; PRE-runModal
;;;;
;;;; The runner tails this file (AppSpec/runner/log-tail.rkt) rather than reading
;;;; stdout: `launch-via 'open` discards an app's stdout via LaunchServices. Reference
;;;; emitters: the scenekit-viewer events.lisp (this target's k110 sibling) and the
;;;; racket mini-browser events.rkt (the k116 reference pattern).
;;;;
;;;; Single writer: every event is emitted on the main thread — startup/launch before
;;;; `-run`, the [nav] events from the four WKNavigationDelegate callbacks (WebKit
;;;; delivers them on main — spec §10), shutdown on the terminate path — so one stream
;;;; with a post-write `finish-output` suffices.
;;;;
;;;; PURE Common Lisp — no AppKit / WebKit / dylib dependency — so it loads +
;;;; unit-tests in isolation (`sbcl --script` loads this file then calls the emitters;
;;;; the only non-ANSI surface is `sb-ext:posix-getenv`). mini-browser.lisp references
;;;; it through the `mb-events` nickname; run.lisp / dump.lisp load this file first.

(defpackage #:apianyware-sbcl-mini-browser-events
  (:use #:cl)
  (:nicknames #:mb-events)
  (:export #:events-init! #:emit-startup #:emit-launch-line #:emit-shutdown
           #:emit-nav-started #:emit-nav-finished #:emit-nav-failed
           #:close-events! #:events-log-path))

(in-package #:apianyware-sbcl-mini-browser-events)

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the same
;; file whether or not #:log-env (MINI_BROWSER_EVENTS_LOG) propagates through
;; LaunchServices.
(defparameter *default-events-path* "/tmp/mini-browser/events.log")

(defvar *port* nil)
(defvar *path* nil)

;; MINI_BROWSER_EVENTS_LOG if set and non-empty, else the fixed default.
(defun resolve-path ()
  (let ((env (sb-ext:posix-getenv "MINI_BROWSER_EVENTS_LOG")))
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

;; Booleans emit as the bare bytes `true` / `false` (contract "Line format") — never a
;; runtime print form like T/NIL.
(defun bool-word (b) (if b "true" "false"))

(defun emit-startup () (emit-line "[lifecycle] startup"))

;; The §3 step 7 launch diagnostic — the bare line beginning `Mini Browser` the
;; runner's `wait-for-log` matches; dual-emitted (the stdout print stays in
;; mini-browser.lisp for unbundled runs). The sbcl wording differs from
;; racket/chez/gerbil by design — the contract asserts the prefix only.
(defun emit-launch-line ()
  (emit-line "Mini Browser opened. Type a URL + Return, navigate with ◀/▶/Reload. Quit with Cmd-Q."))

;; `~(~a~)` downcases REASON: CL's default *print-case* is :upcase, so a bare ~a on the
;; symbol 'menu would emit `reason=MENU` — but the contract mandates lowercase
;; `reason ∈ {menu, signal, error}`.
(defun emit-shutdown (reason)
  (emit-line (format nil "[lifecycle] shutdown reason=~(~a~)" reason)))

;;; The three [nav] events — the navigation-state transitions of spec §7, mirroring the
;;; four WKNavigationDelegate callbacks (the two failure callbacks fold into one event).
;;; URL/TITLE arrive as already-read Lisp strings ("" when the property was nil — the
;;; caller's read helpers own that fold); the emitters only quote and order keys.

;; didStartProvisionalNavigation (§7.1), post-state (loading status set). URL witnesses
;; the normalized (https://-prepended) form even when the load then fails offline.
(defun emit-nav-started (url)
  (emit-line (format nil "[nav] started url=~a" (quote-string url))))

;; didFinishNavigation (§7.2), after the WHOLE chrome-refresh rule. Fixed key order
;; `url title can-go-back can-go-forward` (contract "Navigation events"); BACK/FORWARD
;; are the web view's history getters read in the same refresh that set the buttons.
(defun emit-nav-finished (url title back forward)
  (emit-line (format nil "[nav] finished url=~a title=~a can-go-back=~a can-go-forward=~a"
                     (quote-string url) (quote-string title)
                     (bool-word back) (bool-word forward))))

;; Both §7.3 failure callbacks, at rule entry — message computed, BEFORE runModal (the
;; runner's pre-dismissal cue; the contract's one deliberate pre-state deviation).
;; PHASE arrives normalized lowercase (`request` / `load`) — the status line's
;; capitalized spelling (`Load failed: …`) stays as realized, only the log key is
;; normalized.
(defun emit-nav-failed (phase message)
  (emit-line (format nil "[nav] failed phase=~a message=~a"
                     phase (quote-string message))))

(defun close-events! ()
  (when *port*
    (handler-case (progn (finish-output *port*) (close *port*))
      ((or stream-error file-error) () nil))
    (setf *port* nil *path* nil)))
