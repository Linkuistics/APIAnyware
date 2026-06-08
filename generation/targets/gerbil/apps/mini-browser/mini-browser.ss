;;; mini-browser.ss — Mini Browser sample app (gerbil target).
;;;
;;; Minimal web browser: an address bar, back/forward/reload controls, a
;;; WKWebView that fills the window, and a status line that reflects
;;; WKNavigationDelegate callbacks. Typing a URL and pressing Enter (or clicking
;;; Go) navigates; a missing scheme gets "https://" prepended. Mirrors
;;; generation/targets/chez/apps/mini-browser/mini-browser.sls one piece at a time.
;;;
;;; The riskiest feature: the WKNavigationDelegate's ASYNC, MULTI-CALLBACK shape.
;;; didStartProvisionalNavigation: / didFinishNavigation: / didFail…withError:
;;; fire from WebKit's run loop whenever a load resolves, each re-entering Gerbil
;;; through a `make-delegate` IMP trampoline. WebKit delivers navigation-delegate
;;; callbacks on the MAIN thread, and the ADR-0022 trampoline calls the Gerbil
;;; body directly when already on the main thread (the same path every prior
;;; gerbil sample's target-action callbacks take), so no main-thread bounce /
;;; deadlock. A second delegate carries the four toolbar target-actions + the
;;; address field's Return action.
;;;
;;; Gerbil idiom notes:
;;;   - WKWebView needs initWithFrame:configuration: (no bare init), so a
;;;     WKWebViewConfiguration is created up front.
;;;   - NSString objects coming back from the bindings are `wrap`ped, so reading
;;;     them is `(nsstring->string (->ptr obj))`, guarded by `wrap`→#f for nil.
;;;   - delegate args are wrapped via the 'object token; the procs ignore the
;;;     webView/nav args and read the NSError via `nserror-localized-description`.
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
        :gerbil-bindings/appkit/nsalert
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/foundation/nsurl
        :gerbil-bindings/foundation/nsurlrequest
        ;; only nserror-localized-description: the generated NSError module also
        ;; exports nserror-code/nserror-domain, which collide with runtime/objc's
        ;; ADR-0006 `nserror` defstruct accessors (same names). `only-in` avoids
        ;; the ambiguous-import error.
        (only-in :gerbil-bindings/foundation/nserror nserror-localized-description)
        :gerbil-bindings/webkit/wkwebview
        :gerbil-bindings/webkit/wkwebviewconfiguration)
(export main)

;; --- Window geometry ---
(def WINDOW-W 800.)
(def WINDOW-H 600.)
(def TOOLBAR-H 32.)
(def STATUS-H 22.)
(def MARGIN 12.)

