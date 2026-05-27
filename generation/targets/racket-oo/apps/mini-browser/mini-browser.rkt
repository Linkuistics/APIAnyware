#lang racket/base
;; mini-browser.rkt — Mini Browser sample app (OO style)
;;
;; Minimal web browser: an address bar, back/forward/reload controls, a
;; WKWebView that fills the window, and a status line that reflects
;; WKNavigationDelegate callbacks. Typing a URL and pressing Enter (or
;; clicking Go) navigates; a missing scheme gets "https://" prepended.
;;
;; Exercises:
;;   - WKWebView end-to-end with WKNavigationDelegate observer registration
;;   - Async multi-callback delegate: didStart → didFinish / didFailNavigation
;;   - Cross-framework requires: AppKit + Foundation + WebKit
;;   - NSAlert for error surfacing on failed loads
;;
;; Run with: racket mini-browser.rkt

(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/appkit/nsalert.rkt"
         "../../generated/foundation/nsurl.rkt"
         "../../generated/foundation/nsurlrequest.rkt"
         "../../generated/foundation/nserror.rkt"
         "../../generated/webkit/wkwebview.rkt"
         "../../generated/webkit/protocols/wknavigationdelegate.rkt"
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
(define NSViewMaxYMargin   32)
;; NSBezelStyle
(define NSBezelStyleRounded 1)
;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationHorizontal 0)
;; NSLayoutAttribute
(define NSLayoutAttributeFirstBaseline 12)
;; NSAlertStyle
(define NSAlertStyleWarning 1)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; Regular
(install-standard-app-menu! app "Mini Browser")

;; --- Window ---
(define WINDOW-W 800)
(define WINDOW-H 600)
(define TOOLBAR-H 32)
(define STATUS-H 22)
(define MARGIN 12)

(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 WINDOW-W WINDOW-H)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "Mini Browser")
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 500 400))

(define content-view (nswindow-content-view window))

