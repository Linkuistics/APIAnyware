;;; pdfkit-viewer.ss — PDFKit Viewer sample app (gerbil target).
;;;
;;; Minimal PDF viewer: Open a .pdf via NSOpenPanel, render it in a PDFView,
;;; navigate pages via toolbar buttons, and keep a "Page n of N" label in sync
;;; via PDFViewPageChangedNotification. Mirrors
;;; targets/chez/app-implementations/macos/pdfkit-viewer/pdfkit-viewer.sls
;;; (and racket's pdfkit-viewer.rkt) one piece at a time.
;;;
;;; The feature this app adds over the earlier gerbil samples: one `make-delegate`
;;; record carries FOUR selectors and doubles as both the target-action target
;;; (openDocument:/goPrev:/goNext:) AND the NSNotificationCenter observer
;;; (pageChanged:). First gerbil app to use NSOpenPanel (modal), PDFKit, and an
;;; NSNotificationCenter observer.
;;;
;;; Gerbil idiom notes vs the chez source:
;;;   - Inherited NSSavePanel methods (runModal/URL/setAllowedFileTypes:) are
;;;     called on the NSOpenPanel via the DECLARING class's proc core
;;;     (`nssavepanel-run-modal` etc.), the same inherited-dispatch idiom as
;;;     ui-controls' `nscontrol-double-value`.
;;;   - `make-delegate` returns a bound instance passed straight to
;;;     `nscontrol-set-target!` / `add-observer-…` (no chez `delegate-ptr`).
;;;   - PDFViewPageChangedNotification is already a `wrap`ped object (constants.ss),
;;;     so it flows directly into the observer setter (no chez `borrow-objc-object`).
;;;   - `wrap` returns #f for a nil object, so the nil checks are plain truthiness
;;;     (`(when doc …)`), not chez's `(zero? (objc-object-ptr …))`.
;;;   - Strings cross as `(string->nsstring …)` (UTF-8, so "Open…"/"◀"/"▶" are fine).
;;;
;;; Instrumented for the AppSpec scenario runner per the PDFKit Viewer logging
;;; contract (apps/macos/pdfkit-viewer/docs/logging-contract.md): it writes a
;;; structured events.log the runner tails — [lifecycle] startup/shutdown, the
;;; bare launch line, and the two [document] state-transition events
;;; (opened / page-changed) that make the spec §13 document assertions
;;; observable (the nav-button enabled flags are dropped by the AX-snapshot
;;; transform, and the label's OCR can catch a pre-repaint frame). Under
;;; `launch-via 'open` LaunchServices discards the app's stdout, so the log
;;; file (not stdout) is the runner's read path; the stdout line is kept too
;;; (human-friendly when run unbundled).
;;;
;;; The logging is inlined here rather than split to a sibling events.ss for
;;; the same reason as hello-window / ui-controls-gallery: the bundler's
;;; closure walk (deps.rs) follows only `:gerbil-bindings/…` references, and
;;; these defines use only Gambit primitives (open-output-file, getenv,
;;; create-directory, force-output), so they ride the statically-linked
;;; prelude with no new import.
;;;
;;; Build via build.sh (bottle toolchain); bundle via bundle-gerbil.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nsbutton
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsstackview
        :gerbil-bindings/appkit/nsopenpanel
        :gerbil-bindings/appkit/nssavepanel
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/foundation/nsnotificationcenter
        :gerbil-bindings/foundation/nsmutablearray
        :gerbil-bindings/foundation/nsstring
        :gerbil-bindings/foundation/nsurl
        :gerbil-bindings/pdfkit/pdfview
        :gerbil-bindings/pdfkit/pdfdocument
        :gerbil-bindings/pdfkit/enums
        :gerbil-bindings/pdfkit/constants)
(export main)

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: the Cocoa run loop serialises the main-thread callbacks that
;; emit — startup/launch before -run, the [document] events from the
;; open-button action callback and the page-changed notification observer,
;; shutdown on terminate — so one port with a post-write force-output suffices
;; (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (PDFKIT_VIEWER_EVENTS_LOG)
;; propagates through LaunchServices.
(define pv-default-events-path "/tmp/pdfkit-viewer/events.log")
(define pv-events-port #f)

;; PDFKIT_VIEWER_EVENTS_LOG if set and non-empty, else the fixed default.
(define (pv-resolve-events-path)
  (let ((env (getenv "PDFKIT_VIEWER_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env pv-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (pv-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in pv-emit-line, so
;; a tail sees each promptly.
(define (pv-events-init!)
  (let* ((target (pv-resolve-events-path))
         (parent (pv-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! pv-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (pv-emit-line line)
  (when pv-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line pv-events-port)
        (newline pv-events-port)
        (force-output pv-events-port)))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (pv-quote-string s)
  (let ((out (open-output-string)))
    (write-char #\" out)
    (let loop ((i 0))
      (when (< i (string-length s))
        (let ((c (string-ref s i)))
          (cond
            ((char=? c #\\) (display "\\\\" out))
            ((char=? c #\") (display "\\\"" out))
            ((char=? c #\newline) (display "\\n" out))
            (else (write-char c out))))
        (loop (+ i 1))))
    (write-char #\" out)
    (get-output-string out)))

(define (pv-emit-startup)
  (pv-emit-line "[lifecycle] startup"))
(define (pv-emit-launch-line)
  (pv-emit-line "PDFKit Viewer running. Close window or Ctrl+C to exit."))
(define (pv-emit-shutdown reason)
  (pv-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; The two [document] events — each emitted AFTER the state change it names is
;; applied (label text + nav-button enabled states already set; contract
;; "Document events").

;; `file` is the opened URL's LAST PATH COMPONENT (the panel canonicalizes
;; paths, so the basename is the stable identity); `pages` = pageCount.
;; Success path only — silent no-ops (cancel / nil URL / failed initWithURL:)
;; emit nothing.
(define (pv-emit-document-opened file pages)
  (pv-emit-line (string-append "[document] opened file=" (pv-quote-string file)
                               " pages=" (number->string pages))))

;; `page` is 1-based and always equals the label's n (nil-current-page
;; fallback ⇒ page=1); `pages` = N. Bare integers.
(define (pv-emit-page-changed page pages)
  (pv-emit-line (string-append "[document] page-changed page=" (number->string page)
                               " pages=" (number->string pages))))

(define (pv-close-events!)
  (when pv-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output pv-events-port)
        (close-output-port pv-events-port))))
  (set! pv-events-port #f))
;; --- End structured event log ----------------------------------------------

;; NSModalResponseOK is not in the AppKit enums — define locally, matching the
;; racket/chez source's identical workaround.
(def NSModalResponseOK 1)

;; Track the loaded document in Scheme state rather than asking the PDFView for
;; it: PDFView returns nil `document` until one is set. Single assignment from
;; the openDocument: handler keeps this trivially consistent.
(def current-document #f)

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================
  (def app (nsapplication-shared-application))

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. make-delegate pins
  ;; the synthesized instance in *delegate-roots* for the process (AppKit
  ;; holds the delegate weakly); this def keeps it lexically reachable too.
  ;; The body is guarded because an unhandled exception in an ObjC callback
  ;; would crash the app with no Scheme backtrace.
  (def app-delegate
    (make-delegate
      (list (list "applicationWillTerminate:"
                  (lambda (notification)
                    (with-exception-catcher (lambda (e) #f)
                      (lambda ()
                        (pv-emit-shutdown 'menu)
                        (pv-close-events!))))
                  (list 'object) 'void))))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. 720. 540.)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (def content-view (nswindow-content-view window))

  ;; --- Toolbar controls ---
  (def open-button  (make-nsbutton))
  (def prev-button  (make-nsbutton))
  (def next-button  (make-nsbutton))
  (def page-label   (make-nstextfield))
  (def toolbar-stack (make-nsstackview))

  ;; --- PDF view: fills the window below the toolbar. ---
  (def pdf-view (make-pdfview))

  ;; --- File-type filter for NSOpenPanel: a single-element NSArray of "pdf". ---
  (def pdf-type-array
    (let (arr (make-nsmutablearray-init-with-capacity 1))
      (nsmutablearray-add-object! arr (string->nsstring "pdf"))
      arr))

  ;; --- UI refresh ---
  ;; Applies the §7.2 refresh rule and returns the state it applied — #f for
  ;; the empty state, (page . total) (1-based) when a document is loaded — so
  ;; the [document] log events (logging contract) report exactly what the
  ;; label shows, including the nil-current-page fallback to page 1.
  (def (refresh-ui!)
    (if (not current-document)
      (begin
        (nscontrol-set-string-value! page-label (string->nsstring "No PDF loaded"))
        (nscontrol-set-enabled! prev-button #f)
        (nscontrol-set-enabled! next-button #f)
        #f)
      (let* ((total   (pdfdocument-page-count current-document))
             ;; nil current-page (transient, mid-swap) collapses to index 0.
             (current (pdfview-current-page pdf-view))
             (index   (if current
                        (pdfdocument-index-for-page current-document current)
                        0)))
        (nscontrol-set-string-value! page-label
          (string->nsstring
            (string-append "Page " (number->string (+ index 1))
                           " of " (number->string total))))
        (nscontrol-set-enabled! prev-button (pdfview-can-go-to-previous-page pdf-view))
        (nscontrol-set-enabled! next-button (pdfview-can-go-to-next-page pdf-view))
        (cons (+ index 1) total))))

  ;; --- Delegate: one record, four selectors (target-action + observer) ---
  (def ui-target
    (make-delegate
      (list
        (list "openDocument:"
              (lambda (sender)
                (let (panel (nsopenpanel-open-panel))
                  (nsopenpanel-set-can-choose-files! panel #t)
                  (nsopenpanel-set-can-choose-directories! panel #f)
                  (nsopenpanel-set-allows-multiple-selection! panel #f)
                  ;; Inherited from NSSavePanel — dispatch via its proc core.
                  (nssavepanel-set-allowed-file-types! panel pdf-type-array)
                  ;; Cancel / nil URL / failed initWithURL: are spec-mandated
                  ;; silent no-ops — no event, no error line (logging contract).
                  (when (= (nssavepanel-run-modal panel) NSModalResponseOK)
                    (let (url (nssavepanel-url panel))
                      (when url
                        (let (doc (make-pdfdocument-init-with-url url))
                          (when doc
                            (set! current-document doc)
                            (pdfview-set-document! pdf-view doc)
                            ;; [document] opened — success path only, POST-state
                            ;; (store + setDocument: + refresh already applied).
                            ;; `file` is the URL's last path component (the panel
                            ;; canonicalizes paths, so the basename is the stable
                            ;; identity); `pages` = pageCount. `wrap`→#f covers a
                            ;; nil NSString; Gambit's char-string return maps a
                            ;; NULL UTF8String to #f, hence the (or … "") guard.
                            (let ((state (refresh-ui!))
                                  (basename
                                   (let (name (nsurl-last-path-component url))
                                     (if name
                                       (or (nsstring-utf8-string name) "")
                                       ""))))
                              (when state
                                (pv-emit-document-opened basename (cdr state)))))))))))
              (list 'object) 'void)
        ;; goToPreviousPage:/goToNextPage: take a sender id PDFKit ignores
        ;; (#f → nil). The page-changed notification refreshes the UI.
        (list "goPrev:"
              (lambda (sender) (pdfview-go-to-previous-page pdf-view #f))
              (list 'object) 'void)
        (list "goNext:"
              (lambda (sender) (pdfview-go-to-next-page pdf-view #f))
              (list 'object) 'void)
        ;; Fires on every page change — buttons, arrows, scrolls. One observer
        ;; keeps the label correct however the page was turned.
        (list "pageChanged:"
              (lambda (note)
                ;; [document] page-changed rides the observer, POST-refresh
                ;; (label + button states already applied — logging contract
                ;; "Document events").
                (let (state (refresh-ui!))
                  (when state
                    (pv-emit-page-changed (car state) (cdr state)))))
              (list 'object) 'void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================
  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app app-delegate)
  (install-standard-app-menu! app "PDFKit Viewer")

  ;; Window
  (nswindow-set-title! window (string->nsstring "PDFKit Viewer"))
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 480. 360.))

  ;; Toolbar controls
  (nsbutton-set-title! open-button (string->nsstring "Open…"))
  (nsbutton-set-bezel-style! open-button NSBezelStyleRounded)
  (nsbutton-set-title! prev-button (string->nsstring "◀"))
  (nsbutton-set-bezel-style! prev-button NSBezelStyleRounded)
  (nsbutton-set-title! next-button (string->nsstring "▶"))
  (nsbutton-set-bezel-style! next-button NSBezelStyleRounded)

  (nscontrol-set-string-value! page-label (string->nsstring "No PDF loaded"))
  (nscontrol-set-font! page-label (nsfont-system-font-of-size 13.))
  (nscontrol-set-alignment! page-label NSTextAlignmentLeft)
  (nstextfield-set-editable! page-label #f)
  (nstextfield-set-selectable! page-label #f)
  (nstextfield-set-bezeled! page-label #f)
  (nstextfield-set-draws-background! page-label #f)

  ;; Toolbar stack: horizontal, pinned to the top edge, grows with width.
  (nsview-set-frame! toolbar-stack (make-rect 12. 500. 696. 32.))
  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.)
  (nsstackview-add-arranged-subview! toolbar-stack open-button)
  (nsstackview-add-arranged-subview! toolbar-stack prev-button)
  (nsstackview-add-arranged-subview! toolbar-stack next-button)
  (nsstackview-add-arranged-subview! toolbar-stack page-label)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; PDF view — fills below the toolbar, grows with the window.
  (nsview-set-frame! pdf-view (make-rect 0. 0. 720. 492.))
  (nsview-set-autoresizing-mask! pdf-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (pdfview-set-auto-scales! pdf-view #t)
  (pdfview-set-display-mode! pdf-view kPDFDisplaySinglePageContinuous)
  (nsview-add-subview! content-view pdf-view)

  ;; Initial UI state
  (refresh-ui!)

  ;; Notification observer — the delegate's pageChanged: on every page turn.
  (nsnotificationcenter-add-observer-selector-name-object!
    (nsnotificationcenter-default-center)
    ui-target
    "pageChanged:"
    PDFViewPageChangedNotification
    pdf-view)

  ;; Target-action wiring
  (nscontrol-set-target! open-button ui-target)
  (nscontrol-set-action! open-button "openDocument:")
  (nscontrol-set-target! prev-button ui-target)
  (nscontrol-set-action! prev-button "goPrev:")
  (nscontrol-set-target! next-button ui-target)
  (nscontrol-set-action! next-button "goNext:")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  ;; Launch diagnostic (spec §3 step 7): the bare line beginning `PDFKit
  ;; Viewer` the runner's `wait-for-log` matches, dual-emitted to events.log
  ;; (the runner's read path) and stdout (human-friendly when run unbundled;
  ;; LaunchServices discards stdout under `open`).
  (pv-emit-launch-line)
  (displayln "PDFKit Viewer running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The viewer builds its window/PDF view in main's *defines* section (the def
;; initializers evaluate before main's first expression), so `startup` cannot
;; be main's first expression as in hello-window — it lands here instead,
;; before (main) is entered and thus before window/PDF-view construction, well
;; before the run loop (or the runner's `wait-ready` readiness probe times out).
(pv-events-init!)
(pv-emit-startup)

;; Test-config compatibility (logging-contract.md): the viewer reads no
;; runtime config, so it honours PDFKIT_VIEWER_TEST_CONFIG by reading the env
;; var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "PDFKIT_VIEWER_TEST_CONFIG" #f)

(main)
