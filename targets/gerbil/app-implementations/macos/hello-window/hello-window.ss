;;; hello-window.ss — Hello Window sample app (gerbil target).
;;;
;;; Minimal macOS GUI: a window with a centred label. Exercises NSApplication
;;; setup, the standard app menu, NSWindow creation (NSRect by value), an
;;; NSTextField label, inherited-method dispatch via the proc cores of the
;;; declaring superclass (NSControl/NSView), object lifecycle, and the event
;;; loop. Mirrors generation/targets/chez/apps/hello-window/hello-window.sls
;;; one control at a time.
;;;
;;; Instrumented for the AppSpec scenario runner per the Hello Window logging
;;; contract (apps/macos/hello-window/docs/logging-contract.md): it writes a
;;; structured events.log the runner tails — [lifecycle] startup, the bare
;;; "Hello Window opened." launch diagnostic, and [lifecycle] shutdown reason=…
;;; on terminate. Under `launch-via 'open` LaunchServices discards the app's
;;; stdout, so the log file (not stdout) is the runner's read path; the stdout
;;; line is kept too (human-friendly when run unbundled, true to spec §10).
;;;
;;; The logging uses only Gambit primitives (open-output-file, getenv,
;;; create-directory, force-output), so it needs no new import on the
;;; bundle-gerbil closure path: only `:gerbil-bindings/…` references are walked
;;; (deps.rs), and the Gambit prelude is statically linked by `gxc -exe`.
;;; Inlined rather than split to a sibling `events.ss`, which would have to sit
;;; under the bindings package root to be on GERBIL_LOADPATH (the racket
;;; events.rkt split is colocated; chez inlined for the same reason).
;;;
;;; Build via the bottle toolchain (which already embeds the Gerbil/Gambit
;;; runtime — `gxc -exe` links libgambit.a; no static source toolchain needed,
;;; see the app README + spec §7). The link line carries -lobjc, -framework
;;; AppKit/Foundation, and the clang-compiled native_block.o companion.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/enums)
(export main)

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit, so one port with a post-write force-output suffices (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the
;; same file whether or not #:log-env (HELLO_WINDOW_EVENTS_LOG) propagates
;; through LaunchServices.
(define hw-default-events-path "/tmp/hello-window/events.log")
(define hw-events-port #f)

;; HELLO_WINDOW_EVENTS_LOG if set and non-empty, else the fixed default.
(define (hw-resolve-events-path)
  (let ((env (getenv "HELLO_WINDOW_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env hw-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (hw-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in hw-emit-line, so a
;; tail sees each promptly.
(define (hw-events-init!)
  (let* ((target (hw-resolve-events-path))
         (parent (hw-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! hw-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (hw-emit-line line)
  (when hw-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line hw-events-port)
        (newline hw-events-port)
        (force-output hw-events-port)))))

(define (hw-emit-startup)          (hw-emit-line "[lifecycle] startup"))
(define (hw-emit-opened)           (hw-emit-line "Hello Window opened."))
(define (hw-emit-shutdown reason)  (hw-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

(define (hw-close-events!)
  (when hw-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output hw-events-port)
        (close-output-port hw-events-port))))
  (set! hw-events-port #f))

(define-entry-point (main)
  ;; --- Structured event log: open + [lifecycle] startup BEFORE the run loop ---
  ;; `startup` must land before the app blocks in (nsapplication-run …) or the
  ;; runner's `wait-ready` readiness probe times out.
  (hw-events-init!)
  (hw-emit-startup)

  ;; Test-config compatibility (logging-contract.md): Hello Window has no
  ;; runtime-configurable behaviour, so it honours HELLO_WINDOW_TEST_CONFIG by
  ;; reading the env var and treating absent/empty as "no config" — a no-op.
  (getenv "HELLO_WINDOW_TEST_CONFIG" #f)

  (let (app (nsapplication-shared-application))
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)

    ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
    ;; The osascript graceful quit the runner uses (quit-impl! / scenario 03's
    ;; Command-Q) routes through applicationWillTerminate:. make-delegate pins
    ;; the synthesized instance in *delegate-roots* for the process (AppKit holds
    ;; the delegate weakly), so it survives across the nsapplication-run FFI
    ;; boundary; the `let` keeps it lexically reachable too. The callback ignores
    ;; its NSNotification arg; an unhandled exception in an ObjC callback would
    ;; crash the app, so make-imp-callback-closure runs it under the runtime's
    ;; coercion and we keep the body trivial.
    (let (app-delegate
           (make-delegate
             (list (list "applicationWillTerminate:"
                         (lambda (notification)
                           (hw-emit-shutdown 'menu)
                           (hw-close-events!))
                         (list 'object)        ; the NSNotification → wrapped
                         'void))))
      (nsapplication-set-delegate! app app-delegate)

      ;; Standard macOS app menu (About / Hide / Quit). The bold app-name slot in
      ;; the menu bar comes from CFBundleName when launched as a .app bundle
      ;; (leaf 070/030); unbundled it reads the exe name.
      (install-standard-app-menu! app "Hello Window")

      ;; --- Window (400x200, centred) ---
      (let (window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                     (make-rect 0. 0. 400. 200.)
                     (bitwise-ior NSWindowStyleMaskTitled
                                  NSWindowStyleMaskClosable
                                  NSWindowStyleMaskMiniaturizable)
                     NSBackingStoreBuffered
                     #f))
        (nswindow-set-title! window (string->nsstring "Hello from Gerbil"))
        (nswindow-center! window)

        ;; --- Label (centred in window) ---
        (let (label (make-nstextfield))
          (nsview-set-frame! label (make-rect 0. 70. 400. 60.))
          (nscontrol-set-string-value! label (string->nsstring "Hello, macOS!"))
          (nscontrol-set-font! label (nsfont-system-font-of-size 24.))
          (nscontrol-set-alignment! label NSTextAlignmentCenter)
          (nstextfield-set-editable! label #f)
          (nstextfield-set-selectable! label #f)
          (nstextfield-set-bezeled! label #f)
          (nstextfield-set-draws-background! label #f)
          (nsview-add-subview! (nswindow-content-view window) label))

        ;; --- Show and run ---
        (nswindow-make-key-and-order-front window #f)
        (nsapplication-activate-ignoring-other-apps app #t)

        ;; Launch diagnostic (spec §10): the bare line the runner's `wait-for-log`
        ;; matches in events.log, plus the human-friendly stdout line (kept for
        ;; unbundled runs; LaunchServices discards stdout under `open`).
        (hw-emit-opened)
        (displayln "Hello Window opened. Close the window or press Ctrl+C to exit.")
        (nsapplication-run app)))))

(main)