;; --- NSString object → Scheme string (wrap→#f for nil → ""). ---
(def (ns->str obj) (if obj (nsstring->string (->ptr obj)) ""))

;; --- URL normalisation (hand-rolled scanners; no regex). ---
(def (trim-ws s)
  (let* ((n (string-length s))
         (start (let loop ((i 0))
                  (if (and (< i n) (char-whitespace? (string-ref s i))) (loop (+ i 1)) i)))
         (end (let loop ((j n))
                (if (and (> j start) (char-whitespace? (string-ref s (- j 1)))) (loop (- j 1)) j))))
    (substring s start end)))

(def (has-uri-scheme? s)
  (let (n (string-length s))
    (and (> n 0)
         (char-alphabetic? (string-ref s 0))
         (let loop ((i 1))
           (cond
             ((>= i n) #f)
             ((char=? (string-ref s i) #\:) #t)
             ((let (c (string-ref s i))
                (or (char-alphabetic? c) (char-numeric? c) (memv c '(#\+ #\. #\-))))
              (loop (+ i 1)))
             (else #f))))))

(def (normalize-url text)
  (let (trimmed (trim-ws text))
    (cond
      ((string=? trimmed "") #f)
      ((has-uri-scheme? trimmed) trimmed)
      (else (string-append "https://" trimmed)))))

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================
  (def app (nsapplication-shared-application))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. WINDOW-W WINDOW-H)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (def content-view (nswindow-content-view window))

  ;; --- Toolbar controls ---
  (def back-button    (make-nsbutton))
  (def forward-button (make-nsbutton))
  (def reload-button  (make-nsbutton))
  (def address-field  (make-nstextfield))
  (def go-button      (make-nsbutton))

  (def toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
  (def toolbar-stack (make-nsstackview))

  ;; --- Status label (bottom) ---
  (def status-label (make-nstextfield))

  ;; --- WKWebView (needs a configuration; no bare init) ---
  (def web-y (+ MARGIN STATUS-H MARGIN))
  (def web-h (- toolbar-y web-y MARGIN))
  (def web-config (make-wkwebviewconfiguration))
  (def web-view
    (make-wkwebview-init-with-frame-configuration
      (make-rect MARGIN web-y (- WINDOW-W (* 2. MARGIN)) web-h)
      web-config))

  (def (set-status! text) (nscontrol-set-string-value! status-label (string->nsstring text)))

  ;; --- UI refresh from WKWebView state ---
  (def (refresh-chrome!)
    (nscontrol-set-enabled! back-button    (wkwebview-can-go-back web-view))
    (nscontrol-set-enabled! forward-button (wkwebview-can-go-forward web-view))
    (let (title-text (ns->str (wkwebview-title web-view)))
      (nswindow-set-title! window
        (string->nsstring
          (if (string=? title-text "") "Mini Browser"
              (string-append title-text " — Mini Browser")))))
    (let (u (wkwebview-url web-view))
      (when u
        (let (url-text (ns->str (nsurl-absolute-string u)))
          (unless (string=? url-text "")
            (nscontrol-set-string-value! address-field (string->nsstring url-text)))))))

  ;; --- Error surfacing (err arrives wrapped via the 'object token) ---
  (def (show-error! err phase)
    (let (message (if err (ns->str (nserror-localized-description err)) "Unknown error"))
      (when err
        (let (alert (nsalert-alert-with-error err))
          (when alert
            (nsalert-set-alert-style! alert NSAlertStyleWarning)
            (nsalert-run-modal alert))))
      (set-status! (string-append phase " failed: " message))))

  ;; --- Navigation ---
  (def (navigate-to-text! text)
    (let (normalized (normalize-url text))
      (cond
        ((not normalized) (set-status! "Enter a URL to navigate"))
        (else
         (let (url (make-nsurl-init-with-string (string->nsstring normalized)))
           (if (not url)
             (set-status! (string-append "Invalid URL: " normalized))
             (let (request (make-nsurlrequest-init-with-url url))
               (wkwebview-load-request web-view request))))))))

  ;; --- Navigation delegate (async, multi-callback) ---
  (def nav-delegate
    (make-delegate
      (list
        (list "webView:didStartProvisionalNavigation:"
              (lambda (webview nav) (set-status! "Loading…"))
              (list 'object 'object) 'void)
        (list "webView:didFinishNavigation:"
              (lambda (webview nav) (refresh-chrome!) (set-status! "Done"))
              (list 'object 'object) 'void)
        (list "webView:didFailNavigation:withError:"
              (lambda (webview nav err) (show-error! err "load"))
              (list 'object 'object 'object) 'void)
        (list "webView:didFailProvisionalNavigation:withError:"
              (lambda (webview nav err) (show-error! err "request"))
              (list 'object 'object 'object) 'void))))

  ;; --- Toolbar target-action delegate (4 selectors) ---
  (def ui-target
    (make-delegate
      (list
        (list "go:"
              (lambda (sender)
                (navigate-to-text! (ns->str (nscontrol-string-value address-field))))
              (list 'object) 'void)
        (list "back:"
              (lambda (sender) (when (wkwebview-can-go-back web-view) (wkwebview-go-back web-view)))
              (list 'object) 'void)
        (list "forward:"
              (lambda (sender) (when (wkwebview-can-go-forward web-view) (wkwebview-go-forward web-view)))
              (list 'object) 'void)
        (list "reload:"
              (lambda (sender) (wkwebview-reload web-view))
              (list 'object) 'void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================
  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Mini Browser")

  (nswindow-set-title! window (string->nsstring "Mini Browser"))
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 500. 400.))

  ;; Toolbar controls
  (nsbutton-set-title! back-button (string->nsstring "◀"))
  (nsbutton-set-bezel-style! back-button NSBezelStyleRounded)
  (nscontrol-set-enabled! back-button #f)
  (nsbutton-set-title! forward-button (string->nsstring "▶"))
  (nsbutton-set-bezel-style! forward-button NSBezelStyleRounded)
  (nscontrol-set-enabled! forward-button #f)
  (nsbutton-set-title! reload-button (string->nsstring "Reload"))
  (nsbutton-set-bezel-style! reload-button NSBezelStyleRounded)

  (nscontrol-set-string-value! address-field (string->nsstring "https://example.com"))
  (nstextfield-set-editable! address-field #t)
  (nstextfield-set-bordered! address-field #t)

  (nsbutton-set-title! go-button (string->nsstring "Go"))
  (nsbutton-set-bezel-style! go-button NSBezelStyleRounded)

  (nsview-set-frame! toolbar-stack
    (make-rect MARGIN toolbar-y (- WINDOW-W (* 2. MARGIN)) TOOLBAR-H))
  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.)
  (nsstackview-add-arranged-subview! toolbar-stack back-button)
  (nsstackview-add-arranged-subview! toolbar-stack forward-button)
  (nsstackview-add-arranged-subview! toolbar-stack reload-button)
  (nsstackview-add-arranged-subview! toolbar-stack address-field)
  (nsstackview-add-arranged-subview! toolbar-stack go-button)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; Status label
  (nsview-set-frame! status-label (make-rect MARGIN MARGIN (- WINDOW-W (* 2. MARGIN)) STATUS-H))
  (nscontrol-set-string-value! status-label (string->nsstring "Ready"))
  (nscontrol-set-font! status-label (nsfont-system-font-of-size 11.))
  (nscontrol-set-alignment! status-label NSTextAlignmentLeft)
  (nstextfield-set-editable! status-label #f)
  (nstextfield-set-selectable! status-label #f)
  (nstextfield-set-bezeled! status-label #f)
  (nstextfield-set-draws-background! status-label #f)
  (nsview-set-autoresizing-mask! status-label
    (bitwise-ior NSViewWidthSizable NSViewMaxYMargin))
  (nsview-add-subview! content-view status-label)

  ;; Web view
  (nsview-set-frame! web-view (make-rect MARGIN web-y (- WINDOW-W (* 2. MARGIN)) web-h))
  (nsview-set-autoresizing-mask! web-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view web-view)

  ;; Wire the navigation delegate (weak property; nav-delegate held by this closure)
  (wkwebview-set-navigation-delegate! web-view nav-delegate)

  ;; Target-action wiring (buttons + field inherit set-target!/action! from NSControl)
  (nscontrol-set-target! go-button ui-target)      (nscontrol-set-action! go-button "go:")
  (nscontrol-set-target! address-field ui-target)  (nscontrol-set-action! address-field "go:")
  (nscontrol-set-target! back-button ui-target)    (nscontrol-set-action! back-button "back:")
  (nscontrol-set-target! forward-button ui-target) (nscontrol-set-action! forward-button "forward:")
  (nscontrol-set-target! reload-button ui-target)  (nscontrol-set-action! reload-button "reload:")

  ;; Initial load
  (navigate-to-text! "https://example.com")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (displayln "Mini Browser running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
