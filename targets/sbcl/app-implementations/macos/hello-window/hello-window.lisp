;;;; hello-window.lisp — Hello Window sample app (sbcl target), the 060 ladder's first.
;;;;
;;;; Minimal macOS GUI: a 400x200 centred window with a centred 24pt label. Written
;;;; against the CL-family interface contract (ADR-0033 / the contract spec) so the
;;;; source is portable to a future CL-family member: it names only the `ns:` surface,
;;;; `make-instance` (contract §3.3), the per-selector generics (§3.2), and the `@"…"`
;;;; NSString reader macro (§3.2). Mirrors the chez/gerbil hello-window one control at a
;;;; time. Exercises:
;;;;   - NSApplication setup (shared instance, regular activation policy, run loop);
;;;;   - the standard app menu (Quit -> -[NSApplication terminate:]);
;;;;   - NSWindow's typed 4-arg designated init `initWithContentRect:styleMask:backing:
;;;;     defer:` (by-value NSRect + two enums + a BOOL — the ADR-0040 typed applier);
;;;;   - an NSTextField label via bare alloc/init + setFrame: (the inherited
;;;;     `initWithFrame:` is registered on NSControl/NSView, NOT on the subclass, and the
;;;;     init registry is exact-class — see learnings);
;;;;   - inherited generic dispatch (setStringValue:/setFont:/setAlignment: live on
;;;;     NSControl, the label is an NSTextField subclass — CLOS resolves it);
;;;;   - the `@"…"` reader making NSStrings, and `aw-with-rect` stack-allocating geometry.
;;;;
;;;; Every AppKit/Foundation call is PURE ObjC — no Swift-native trampoline residual — so the
;;;; run/build harness keeps `:load-residual nil`. It is NOT, however, dylib-free: the AppSpec
;;;; logging contract's `[lifecycle] shutdown reason=menu` event needs an
;;;; `applicationWillTerminate:` delegate callback, and an ObjC→Lisp callback on SBCL MUST
;;;; route through libAPIAnywareSbcl's subclass bounce shim (a `define-alien-callable`
;;;; installed AS an IMP runs Lisp on a foreign thread — the ADR-0035 crash). So the harness
;;;; loads the dylib for the subclass machinery only (no block factory, no trampoline residual),
;;;; like note-editor's `note-controller`. The `applicationWillTerminate:` delegate fires on the
;;;; osascript/Cmd-Q quit path the runner's `quit-impl!` / scenario `03` exercise.
;;;;
;;;; Instrumented for the AppSpec scenario runner per the Hello Window logging contract
;;;; (apps/macos/hello-window/docs/logging-contract.md): it writes the structured events.log
;;;; the runner tails — `[lifecycle] startup` (events.lisp / hw-events) before the run loop,
;;;; the bare `Hello Window opened.` launch diagnostic, and `[lifecycle] shutdown reason=menu`
;;;; from the terminate delegate. Under `launch-via 'open` LaunchServices discards stdout, so
;;;; the log file (not stdout) is the runner's read path; the stdout line is kept too
;;;; (human-friendly when run unbundled, true to spec §10).
;;;;
;;;; Package: `apianyware-sbcl-impl`. The portable contract surface is `ns:`; the
;;;; impl-package home (giving bare `make-instance`, `aw-with-rect`, the menu helper) and
;;;; the not-yet-portable geometry primitive are recorded as contract-surface follow-ups
;;;; in learnings.md — they don't affect the `ns:`-named Cocoa calls, which ARE portable.

