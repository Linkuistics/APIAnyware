#lang racket/base
;; pdfkit-viewer.rkt — PDFKit Viewer sample app (OO style)
;;
;; Minimal PDF viewer: Open a .pdf via NSOpenPanel, render it in a
;; PDFView, navigate pages via toolbar buttons, and keep a "Page n of N"
;; label in sync via PDFViewPageChangedNotification.
;;
;; Exercises: PDFKit generated bindings end-to-end (PDFView, PDFDocument,
;; PDFPage), NSNotificationCenter observer registration, NSOpenPanel file
;; filter via list->nsarray, and a notification-driven UI refresh loop.
;;
;; Run with: racket pdfkit-viewer.rkt

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/appkit/nsopenpanel.rkt"
         "../../generated/foundation/nsurl.rkt"
         "../../generated/foundation/nsnotificationcenter.rkt"
         "../../generated/pdfkit/pdfview.rkt"
         "../../generated/pdfkit/pdfdocument.rkt"
         (only-in "../../generated/pdfkit/constants.rkt"
                  PDFViewPageChangedNotification)
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/delegate.rkt"
         "../../runtime/app-menu.rkt")

;; --- Constants (not yet extracted by collector) ---
;; NSWindowStyleMask
(define NSWindowStyleMaskTitled         1)
(define NSWindowStyleMaskClosable       2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSWindowStyleMaskResizable      8)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSTextAlignment
(define NSTextAlignmentLeft 0)
;; NSViewAutoresizingMask
(define NSViewWidthSizable  2)
(define NSViewHeightSizable 16)
(define NSViewMinYMargin    8)
;; NSBezelStyle
(define NSBezelStyleRounded 1)
;; NSModalResponse
(define NSModalResponseOK 1)
;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationHorizontal 0)
;; NSLayoutAttribute
(define NSLayoutAttributeFirstBaseline 12)
;; PDFDisplayMode
(define kPDFDisplaySinglePageContinuous 1)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; Regular
(install-standard-app-menu! app "PDFKit Viewer")

;; --- Window ---
(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 720 540)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "PDFKit Viewer")
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 480 360))

(define content-view (nswindow-content-view window))

