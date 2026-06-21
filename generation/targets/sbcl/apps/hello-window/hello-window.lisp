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
;;;; The app is PURE ObjC — no Swift-native residual — so it needs no libAPIAnywareSbcl
;;;; dylib; the run/build harness loads bindings with `:load-residual nil`.
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

(defun hello-window-main (&key (run t))
  "Build the hello-window UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060/020): it performs every FFI crossing
   the app does — the typed window/menu inits, the property setters, the NSFont class
   method, makeKeyAndOrderFront:/activate — then returns WITHOUT blocking on `-run`, so a
   bare `sbcl --load` validates marshalling before the VM round-trip. The real run (the
   dumped executable's toplevel) calls with RUN t."
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Hello Window")

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
        (when run
          (format t "~&Hello Window opened. Quit with Cmd-Q.~%")
          (finish-output)
          (ns:run app))))))
