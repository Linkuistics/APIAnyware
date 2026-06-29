#lang racket/base
;; hello-window.rkt — Hello Window sample app (OO style)
;;
;; Minimal macOS GUI: creates a window with a centered label.
;; Exercises: NSApplication setup, NSWindow creation, NSTextField as label,
;;            property setters, object lifecycle, event loop.
;;
;; Instrumented for the AppSpec scenario runner per the Hello Window logging
;; contract (apps/macos/hello-window/docs/logging-contract.md): it writes a
;; structured events.log the runner tails — [lifecycle] startup, the bare
;; "Hello Window opened." launch diagnostic, and [lifecycle] shutdown reason=…
;; on terminate. Under `launch-via 'open` stdout is discarded by LaunchServices,
;; so the log file (not stdout) is the runner's read path; the stdout displayln
;; is kept too (human-friendly when run unbundled, true to spec §10).
;;
;; Run with: racket hello-window.rkt — but note the ../../{generated,runtime}
;;   requires resolve only via the bundler's SourceRoots::split, so the built
;;   .app (apianyware-bundle-racket) is the runnable artifact, not this file.

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/app-menu.rkt"
         "../../runtime/delegate.rkt"
         "events.rkt")

;; --- Constants (not yet extracted by collector) ---
;; NSWindowStyleMask
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSTextAlignment (macOS modern values — Left=0, Center=1, Right=2)
(define NSTextAlignmentCenter 1)

;; --- Structured event log (logging contract) ---
;; Open + truncate the events.log the runner tails, then record [lifecycle]
;; startup BEFORE entering the AppKit run loop (or `wait-ready` times out).
(events-init!)
(emit-startup)

;; Test-config compatibility (logging-contract.md "Test-config compatibility"):
;; Hello Window has no runtime-configurable behaviour, so it honours the
;; HELLO_WINDOW_TEST_CONFIG contract by reading the env var and treating an
;; absent/empty value (and a missing file) as "no config" — a deliberate no-op.
(void (getenv "HELLO_WINDOW_TEST_CONFIG"))

;; --- Shutdown wiring (signal / error paths) ---
;; The logging contract requires a [lifecycle] shutdown line on terminate.
;; The menu/Cmd-Q path goes through applicationWillTerminate: (delegate below);
;; SIGTERM/SIGINT reach Racket as exn:break → reason=signal, and any other
;; uncaught exception → reason=error.
(uncaught-exception-handler
 (lambda (exn)
   (with-handlers ([exn:fail? (lambda (_) (void))])
     (if (exn:break? exn)
         (emit-shutdown 'signal)
         (emit-shutdown 'error))
     (close-events!))
   (exit (if (exn:break? exn) 130 1))))

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; NSApplicationActivationPolicyRegular

;; Standard macOS app menu (About / Hide / Quit). Bold app-name slot
;; in the menu bar comes from CFBundleName when launched as a .app
;; bundle (see `apianyware-bundle-racket`).
(install-standard-app-menu! app "Hello Window")

;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
;; Cocoa holds delegates weakly, so keep a module-scope reference. The body is
;; wrapped in with-handlers because an unhandled exception in an ObjC callback
;; crashes the app with no Racket stack trace.
(define app-delegate
  (make-delegate
   "applicationWillTerminate:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationWillTerminate delegate error: ~a\n"
                                 (exn-message e)))])
       (emit-shutdown 'menu)
       (close-events!)))))
(void (nsapplication-set-delegate! app app-delegate))

;; --- Create window (400x200, centered) ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 400 200)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable)
   NSBackingStoreBuffered
   #f))

(nswindow-set-title! window "Hello from Racket")
(nswindow-center! window)

;; --- Create label (centered in window) ---
(define label
  (make-nstextfield-init-with-frame (make-nsrect 0 70 400 60)))

(nstextfield-set-string-value! label "Hello, macOS!")
(nstextfield-set-font! label (nsfont-system-font-of-size 24.0))
(nstextfield-set-alignment! label NSTextAlignmentCenter)
(nstextfield-set-editable! label #f)
(nstextfield-set-selectable! label #f)
(nstextfield-set-bezeled! label #f)
(nstextfield-set-draws-background! label #f)

;; --- Add label to window ---
(define content-view (nswindow-content-view window))
(nsview-add-subview! content-view label)

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

;; Launch diagnostic (spec §10): the bare line the runner's `wait-for-log`
;; matches, plus the human-friendly stdout line (kept for unbundled runs).
(emit-opened)
(displayln "Hello Window opened. Close the window or press Ctrl+C to exit.")
(nsapplication-run app)