;; --- Toolbar controls ---
(define open-button (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
(nsbutton-set-title! open-button "Open…")
(nsbutton-set-bezel-style! open-button NSBezelStyleRounded)

(define prev-button (make-nsbutton-init-with-frame (make-nsrect 0 0 40 28)))
(nsbutton-set-title! prev-button "◀")
(nsbutton-set-bezel-style! prev-button NSBezelStyleRounded)

(define next-button (make-nsbutton-init-with-frame (make-nsrect 0 0 40 28)))
(nsbutton-set-title! next-button "▶")
(nsbutton-set-bezel-style! next-button NSBezelStyleRounded)

(define page-label (make-nstextfield-init-with-frame (make-nsrect 0 0 0 0)))
(nstextfield-set-string-value! page-label "No PDF loaded")
(nstextfield-set-font! page-label (nsfont-system-font-of-size 13.0))
(nstextfield-set-alignment! page-label NSTextAlignmentLeft)
(nstextfield-set-editable! page-label #f)
(nstextfield-set-selectable! page-label #f)
(nstextfield-set-bezeled! page-label #f)
(nstextfield-set-draws-background! page-label #f)

(define toolbar-stack
  (make-nsstackview-init-with-frame (make-nsrect 12 500 696 32)))
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

;; --- PDF view ---
;; Fills the window below the toolbar. `setAutoScales:` lets PDFKit pick
;; a reasonable initial zoom and keep it proportional on window resize.
;; `setDisplayMode: kPDFDisplaySinglePageContinuous` matches the default
;; feel of Preview.app: scrollable, but one page "unit" at a time for
;; the nav buttons.
(define pdf-view
  (make-pdfview-init-with-frame (make-nsrect 0 0 720 492)))
(nsview-set-autoresizing-mask! pdf-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
(pdfview-set-auto-scales! pdf-view #t)
(pdfview-set-display-mode! pdf-view kPDFDisplaySinglePageContinuous)
(nsview-add-subview! content-view pdf-view)

;; --- UI refresh ---
;;
;; We track the loaded document in Racket state (current-document)
;; rather than asking the PDFView for it. Reason: `pdfview-document`'s
;; generated return contract requires `pdfdocument?` and doesn't accept
;; nil — a fresh PDFView with no document would fail the contract at
;; the class-wrapper boundary. Same for `pdfview-current-page` on an
;; empty view. Tracking locally avoids the round-trip and the nullable
;; contract gap.
(define current-document #f)

(define (refresh-ui!)
  (cond
    [(not current-document)
     (nstextfield-set-string-value! page-label "No PDF loaded")
     (nsbutton-set-enabled! prev-button #f)
     (nsbutton-set-enabled! next-button #f)]
    [else
     (define total (pdfdocument-page-count current-document))
     ;; `pdfview-current-page` has a generated return contract of
     ;; `pdfpage?` — it rejects nil. Wrap in with-handlers so a
     ;; transient nil-current-page (during document swap, say) falls
     ;; back to page 1 instead of blowing up the handler.
     (define index
       (with-handlers ([exn:fail:contract? (lambda (_) 0)])
         (define current (pdfview-current-page pdf-view))
         (if (or (not current) (objc-null? current))
             0
             (pdfdocument-index-for-page current-document current))))
     (nstextfield-set-string-value! page-label
       (format "Page ~a of ~a" (+ index 1) total))
     (nsbutton-set-enabled! prev-button (pdfview-can-go-to-previous-page pdf-view))
     (nsbutton-set-enabled! next-button (pdfview-can-go-to-next-page pdf-view))]))

(refresh-ui!)

;; --- Notification observer ---
;; PDFViewPageChangedNotification fires on every page change — button
;; clicks, keyboard arrows, trackpad scrolls, whatever. Observing it
;; keeps the label correct regardless of how the page was turned.
;;
;; PDFViewPageChangedNotification is emitted as a raw _id-typed cpointer
;; via get-ffi-obj; the observer registration wrapper's `name` contract
;; expects objc-object? or string or #f, so wrap via borrow-objc-object.
(define page-observer
  (make-delegate
   #:return-types (hash "pageChanged:" 'void)
   #:param-types  (hash "pageChanged:" '(object))
   "pageChanged:"
   (lambda (_note)
     (refresh-ui!))))

(nsnotificationcenter-add-observer-selector-name-object!
  (nsnotificationcenter-default-center)
  page-observer
  "pageChanged:"
  (borrow-objc-object PDFViewPageChangedNotification)
  pdf-view)

;; --- Open action ---
;; NSOpenPanel filtered to .pdf via setAllowedFileTypes:. The filter
;; array is a single-element NSArray of NSString. list->nsarray returns
;; an objc-object wrapper that class-wrapper param contracts accept
;; directly.
(define pdf-type-array
  (list->nsarray (list (string->nsstring "pdf"))))

(define open-target
  (make-delegate
   #:return-types (hash "openDocument:" 'void)
   "openDocument:"
   (lambda (_sender)
     (define panel (nsopenpanel-open-panel))
     (nsopenpanel-set-can-choose-files! panel #t)
     (nsopenpanel-set-can-choose-directories! panel #f)
     (nsopenpanel-set-allows-multiple-selection! panel #f)
     (nsopenpanel-set-allowed-file-types! panel pdf-type-array)
     (define response (nsopenpanel-run-modal panel))
     (when (= response NSModalResponseOK)
       (define url (nsopenpanel-url panel))
       (when (and url (not (objc-null? url)))
         (define doc (make-pdfdocument-init-with-url url))
         (when (and doc (not (objc-null? doc)))
           (set! current-document doc)
           (pdfview-set-document! pdf-view doc)
           (refresh-ui!)))))))

(nsbutton-set-target! open-button open-target)
(nsbutton-set-action! open-button "openDocument:")

;; --- Navigation actions ---
;; goToPreviousPage: / goToNextPage: expect a `sender` id argument;
;; we pass `#f` (nil) since the sender is unused by PDFKit. The
;; `PDFViewPageChangedNotification` observer handles the UI refresh
;; automatically — no explicit refresh-ui! call needed here.
(define prev-target
  (make-delegate
   #:return-types (hash "goPrev:" 'void)
   "goPrev:"
   (lambda (_sender)
     (pdfview-go-to-previous-page pdf-view #f))))

(define next-target
  (make-delegate
   #:return-types (hash "goNext:" 'void)
   "goNext:"
   (lambda (_sender)
     (pdfview-go-to-next-page pdf-view #f))))

(nsbutton-set-target! prev-button prev-target)
(nsbutton-set-action! prev-button "goPrev:")
(nsbutton-set-target! next-button next-target)
(nsbutton-set-action! next-button "goNext:")

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

(displayln "PDFKit Viewer running. Close window or Ctrl+C to exit.")
(nsapplication-run app)