(in-package #:apianyware-sbcl-impl)

(defun install-app-menu (app app-name)
  "Install a minimal standard macOS main menu: one application submenu carrying a Quit
   item bound to Cmd-Q -> `-[NSApplication terminate:]`. Built entirely through the
   contract surface — `make-instance` typed inits (the menu item's `:action` is a SEL
   arg, marshalled by the ADR-0040 applier) and the `ns:` menu generics."
  (let ((main-menu   (make-instance 'ns:ns-menu :init-with-title @""))
        (app-item    (make-instance 'ns:ns-menu-item
                       :init-with-title @"" :action "" :key-equivalent @""))
        (app-submenu (make-instance 'ns:ns-menu :init-with-title @""))
        (quit-item   (make-instance 'ns:ns-menu-item
                       :init-with-title (aw-wrap (aw-make-nsstring
                                                  (format nil "Quit ~A" app-name)) t)
                       :action "terminate:"
                       :key-equivalent @"q")))
    (ns:add-item_ app-submenu quit-item)
    (ns:add-item_ main-menu app-item)
    (ns:set-submenu_for-item_ main-menu app-submenu app-item)
    (ns:set-main-menu_ app main-menu)))

;;; --- Terminate delegate (logging contract: [lifecycle] shutdown reason=menu) ---------
;;; `applicationWillTerminate:` is the only hook that fires on the menu/Cmd-Q quit path:
;;; -[NSApplication terminate:] ends in a C exit(), which bypasses sb-ext:*exit-hooks*, so
;;; an AppKit-level delegate callback is the reliable shutdown signal. The subclass is
;;; synthesized at RUNTIME (not load) so it registers in the process that shows the UI — a
;;; class synthesized during `save-lisp-and-die` does NOT survive into the revived image
;;; (fresh ObjC runtime). `*hw-delegate-ready*` stays nil through the dump (dump.lisp never
;;; calls -main) and re-synthesizes at revive. Mirrors note-editor's `ensure-note-controller`.
(defvar *hw-delegate-ready* nil
  "nil until `ensure-hw-delegate` has synthesized the delegate class in THIS process. A
   revived image starts nil again and re-synthesizes.")

(defun ensure-hw-delegate ()
  "Define the `hw-app-delegate` ObjC subclass + its `applicationWillTerminate:` method.
   Idempotent within a process via `*hw-delegate-ready*`. The dylib's subclass dispatcher
   self-registers on this first `define-objc-method` (via `aw-install-override`)."
  (unless *hw-delegate-ready*
    (define-objc-subclass hw-app-delegate (ns:ns-object))   ; no slots — pure callback target
    ;; NSApplication auto-observes NSApplicationWillTerminateNotification for a delegate that
    ;; responds to this selector, so informal conformance (respond, don't declare the
    ;; protocol) suffices. Guarded: an unhandled error in an ObjC callback crashes the app
    ;; with no Lisp backtrace.
    (define-objc-method (hw-app-delegate "applicationWillTerminate:") (self notification)
      (declare (ignore self notification))
      (handler-case
          (progn (hw-events:emit-shutdown 'menu) (hw-events:close-events!))
        (error (e)
          (format *error-output* "applicationWillTerminate delegate error: ~A~%" e)
          (finish-output *error-output*))))
    (setf *hw-delegate-ready* t)))

(defun hello-window-main (&key (run t))
  "Build the hello-window UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060/020): it performs every FFI crossing
   the app does — the typed window/menu inits, the property setters, the NSFont class
   method, makeKeyAndOrderFront:/activate, AND the delegate subclass synthesis + set-delegate
   (the logging-contract terminate hook) — then returns WITHOUT blocking on `-run`, so a bare
   `sbcl --load` validates marshalling (and, in the revived image, the subclass re-synthesis)
   before the VM round-trip. The real run (the dumped executable's toplevel) calls with RUN t."
  (ensure-hw-delegate)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Hello Window")

    ;; --- Structured event log: open + [lifecycle] startup BEFORE the run loop ---
    ;; `startup` must land before the app blocks in (ns:run app) or the runner's `wait-ready`
    ;; readiness probe times out. Gated on the real run — the build-time smoke needs no log
    ;; file. Test-config compatibility (logging-contract.md): Hello Window has no
    ;; runtime-configurable behaviour, so it honours HELLO_WINDOW_TEST_CONFIG by reading the
    ;; env var and treating absent/empty as "no config" — a deliberate no-op.
    (when run
      (hw-events:events-init!)
      (hw-events:emit-startup)
      (sb-ext:posix-getenv "HELLO_WINDOW_TEST_CONFIG"))

    ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
    ;; Installed unconditionally so the pre-flight / revive smoke exercises the subclass
    ;; bounce shim + set-delegate. The instance is pinned in *subclass-instances* (a STRONG
    ;; table — subclass.lisp), so Cocoa's weak delegate reference never reaps it.
    (ns:set-delegate_ app (make-instance 'hw-app-delegate))

    ;; --- Window (400x200, centred) ---
    (aw-with-rect (frame 0 0 400 200)
      (let ((window (make-instance 'ns:ns-window
                      :init-with-content-rect frame
                      :style-mask (logior ns:ns-window-style-mask-titled
                                          ns:ns-window-style-mask-closable
                                          ns:ns-window-style-mask-miniaturizable)
                      :backing ns:ns-backing-store-buffered
                      :defer nil)))
        (ns:set-title_ window @"Hello from SBCL")
        (ns:center window)

        ;; --- Label (centred in the window) ---
        (let ((label (make-instance 'ns:ns-text-field)))   ; bare init; set frame next
          (aw-with-rect (label-frame 0 70 400 60)
            (ns:set-frame_ label label-frame))
          (ns:set-string-value_ label @"Hello, macOS!")
          (ns:set-font_ label (ns:system-font-of-size_ (find-class 'ns:ns-font) 24.0d0))
          (ns:set-alignment_ label ns:ns-text-alignment-center)
          (ns:set-editable_ label nil)
          (ns:set-selectable_ label nil)
          (ns:set-bezeled_ label nil)
          (ns:set-draws-background_ label nil)
          (ns:add-subview_ (ns:content-view window) label))

        ;; --- Show + run ---
        (ns:make-key-and-order-front_ window nil)
        (ns:activate-ignoring-other-apps_ app t)
        ;; Launch diagnostic (spec §10): the bare line the runner's `wait-for-log` matches
        ;; in events.log, plus the human-friendly stdout line (kept for unbundled runs;
        ;; LaunchServices discards stdout under `open`).
        (when run
          (hw-events:emit-opened)
          (format t "~&Hello Window opened. Quit with Cmd-Q.~%")
          (finish-output)
          (ns:run app))))))
