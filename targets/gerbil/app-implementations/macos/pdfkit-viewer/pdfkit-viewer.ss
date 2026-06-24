;;; pdfkit-viewer.ss — PDFKit Viewer sample app (gerbil target).
;;;
;;; Minimal PDF viewer: Open a .pdf via NSOpenPanel, render it in a PDFView,
;;; navigate pages via toolbar buttons, and keep a "Page n of N" label in sync
;;; via PDFViewPageChangedNotification. Mirrors
;;; generation/targets/chez/apps/pdfkit-viewer/pdfkit-viewer.sls
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
;;; Build via bundle-gerbil; uses the bottle toolchain.
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
        :gerbil-bindings/pdfkit/pdfview
        :gerbil-bindings/pdfkit/pdfdocument
        :gerbil-bindings/pdfkit/enums
        :gerbil-bindings/pdfkit/constants)
(export main)

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
  (def (refresh-ui!)
    (if (not current-document)
      (begin
        (nscontrol-set-string-value! page-label (string->nsstring "No PDF loaded"))
        (nscontrol-set-enabled! prev-button #f)
        (nscontrol-set-enabled! next-button #f))
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
        (nscontrol-set-enabled! next-button (pdfview-can-go-to-next-page pdf-view)))))

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
                  (when (= (nssavepanel-run-modal panel) NSModalResponseOK)
                    (let (url (nssavepanel-url panel))
                      (when url
                        (let (doc (make-pdfdocument-init-with-url url))
                          (when doc
                            (set! current-document doc)
                            (pdfview-set-document! pdf-view doc)
                            (refresh-ui!))))))))
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
              (lambda (note) (refresh-ui!))
              (list 'object) 'void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================
  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
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

  (displayln "PDFKit Viewer running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
