;;;; runtime/reader-syntax.lisp — the contract §3.2 reader macros (surfaced 060/020).
;;;;
;;;; The CL-family contract (§3.2, ADR-0033) names two reader macros every member MUST
;;;; provide — `@"…"` for an `NSString` literal and `#/selector` for a selector — and the
;;;; SBCL design spec assigns "readers in runtime". They were specified but never built;
;;;; the first GUI app (`060/020-hello-window`) is the forcing function: an app written
;;;; against the contract has no other portable way to make an `NSString` (the generated
;;;; setters take an *object* — `ns:set-title_` calls `(aw-ptr value)` — never a Lisp
;;;; string), so it needs `@"…"`.
;;;;
;;;; This unit realizes `@"…"`. `#/` is DEFERRED (no app on the ladder needs it — the
;;;; generated surface is named per-selector generics, not raw `objc_msgSend`, so a
;;;; selector literal is never on an app's critical path; it wants its own focused unit +
;;;; tests). See the 060/020 running log + learnings for the deferral.
;;;;
;;;; Loaded LAST in the dev order (after the string bridge + the metaclass `make-instance`
;;;; that `aw-wrap` drives both exist), and installs into the GLOBAL `*readtable*` at load
;;;; so any file read after the runtime — i.e. the app — just sees `@"…"` with no ceremony
;;;; (CCL installs `@` globally too). Safe: no generated/runtime/smoke `.lisp` file carries
;;;; a token beginning with `@`, and `@` is registered NON-terminating so it only acts as a
;;;; macro character at the start of a token (a hypothetical `foo@bar` symbol still reads).

(in-package #:apianyware-sbcl-impl)

(defun aw-read-nsstring (stream char)
  "The `@` reader macro (contract §3.2): `@\"text\"` reads as a form that, at run time,
   yields a lifetime-managed `ns:ns-string` instance — `(aw-wrap (aw-make-nsstring …) t)`.
   `aw-make-nsstring` returns a +1 `NSString`; `aw-wrap … t` takes that ownership and arms
   the main-thread release finalizer (ADR-0036), so the literal needs no manual free. The
   expansion is written here (impl package), so the captured `aw-wrap`/`aw-make-nsstring`
   are impl symbols regardless of the package the app `@\"…\"` is read in.

   Only the string form `@\"…\"` is accepted; `@` before anything else signals (CCL also
   spells `@selector`/`@(…)`, deferred with `#/` until an app needs them)."
  (declare (ignore char))
  (let ((next (peek-char nil stream t nil t)))
    (unless (char= next #\")
      (error "The @ reader macro must be followed by a string literal, e.g. @\"text\" ~
              (got @~A)" next))
    (let ((text (read stream t nil t)))         ; the standard reader consumes the "…"
      `(aw-wrap (aw-make-nsstring ,text) t))))

(defun aw-install-reader-syntax (&optional (readtable *readtable*))
  "Install the contract §3.2 reader macros into READTABLE (the current `*readtable*` by
   default). Idempotent. `@` is NON-terminating, so it only fires at token start. Called
   at runtime load so the app sees `@\"…\"` for free; re-callable by a builder that
   rebinds `*readtable*`."
  (set-macro-character #\@ #'aw-read-nsstring t readtable)
  readtable)

(aw-install-reader-syntax)

(export '(aw-install-reader-syntax) '#:apianyware-sbcl-impl)
