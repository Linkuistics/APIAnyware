;; hello-window.sls — Hello Window sample app (chez target).
;;
;; Minimal macOS GUI: creates a window with a centred label. Exercises
;; NSApplication setup, NSWindow creation, NSTextField as label,
;; property setters, object lifecycle, and the event loop. Mirrors
;; generation/targets/racket/apps/hello-window/hello-window.rkt one
;; control at a time.
;;
;; Instrumented for the AppSpec scenario runner per the Hello Window logging
;; contract (apps/macos/hello-window/docs/logging-contract.md): it writes a
;; structured events.log the runner tails — [lifecycle] startup, the bare
;; "Hello Window opened." launch diagnostic, and [lifecycle] shutdown reason=…
;; on terminate. Under `launch-via 'open` LaunchServices discards the app's
;; stdout, so the log file (not stdout) is the runner's read path; the stdout
;; line is kept too (human-friendly when run unbundled, true to spec §10).
;;
;; The logging is inlined here rather than extracted to a sibling `events.sls`:
;; chez resolves `(import …)` by library-name→path against the whole-program
;; compile tree (logical `apps/<script>/`), so a sibling library would need an
;; `apps/`-prefixed name. These top-level defines use only `(chezscheme)` names,
;; so the standalone bundler resolves them with no new library on the path.
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/hello-window/hello-window.sls
;; Bundled (the runnable artifact) via build.sh, which wraps
;;   `cargo run --example bundle_app -p apianyware-bundle-chez -- hello-window`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit, so one port with a post-write flush suffices (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the
;; same file whether or not #:log-env (HELLO_WINDOW_EVENTS_LOG) propagates
;; through LaunchServices.
(define hw-default-events-path "/tmp/hello-window/events.log")
(define hw-events-port #f)

;; HELLO_WINDOW_EVENTS_LOG if set and non-empty, else the fixed default.
(define (hw-resolve-events-path)
  (let ([env (getenv "HELLO_WINDOW_EVENTS_LOG")])
    (if (and env (not (string=? env ""))) env hw-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (hw-path-parent p)
  (let loop ([i (- (string-length p) 1)])
    (cond
      [(< i 0) #f]
      [(char=? (string-ref p i) #\/) (substring p 0 i)]
      [else (loop (- i 1))])))

;; Open + truncate the events.log: (file-options no-fail) creates it if absent
;; and truncates it if present. Line-buffered so a tail sees each record
;; promptly. The parent dir is created if missing (guarded against a race).
(define (hw-events-init!)
  (let* ([target (hw-resolve-events-path)]
         [parent (hw-path-parent target)])
    (when (and parent (not (string=? parent "")) (not (file-directory? parent)))
      (guard (e [#t (void)]) (mkdir parent)))
    (set! hw-events-port
      (open-file-output-port target
        (file-options no-fail)
        (buffer-mode line)
        (make-transcoder (utf-8-codec))))))

(define (hw-emit-line line)
  (when hw-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (guard (e [#t (void)])
      (put-string hw-events-port line)
      (put-char hw-events-port #\newline)
      (flush-output-port hw-events-port))))

(define (hw-emit-startup)          (hw-emit-line "[lifecycle] startup"))
(define (hw-emit-opened)           (hw-emit-line "Hello Window opened."))
(define (hw-emit-shutdown reason)  (hw-emit-line (format "[lifecycle] shutdown reason=~a" reason)))

(define (hw-close-events!)
  (when hw-events-port
    (guard (e [#t (void)])
      (flush-output-port hw-events-port)
      (close-output-port hw-events-port)))
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
  (getenv "HELLO_WINDOW_TEST_CONFIG")

  (let ([app (nsapplication-shared-application)])
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)

    ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
    ;; The osascript graceful quit the runner uses (quit-impl! / scenario 03's
    ;; Command-Q) routes through applicationWillTerminate:. Cocoa holds the
    ;; delegate weakly, so keep `app-delegate` reachable — this `let` spans the
    ;; run loop. The callback body is guarded because an unhandled exception in
    ;; an ObjC callback crashes the app with no Scheme backtrace.
    (let ([app-delegate
           (make-delegate
             `(("applicationWillTerminate:"
                ,(lambda (notification)
                   (guard (e [#t (void)])
                     (hw-emit-shutdown 'menu)
                     (hw-close-events!)))
                (void*) void)))])
      (nsapplication-set-delegate! app (delegate-ptr app-delegate))

      ;; Standard macOS app menu (About / Hide / Quit). The bold app-name
      ;; slot in the menu bar comes from CFBundleName when launched as a
      ;; .app bundle (see bundle-chez); unbundled it reads "chez".
      (install-standard-app-menu! app "Hello Window")

      ;; --- Create window (400x200, centred) ---
      (let ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                      (make-nsrect 0 0 400 200)
                      (bitwise-ior NSWindowStyleMaskTitled
                                   NSWindowStyleMaskClosable
                                   NSWindowStyleMaskMiniaturizable)
                      NSBackingStoreBuffered
                      #f)])
        (nswindow-set-title! window "Hello from Chez")
        (nswindow-center! window)

        ;; --- Create label (centred in window) ---
        (let ([label (make-nstextfield-init-with-frame
                       (make-nsrect 0 70 400 60))])
          (nstextfield-set-string-value! label "Hello, macOS!")
          (nstextfield-set-font! label (nsfont-system-font-of-size 24.0))
          (nstextfield-set-alignment! label NSTextAlignmentCenter)
          (nstextfield-set-editable! label #f)
          (nstextfield-set-selectable! label #f)
          (nstextfield-set-bezeled! label #f)
          (nstextfield-set-draws-background! label #f)

          (nsview-add-subview! (nswindow-content-view window) label))

        ;; --- Show window and run ---
        (nswindow-make-key-and-order-front window #f)
        (nsapplication-activate-ignoring-other-apps app #t)

        ;; Launch diagnostic (spec §10): the bare line the runner's `wait-for-log`
        ;; matches in events.log, plus the human-friendly stdout line (kept for
        ;; unbundled runs; LaunchServices discards stdout under `open`).
        (hw-emit-opened)
        (display "Hello Window opened. Close the window or press Ctrl+C to exit.\n")
        (nsapplication-run app)))))

(main)