;; --- Toolbar controls ---
(define back-button (make-nsbutton-init-with-frame (make-nsrect 0 0 36 28)))
(nsbutton-set-title! back-button "◀")
(nsbutton-set-bezel-style! back-button NSBezelStyleRounded)
(nsbutton-set-enabled! back-button #f)

(define forward-button (make-nsbutton-init-with-frame (make-nsrect 0 0 36 28)))
(nsbutton-set-title! forward-button "▶")
(nsbutton-set-bezel-style! forward-button NSBezelStyleRounded)
(nsbutton-set-enabled! forward-button #f)

(define reload-button (make-nsbutton-init-with-frame (make-nsrect 0 0 64 28)))
(nsbutton-set-title! reload-button "Reload")
(nsbutton-set-bezel-style! reload-button NSBezelStyleRounded)

(define address-field (make-nstextfield-init-with-frame (make-nsrect 0 0 480 24)))
(nstextfield-set-string-value! address-field "https://www.apple.com")
(nstextfield-set-editable! address-field #t)
(nstextfield-set-bordered! address-field #t)

(define go-button (make-nsbutton-init-with-frame (make-nsrect 0 0 48 28)))
(nsbutton-set-title! go-button "Go")
(nsbutton-set-bezel-style! go-button NSBezelStyleRounded)

(define toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
(define toolbar-stack
  (make-nsstackview-init-with-frame
   (make-nsrect MARGIN toolbar-y (- WINDOW-W (* 2 MARGIN)) TOOLBAR-H)))
(nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
(nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
(nsstackview-set-spacing! toolbar-stack 8.0)
(nsstackview-add-arranged-subview! toolbar-stack back-button)
(nsstackview-add-arranged-subview! toolbar-stack forward-button)
(nsstackview-add-arranged-subview! toolbar-stack reload-button)
(nsstackview-add-arranged-subview! toolbar-stack address-field)
(nsstackview-add-arranged-subview! toolbar-stack go-button)
(nsview-set-autoresizing-mask! toolbar-stack
  (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
(nsview-add-subview! content-view toolbar-stack)

;; --- Status label (bottom) ---
(define status-label
  (make-nstextfield-init-with-frame
   (make-nsrect MARGIN MARGIN (- WINDOW-W (* 2 MARGIN)) STATUS-H)))
(nstextfield-set-string-value! status-label "Ready")
(nstextfield-set-font! status-label (nsfont-system-font-of-size 11.0))
(nstextfield-set-alignment! status-label NSTextAlignmentLeft)
(nstextfield-set-editable! status-label #f)
(nstextfield-set-selectable! status-label #f)
(nstextfield-set-bezeled! status-label #f)
(nstextfield-set-draws-background! status-label #f)
(nsview-set-autoresizing-mask! status-label
  (bitwise-ior NSViewWidthSizable NSViewMaxYMargin))
(nsview-add-subview! content-view status-label)

;; --- WKWebView ---
;; Fills the area between the toolbar and the status line. Height is
;; WINDOW-H minus both chrome rows plus their margins.
(define web-y (+ MARGIN STATUS-H MARGIN))
(define web-h (- toolbar-y web-y MARGIN))
(define web-view
  (make-wkwebview-init-with-frame
   (make-nsrect MARGIN web-y (- WINDOW-W (* 2 MARGIN)) web-h)))
(nsview-set-autoresizing-mask! web-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
(nsview-add-subview! content-view web-view)

;; --- UI refresh ---
;; WKWebView.title / .URL return NSString / NSURL wrappers (or nil). The
;; generated contracts for both return `(or/c <pred> objc-nil?)`, so a
;; nil check (`objc-null?`) is safe. ->string handles the NSString →
;; Racket string conversion uniformly.
(define (nsstring->racket-string s)
  (if (or (not s) (objc-null? s))
      ""
      (->string s)))

(define (refresh-chrome!)
  (nsbutton-set-enabled! back-button    (wkwebview-can-go-back web-view))
  (nsbutton-set-enabled! forward-button (wkwebview-can-go-forward web-view))
  (define t (wkwebview-title web-view))
  (define title-text (nsstring->racket-string t))
  (nswindow-set-title! window
    (if (string=? title-text "")
        "Mini Browser"
        (format "~a — Mini Browser" title-text)))
  (define u (wkwebview-url web-view))
  (when (and u (not (objc-null? u)))
    (define url-text (nsstring->racket-string (nsurl-absolute-string u)))
    (unless (string=? url-text "")
      (nstextfield-set-string-value! address-field url-text))))

(define (set-status! text)
  (nstextfield-set-string-value! status-label text))

;; --- Navigation delegate ---
;; WKNavigationDelegate fires three classes of event during a load:
;;   1. didStartProvisionalNavigation: — the request left the app
;;   2. didFinishNavigation: — page fully loaded, chrome should refresh
;;   3. didFailNavigation: / didFailProvisionalNavigation: — error path
;;
;; `_webview` / `_nav` are unused here (we ask the one web-view we own
;; directly), but `#:param-types` still declares them as objects so the
;; trampoline wraps the raw cpointers for us.
(define (handle-start _webview _nav)
  (set-status! "Loading..."))

(define (handle-finish _webview _nav)
  (refresh-chrome!)
  (set-status! "Done"))

(define (show-error! err phase)
  (define message
    (if (or (not err) (objc-null? err))
        "Unknown error"
        (nsstring->racket-string (nserror-localized-description err))))
  ;; NSAlert doesn't emit an `init` method in the bindings — use the
  ;; `+alertWithError:` class method, which covers the NSError case
  ;; exactly. Style/text adjustments can still be applied after.
  (when (and err (not (objc-null? err)))
    (define alert (nsalert-alert-with-error err))
    (when (and alert (not (objc-null? alert)))
      (nsalert-set-alert-style! alert NSAlertStyleWarning)
      (nsalert-run-modal alert)))
  (set-status! (format "~a failed: ~a" phase message)))

(define (handle-fail _webview _nav err)
  (show-error! err "load"))

(define (handle-provisional-fail _webview _nav err)
  (show-error! err "request"))

(define nav-delegate
  (make-wknavigationdelegate
   "webView:didStartProvisionalNavigation:" handle-start
   "webView:didFinishNavigation:"            handle-finish
   "webView:didFailNavigation:withError:"    handle-fail
   "webView:didFailProvisionalNavigation:withError:" handle-provisional-fail))
(wkwebview-set-navigation-delegate! web-view nav-delegate)

;; --- Navigation helpers ---
(define (normalize-url text)
  (define trimmed
    (regexp-replace* #px"^\\s+|\\s+$" text ""))
  (cond
    [(string=? trimmed "") #f]
    [(regexp-match? #px"^[a-zA-Z][a-zA-Z0-9+.-]*:" trimmed) trimmed]
    [else (string-append "https://" trimmed)]))

(define (navigate-to-text! text)
  (define normalized (normalize-url text))
  (cond
    [(not normalized)
     (set-status! "Enter a URL to navigate")]
    [else
     (define url (make-nsurl-init-with-string normalized))
     (cond
       [(or (not url) (objc-null? url))
        (set-status! (format "Invalid URL: ~a" normalized))]
       [else
        (define request (make-nsurlrequest-init-with-url url))
        (wkwebview-load-request web-view request)])]))

;; --- Button targets ---
(define go-target
  (make-delegate
   #:return-types (hash "go:" 'void)
   "go:"
   (lambda (_sender)
     (navigate-to-text! (nsstring->racket-string
                         (nstextfield-string-value address-field))))))
(nsbutton-set-target! go-button go-target)
(nsbutton-set-action! go-button "go:")

;; Address-field target-action fires on Return/Enter — treat as Go.
(nstextfield-set-target! address-field go-target)
(nstextfield-set-action! address-field "go:")

(define back-target
  (make-delegate
   #:return-types (hash "back:" 'void)
   "back:"
   (lambda (_sender)
     (when (wkwebview-can-go-back web-view)
       (wkwebview-go-back web-view)))))
(nsbutton-set-target! back-button back-target)
(nsbutton-set-action! back-button "back:")

(define forward-target
  (make-delegate
   #:return-types (hash "forward:" 'void)
   "forward:"
   (lambda (_sender)
     (when (wkwebview-can-go-forward web-view)
       (wkwebview-go-forward web-view)))))
(nsbutton-set-target! forward-button forward-target)
(nsbutton-set-action! forward-button "forward:")

(define reload-target
  (make-delegate
   #:return-types (hash "reload:" 'void)
   "reload:"
   (lambda (_sender)
     (wkwebview-reload web-view))))
(nsbutton-set-target! reload-button reload-target)
(nsbutton-set-action! reload-button "reload:")

;; --- Initial load ---
(navigate-to-text! "https://www.apple.com")

;; --- Show window and run ---
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

(displayln "Mini Browser running. Close window or Ctrl+C to exit.")
(nsapplication-run app)
