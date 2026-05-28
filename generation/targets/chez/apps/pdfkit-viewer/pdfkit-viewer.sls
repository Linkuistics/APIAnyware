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
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/pdfkit-viewer/pdfkit-viewer.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-macos-bundle-chez
;;              -- pdfkit-viewer`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware pdfkit)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

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
  (define (refresh-ui!)
    (cond
      [(not current-document)
       (nstextfield-set-string-value! page-label "No PDF loaded")
       (nsbutton-set-enabled! prev-button #f)
       (nsbutton-set-enabled! next-button #f)]
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
         (nsbutton-set-enabled! next-button (pdfview-can-go-to-next-page pdf-view)))]))

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
              (let ([response (nsopenpanel-run-modal panel)])
                (when (= response NSModalResponseOK)
                  (let ([url (nsopenpanel-url panel)])
                    (unless (zero? (objc-object-ptr url))
                      (let ([doc (make-pdfdocument-init-with-url url)])
                        (unless (zero? (objc-object-ptr doc))
                          (set! current-document doc)
                          (pdfview-set-document! pdf-view doc)
                          (refresh-ui!)))))))))
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
            (refresh-ui!))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
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

  (display "PDFKit Viewer running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

(main)
