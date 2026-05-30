;; mini-browser.sls — Mini Browser sample app (chez target).
;;
;; Minimal web browser: an address bar, back/forward/reload controls, a
;; WKWebView that fills the window, and a status line that reflects
;; WKNavigationDelegate callbacks. Typing a URL and pressing Enter (or
;; clicking Go) navigates; a missing scheme gets "https://" prepended.
;; Mirrors generation/targets/racket/apps/mini-browser/mini-browser.rkt.
;;
;; Exercises the first chez delegate with an ASYNC, MULTI-CALLBACK shape:
;; WKNavigationDelegate fires didStartProvisionalNavigation: →
;; didFinishNavigation: / didFailNavigation: from WebKit's run loop, each
;; re-entering Scheme through the `foreign-callable` trampoline whose body
;; wraps in `with-autorelease-pool` + guardian drain (ADR-0007). Where the
;; pdfkit trio's callbacks were synchronous (target-action, notification),
;; these arrive whenever a load resolves — the lifetime model has to hold
;; across run-loop re-entry, not just within one event tick.
;;
;; A second delegate (`ui-target`) carries the four target-action
;; selectors for the toolbar buttons and the address field's Return key.
;;
;; The body of `(define-entry-point (main) ...)` is a procedure body in
;; R6RS terms — all internal `define`s precede every expression. Mixing
;; them is what `(import (chezscheme))` rejects at script load with
;; "invalid context for definition".
;;
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/mini-browser/mini-browser.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-macos-bundle-chez
;;              -- mini-browser`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware webkit)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Window geometry ---
(define WINDOW-W 800)
(define WINDOW-H 600)
(define TOOLBAR-H 32)
(define STATUS-H 22)
(define MARGIN 12)

;; --- URL normalisation (no racket/base regexp here) ---
;;
;; Trim surrounding whitespace, then: empty → #f; already-schemed (a
;; leading `[A-Za-z][A-Za-z0-9+.-]*:`) → unchanged; otherwise prepend
;; "https://". Hand-rolled scanners replace the racket port's
;; `regexp-replace*` / `regexp-match?`, since `(chezscheme)` carries no
;; racket regex.
(define (trim-ws s)
  (let* ([n (string-length s)]
         [start (let loop ([i 0])
                  (if (and (< i n) (char-whitespace? (string-ref s i)))
                      (loop (+ i 1))
                      i))]
         [end (let loop ([j n])
                (if (and (> j start) (char-whitespace? (string-ref s (- j 1))))
                    (loop (- j 1))
                    j))])
    (substring s start end)))

(define (has-uri-scheme? s)
  (let ([n (string-length s)])
    (and (> n 0)
         (char-alphabetic? (string-ref s 0))
         (let loop ([i 1])
           (cond
             [(>= i n) #f]
             [(char=? (string-ref s i) #\:) #t]
             [(let ([c (string-ref s i)])
                (or (char-alphabetic? c)
                    (char-numeric? c)
                    (memv c '(#\+ #\. #\-))))
              (loop (+ i 1))]
             [else #f])))))

(define (normalize-url text)
  (let ([trimmed (trim-ws text)])
    (cond
      [(string=? trimmed "") #f]
      [(has-uri-scheme? trimmed) trimmed]
      [else (string-append "https://" trimmed)])))

(define-entry-point (main)
  ;; ============================================================
  ;; Definitions
  ;; ============================================================

  (define app (nsapplication-shared-application))

  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 WINDOW-W WINDOW-H)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))

  ;; --- Toolbar controls ---
  (define back-button    (make-nsbutton-init-with-frame (make-nsrect 0 0 36 28)))
  (define forward-button (make-nsbutton-init-with-frame (make-nsrect 0 0 36 28)))
  (define reload-button  (make-nsbutton-init-with-frame (make-nsrect 0 0 64 28)))
  (define address-field  (make-nstextfield-init-with-frame (make-nsrect 0 0 480 24)))
  (define go-button      (make-nsbutton-init-with-frame (make-nsrect 0 0 48 28)))

  (define toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
  (define toolbar-stack
    (make-nsstackview-init-with-frame
      (make-nsrect MARGIN toolbar-y (- WINDOW-W (* 2 MARGIN)) TOOLBAR-H)))

  ;; --- Status label (bottom) ---
  (define status-label
    (make-nstextfield-init-with-frame
      (make-nsrect MARGIN MARGIN (- WINDOW-W (* 2 MARGIN)) STATUS-H)))

  ;; --- WKWebView ---
  ;; Fills the area between the toolbar and the status line. Height is
  ;; WINDOW-H minus both chrome rows plus their margins.
  (define web-y (+ MARGIN STATUS-H MARGIN))
  (define web-h (- toolbar-y web-y MARGIN))
  (define web-view
    (make-wkwebview-init-with-frame
      (make-nsrect MARGIN web-y (- WINDOW-W (* 2 MARGIN)) web-h)))

  ;; --- Status helper ---
  (define (set-status! text)
    (nstextfield-set-string-value! status-label text))

  ;; --- UI refresh ---
  ;; WKWebView.title / .URL return NSString / NSURL wrappers (or nil).
  ;; `nsstring->string` collapses a null receiver to "", so the title
  ;; path needs no explicit nil check; the URL path does, because we
  ;; reach through it with `nsurl-absolute-string` first.
  (define (refresh-chrome!)
    (nsbutton-set-enabled! back-button    (wkwebview-can-go-back web-view))
    (nsbutton-set-enabled! forward-button (wkwebview-can-go-forward web-view))
    (let ([title-text (nsstring->string (wkwebview-title web-view))])
      (nswindow-set-title! window
        (if (string=? title-text "")
            "Mini Browser"
            (format #f "~a — Mini Browser" title-text))))
    (let ([u (wkwebview-url web-view)])
      (unless (zero? (objc-object-ptr u))
        (let ([url-text (nsstring->string (nsurl-absolute-string u))])
          (unless (string=? url-text "")
            (nstextfield-set-string-value! address-field url-text))))))

  ;; --- Error surfacing ---
  ;; `err` arrives as a raw uptr from the Swift trampoline (delegate args
  ;; are void*, never pre-wrapped). nil is 0; `coerce-arg` inside the
  ;; generated NSError accessors accepts the raw integer, so no wrap is
  ;; needed to read its localizedDescription. NSAlert has no init in the
  ;; bindings — `+alertWithError:` covers the NSError case exactly.
  (define (show-error! err phase)
    (let ([message (if (zero? err)
                       "Unknown error"
                       (nsstring->string (nserror-localized-description err)))])
      (unless (zero? err)
        (let ([alert (nsalert-alert-with-error err)])
          (unless (zero? (objc-object-ptr alert))
            (nsalert-set-alert-style! alert NSAlertStyleWarning)
            (nsalert-run-modal alert))))
      (set-status! (format #f "~a failed: ~a" phase message))))

  ;; --- Navigation ---
  (define (navigate-to-text! text)
    (let ([normalized (normalize-url text)])
      (cond
        [(not normalized)
         (set-status! "Enter a URL to navigate")]
        [else
         (let ([url (make-nsurl-init-with-string normalized)])
           (cond
             [(zero? (objc-object-ptr url))
              (set-status! (format #f "Invalid URL: ~a" normalized))]
             [else
              (let ([request (make-nsurlrequest-init-with-url url)])
                (wkwebview-load-request web-view request))]))])))

  ;; --- Navigation delegate ---
  ;; WKNavigationDelegate fires three classes of event during a load:
  ;;   1. didStartProvisionalNavigation: — the request left the app
  ;;   2. didFinishNavigation: — page fully loaded, chrome should refresh
  ;;   3. didFailNavigation: / didFailProvisionalNavigation: — error path
  ;;
  ;; The trampoline strips self/_cmd; each proc receives only the method
  ;; args as void*. `_webview` / `_nav` are unused (we ask the one
  ;; web-view we own directly), so we ignore them. The two failure
  ;; selectors carry a third arg, the NSError.
  (define nav-delegate
    (make-delegate
      `(("webView:didStartProvisionalNavigation:"
         ,(lambda (_webview _nav)
            (set-status! "Loading..."))
         (void* void*) void)
        ("webView:didFinishNavigation:"
         ,(lambda (_webview _nav)
            (refresh-chrome!)
            (set-status! "Done"))
         (void* void*) void)
        ("webView:didFailNavigation:withError:"
         ,(lambda (_webview _nav err)
            (show-error! err "load"))
         (void* void* void*) void)
        ("webView:didFailProvisionalNavigation:withError:"
         ,(lambda (_webview _nav err)
            (show-error! err "request"))
         (void* void* void*) void))))

  ;; --- Toolbar target-action delegate ---
  ;; One record, four selectors. The address field's action fires on
  ;; Return/Enter — wired to the same "go:" the Go button uses.
  (define ui-target
    (make-delegate
      `(("go:"
         ,(lambda (_sender)
            (navigate-to-text!
              (nsstring->string (nstextfield-string-value address-field))))
         (void*) void)
        ("back:"
         ,(lambda (_sender)
            (when (wkwebview-can-go-back web-view)
              (wkwebview-go-back web-view)))
         (void*) void)
        ("forward:"
         ,(lambda (_sender)
            (when (wkwebview-can-go-forward web-view)
              (wkwebview-go-forward web-view)))
         (void*) void)
        ("reload:"
         ,(lambda (_sender)
            (wkwebview-reload web-view))
         (void*) void))))

  ;; ============================================================
  ;; Expressions
  ;; ============================================================

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Mini Browser")

  ;; Window
  (nswindow-set-title! window "Mini Browser")
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 500 400))

  ;; Toolbar controls
  (nsbutton-set-title! back-button "\x25C0;")
  (nsbutton-set-bezel-style! back-button NSBezelStyleRounded)
  (nsbutton-set-enabled! back-button #f)

  (nsbutton-set-title! forward-button "\x25B6;")
  (nsbutton-set-bezel-style! forward-button NSBezelStyleRounded)
  (nsbutton-set-enabled! forward-button #f)

  (nsbutton-set-title! reload-button "Reload")
  (nsbutton-set-bezel-style! reload-button NSBezelStyleRounded)

  (nstextfield-set-string-value! address-field "https://www.apple.com")
  (nstextfield-set-editable! address-field #t)
  (nstextfield-set-bordered! address-field #t)

  (nsbutton-set-title! go-button "Go")
  (nsbutton-set-bezel-style! go-button NSBezelStyleRounded)

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

  ;; Status label
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

  ;; Web view
  (nsview-set-autoresizing-mask! web-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view web-view)

  ;; Wire the navigation delegate (weak property — `nav-delegate` is held
  ;; live by this closure for the run loop's duration).
  (wkwebview-set-navigation-delegate! web-view (delegate-ptr nav-delegate))

  ;; Target-action wiring
  (nsbutton-set-target! go-button (delegate-ptr ui-target))
  (nsbutton-set-action! go-button "go:")
  ;; Address-field Return/Enter → treat as Go.
  (nstextfield-set-target! address-field (delegate-ptr ui-target))
  (nstextfield-set-action! address-field "go:")
  (nsbutton-set-target! back-button (delegate-ptr ui-target))
  (nsbutton-set-action! back-button "back:")
  (nsbutton-set-target! forward-button (delegate-ptr ui-target))
  (nsbutton-set-action! forward-button "forward:")
  (nsbutton-set-target! reload-button (delegate-ptr ui-target))
  (nsbutton-set-action! reload-button "reload:")

  ;; Initial load
  (navigate-to-text! "https://www.apple.com")

  ;; Show window and run
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (display "Mini Browser running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

(main)
