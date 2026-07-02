;; pdfkit-viewer.sls — PDFKit Viewer sample app (chez target).
;;
;; Minimal PDF viewer: Open a .pdf via NSOpenPanel, render it in a
;; PDFView, navigate pages via toolbar buttons, and keep a "Page n of N"
;; label in sync via PDFViewPageChangedNotification. Mirrors
;; generation/targets/racket/apps/pdfkit-viewer/pdfkit-viewer.rkt.
;;
;; Exercises one chez `make-delegate` carrying four selectors
;; (openDocument:, goPrev:, goNext:, pageChanged:) — the first chez
;; sample with rung 4 of the feature ladder: one delegate record both
;; target-action target AND NSNotificationCenter observer.
;;
;; The body of `(define-entry-point (main) ...)` is a procedure body
;; in R6RS terms — all internal `define`s precede every expression.
;; Mixing them is what `(import (chezscheme))` rejects at script load
;; with "invalid context for definition".
;;
;; Instrumented for the AppSpec scenario runner per the PDFKit Viewer
;; logging contract (apps/macos/pdfkit-viewer/docs/logging-contract.md):
;; it writes a structured events.log the runner tails — [lifecycle]
;; startup/shutdown, the bare launch line, and the two [document]
;; state-transition events (opened / page-changed) that make the spec §13
;; document assertions observable (the nav-button enabled flags are
;; dropped by the AX-snapshot transform, and the label's OCR can catch a
;; pre-repaint frame). Under `launch-via 'open` LaunchServices discards
;; the app's stdout, so the log file (not stdout) is the runner's read
;; path; the stdout line is kept too (human-friendly when run unbundled).
;;
;; The logging is inlined here rather than extracted to a sibling
;; `events.sls` for the same reason as hello-window / ui-controls-gallery:
;; chez resolves `(import …)` by library-name→path against the
;; whole-program compile tree, so a sibling library would need an
;; `apps/`-prefixed name. These top-level defines use only (chezscheme)
;; names, so the standalone bundler resolves them with no new library on
;; the path.
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/pdfkit-viewer/pdfkit-viewer.sls
;; Bundled (the runnable artifact) via build.sh, which wraps
;;   `cargo run --example bundle_app -p apianyware-bundle-chez
;;    -- pdfkit-viewer`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware pdfkit)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [document] events from the
;; open-button action callback and the page-changed notification observer,
;; shutdown on terminate — so one port with a post-write flush suffices (no
;; lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (PDFKIT_VIEWER_EVENTS_LOG)
;; propagates through LaunchServices.
(define pv-default-events-path "/tmp/pdfkit-viewer/events.log")
(define pv-events-port #f)

;; PDFKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (pv-resolve-events-path)
  (let ([env (getenv "PDFKIT_VIEWER_EVENTS_LOG")])
    (if (and env (not (string=? env ""))) env pv-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (pv-path-parent p)
  (let loop ([i (- (string-length p) 1)])
    (cond
      [(< i 0) #f]
      [(char=? (string-ref p i) #\/) (substring p 0 i)]
      [else (loop (- i 1))])))

;; Open + truncate the events.log: (file-options no-fail) creates it if absent
;; and truncates it if present. Line-buffered so a tail sees each record
;; promptly. The parent dir is created if missing (guarded against a race).
(define (pv-events-init!)
  (let* ([target (pv-resolve-events-path)]
         [parent (pv-path-parent target)])
    (when (and parent (not (string=? parent "")) (not (file-directory? parent)))
      (guard (e [#t (void)]) (mkdir parent)))
    (set! pv-events-port
      (open-file-output-port target
        (file-options no-fail)
        (buffer-mode line)
        (make-transcoder (utf-8-codec))))))

(define (pv-emit-line line)
  (when pv-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (guard (e [#t (void)])
      (put-string pv-events-port line)
      (put-char pv-events-port #\newline)
      (flush-output-port pv-events-port))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (pv-quote-string s)
  (let ([out (open-output-string)])
    (put-char out #\")
    (string-for-each
      (lambda (c)
        (case c
          [(#\\) (put-string out "\\\\")]
          [(#\") (put-string out "\\\"")]
          [(#\newline) (put-string out "\\n")]
          [else (put-char out c)]))
      s)
    (put-char out #\")
    (get-output-string out)))

(define (pv-emit-startup)
  (pv-emit-line "[lifecycle] startup"))
(define (pv-emit-launch-line)
  (pv-emit-line "PDFKit Viewer running. Close window or Ctrl+C to exit."))
(define (pv-emit-shutdown reason)
  (pv-emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The two [document] events — each emitted AFTER the state change it names is
;; applied (label text + nav-button enabled states already set; contract
;; "Document events").

;; `file` is the opened URL's LAST PATH COMPONENT (the panel canonicalizes
;; paths, so the basename is the stable identity); `pages` = pageCount.
;; Success path only — silent no-ops (cancel / nil URL / failed initWithURL:)
;; emit nothing.
(define (pv-emit-document-opened file pages)
  (pv-emit-line (format "[document] opened file=~a pages=~a" (pv-quote-string file) pages)))

;; `page` is 1-based and always equals the label's n (nil-current-page
;; fallback ⇒ page=1); `pages` = N. Bare integers.
(define (pv-emit-page-changed page pages)
  (pv-emit-line (format "[document] page-changed page=~a pages=~a" page pages)))

(define (pv-close-events!)
  (when pv-events-port
    (guard (e [#t (void)])
      (flush-output-port pv-events-port)
      (close-output-port pv-events-port)))
  (set! pv-events-port #f))

;; NSModalResponseOK is not in the AppKit enums.sls — define locally,
;; matching the racket source's identical workaround.
(define NSModalResponseOK 1)

;; Track the loaded document in Scheme state rather than asking the
;; PDFView for it: PDFView returns a null `document` until one is set,
;; and routing through PDFView would re-wrap every refresh. Single
;; assignment from the openDocument: handler keeps this trivially
;; consistent.
(define current-document #f)

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  (define app (nsapplication-shared-application))

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. Cocoa holds the
  ;; delegate weakly, so keep `app-delegate` reachable — this define lives for
  ;; the whole of `main`, which spans the run loop. The callback body is
  ;; guarded because an unhandled exception in an ObjC callback crashes the
  ;; app with no Scheme backtrace.
  (define app-delegate
    (make-delegate
      `(("applicationWillTerminate:"
         ,(lambda (notification)
            (guard (e [#t (void)])
              (pv-emit-shutdown 'menu)
              (pv-close-events!)))
         (void*) void))))

  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 720 540)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))

  ;; --- Toolbar controls ---
  (define open-button  (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
  (define prev-button  (make-nsbutton-init-with-frame (make-nsrect 0 0 40 28)))
  (define next-button  (make-nsbutton-init-with-frame (make-nsrect 0 0 40 28)))
  (define page-label   (make-nstextfield-init-with-frame (make-nsrect 0 0 0 0)))
  (define toolbar-stack
    (make-nsstackview-init-with-frame (make-nsrect 12 500 696 32)))

  ;; --- PDF view ---
  ;; Fills the window below the toolbar. `setAutoScales:` lets PDFKit
  ;; pick a reasonable initial zoom and keep it proportional on window
  ;; resize. `kPDFDisplaySinglePageContinuous` matches Preview.app:
  ;; scrollable, but one page "unit" at a time for the nav buttons.
  (define pdf-view
    (make-pdfview-init-with-frame (make-nsrect 0 0 720 492)))

  ;; --- File-type filter for NSOpenPanel ---
  ;; Single-element NSArray of NSString. `list->nsarray` returns an
  ;; objc-object that the generated setter accepts directly.
  (define pdf-type-array
    (list->nsarray (list (string->nsstring "pdf"))))

  ;; --- UI refresh ---
  ;; Applies the §7.2 refresh rule and returns the state it applied — #f for
  ;; the empty state, (page . total) (1-based) when a document is loaded — so
  ;; the [document] log events (logging contract) report exactly what the
  ;; label shows, including the nil-current-page fallback to page 1.
  (define (refresh-ui!)
    (cond
      [(not current-document)
       (nstextfield-set-string-value! page-label "No PDF loaded")
       (nsbutton-set-enabled! prev-button #f)
       (nsbutton-set-enabled! next-button #f)
       #f]
      [else
       (let* ([total (pdfdocument-page-count current-document)]
              ;; Transient nil-current-page (e.g. mid-document-swap)
              ;; collapses to index 0 — no racket contract layer to
              ;; trip; just check the ptr.
              [current (pdfview-current-page pdf-view)]
              [index (if (zero? (objc-object-ptr current))
                         0
                         (pdfdocument-index-for-page current-document current))])
         (nstextfield-set-string-value! page-label
           (format #f "Page ~a of ~a" (+ index 1) total))
         (nsbutton-set-enabled! prev-button (pdfview-can-go-to-previous-page pdf-view))
         (nsbutton-set-enabled! next-button (pdfview-can-go-to-next-page pdf-view))
         (cons (+ index 1) total))]))

  ;; --- Delegate: one record, four selectors ---
  ;;
  ;; Held in a top-level binding (well, define inside main — captured
  ;; by the let cascade) so its lifetime spans the run loop. NSButton's
  ;; target property and NSNotificationCenter's observer reference are
  ;; both weak; `runtime/dispatch.sls` documents the invariant.
  (define ui-target
    (make-delegate
      `(("openDocument:"
         ,(lambda (_sender)
            (let ([panel (nsopenpanel-open-panel)])
              (nsopenpanel-set-can-choose-files! panel #t)
              (nsopenpanel-set-can-choose-directories! panel #f)
              (nsopenpanel-set-allows-multiple-selection! panel #f)
              (nsopenpanel-set-allowed-file-types! panel pdf-type-array)
              ;; Cancel / nil URL / failed initWithURL: are spec-mandated
              ;; silent no-ops — no event, no error line (logging contract).
              (let ([response (nsopenpanel-run-modal panel)])
                (when (= response NSModalResponseOK)
                  (let ([url (nsopenpanel-url panel)])
                    (unless (zero? (objc-object-ptr url))
                      (let ([doc (make-pdfdocument-init-with-url url)])
                        (unless (zero? (objc-object-ptr doc))
                          (set! current-document doc)
                          (pdfview-set-document! pdf-view doc)
                          ;; [document] opened — success path only, POST-state
                          ;; (store + setDocument: + refresh already applied).
                          ;; `file` is the URL's last path component (the panel
                          ;; canonicalizes paths, so the basename is the stable
                          ;; identity); `pages` = pageCount. The FFI's `string`
                          ;; return maps a NULL UTF8String to #f, hence the
                          ;; (or … "") guard.
                          (let ([state (refresh-ui!)]
                                [basename
                                 (let ([name (nsurl-last-path-component url)])
                                   (if (zero? (objc-object-ptr name))
                                       ""
                                       (or (nsstring-utf8-string name) "")))])
                            (when state
                              (pv-emit-document-opened basename (cdr state))))))))))))
         (void*) void)
        ;; goToPreviousPage: / goToNextPage: take a `sender` id that
        ;; PDFKit ignores; passing #f → nil is fine. The page-changed
        ;; notification then refreshes the UI — no explicit call here.
        ("goPrev:"
         ,(lambda (_sender)
            (pdfview-go-to-previous-page pdf-view #f))
         (void*) void)
        ("goNext:"
         ,(lambda (_sender)
            (pdfview-go-to-next-page pdf-view #f))
         (void*) void)
        ;; Fires on every page change — toolbar buttons, keyboard
        ;; arrows, trackpad scrolls. Single observer keeps the label
        ;; correct regardless of how the page was turned.
        ("pageChanged:"
         ,(lambda (_note)
            ;; [document] page-changed rides the observer, POST-refresh
            ;; (label + button states already applied — logging contract
            ;; "Document events").
            (let ([state (refresh-ui!)])
              (when state
                (pv-emit-page-changed (car state) (cdr state)))))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app (delegate-ptr app-delegate))
  (install-standard-app-menu! app "PDFKit Viewer")

  ;; Window
  (nswindow-set-title! window "PDFKit Viewer")
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 480 360))

  ;; Toolbar controls
  (nsbutton-set-title! open-button "Open\x2026;")
  (nsbutton-set-bezel-style! open-button NSBezelStyleRounded)

  (nsbutton-set-title! prev-button "\x25C0;")
  (nsbutton-set-bezel-style! prev-button NSBezelStyleRounded)

  (nsbutton-set-title! next-button "\x25B6;")
  (nsbutton-set-bezel-style! next-button NSBezelStyleRounded)

  (nstextfield-set-string-value! page-label "No PDF loaded")
  (nstextfield-set-font! page-label (nsfont-system-font-of-size 13.0))
  (nstextfield-set-alignment! page-label NSTextAlignmentLeft)
  (nstextfield-set-editable! page-label #f)
  (nstextfield-set-selectable! page-label #f)
  (nstextfield-set-bezeled! page-label #f)
  (nstextfield-set-draws-background! page-label #f)

  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.0)
  (nsstackview-add-arranged-subview! toolbar-stack open-button)
  (nsstackview-add-arranged-subview! toolbar-stack prev-button)
  (nsstackview-add-arranged-subview! toolbar-stack next-button)
  (nsstackview-add-arranged-subview! toolbar-stack page-label)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; PDF view
  (nsview-set-autoresizing-mask! pdf-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (pdfview-set-auto-scales! pdf-view #t)
  (pdfview-set-display-mode! pdf-view kPDFDisplaySinglePageContinuous)
  (nsview-add-subview! content-view pdf-view)

  ;; Initial UI state
  (refresh-ui!)

  ;; Notification observer. PDFViewPageChangedNotification is exported
  ;; as a raw uptr (foreign-ref); wrap via `borrow-objc-object` so the
  ;; observer setter's coerce-arg sees an objc-object.
  (nsnotificationcenter-add-observer-selector-name-object!
    (nsnotificationcenter-default-center)
    (delegate-ptr ui-target)
    "pageChanged:"
    (borrow-objc-object PDFViewPageChangedNotification)
    pdf-view)

  ;; Target-action wiring
  (nsbutton-set-target! open-button (delegate-ptr ui-target))
  (nsbutton-set-action! open-button "openDocument:")
  (nsbutton-set-target! prev-button (delegate-ptr ui-target))
  (nsbutton-set-action! prev-button "goPrev:")
  (nsbutton-set-target! next-button (delegate-ptr ui-target))
  (nsbutton-set-action! next-button "goNext:")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  ;; Launch diagnostic (spec §3 step 7): the bare line beginning `PDFKit
  ;; Viewer` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (pv-emit-launch-line)
  (display "PDFKit Viewer running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The viewer builds its window/PDF view in `main`'s defines section (R6RS
;; body: all defines precede every expression), so `startup` cannot be main's
;; first expression as in hello-window — it lands here instead, before (main)
;; is entered and thus before window/PDF-view construction, well before the
;; run loop (or the runner's `wait-ready` readiness probe times out).
(pv-events-init!)
(pv-emit-startup)

;; Test-config compatibility (logging-contract.md): the viewer reads no
;; runtime config, so it honours PDFKIT_VIEWER_TEST_CONFIG by reading the env
;; var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "PDFKIT_VIEWER_TEST_CONFIG")

(main)
