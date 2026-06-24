;;;; mini-browser.lisp — Mini Browser sample app (sbcl target, the 060 ladder's sixth
;;;; app). An address bar, ◀/▶/Reload toolbar, a WKWebView that fills the window, and a
;;;; status line that reflects the WKNavigationDelegate callbacks. Typing a URL + Return
;;;; (or clicking Go) navigates; a missing scheme gets "https://" prepended; ◀/▶ walk the
;;;; back-forward list. The sbcl analogue of racket/chez/gerbil's mini-browser.
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:` surface, `make-instance` typed inits (§3.3 — WKWebView's
;;;; `initWithFrame:configuration:`, NSURL's `initWithString:`, NSURLRequest's
;;;; `initWithURL:`), the per-selector generics (§3.2), the `@"…"` NSString reader (§3.2),
;;;; and the subclass macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).
;;;;
;;;; Distinctive (vs. pdfkit-viewer, the prior single-controller app):
;;;;   - FIRST sbcl app to use WebKit (freshly generated for this leaf) and the riskiest
;;;;     delegate shape so far: the ASYNC, MULTI-CALLBACK WKNavigationDelegate.
;;;;     `webView:didStartProvisionalNavigation:` / `didFinishNavigation:` /
;;;;     `didFail…:withError:` fire from WebKit's run loop whenever a load resolves — each
;;;;     re-entering Lisp through the ONE forwarding dispatcher. WebKit delivers
;;;;     navigation-delegate callbacks on the MAIN thread, and the ADR-0035 bounce is a
;;;;     no-op pass-through when already on main (no `dispatch_sync`, no deadlock) — the
;;;;     same path every prior sample's target-action / observer callbacks take.
;;;;   - FIRST sbcl app whose synthesized subclass FORMALLY CONFORMS to a framework
;;;;     protocol: `browser-controller` is `(define-objc-subclass … (:protocols
;;;;     "WKNavigationDelegate"))`, so `class_conformsToProtocol` is true and each nav
;;;;     selector's ABI encoding is read LIVE off the protocol (vs. the synthesized
;;;;     default the target-action selectors fall back to). One controller, EIGHT
;;;;     selectors, two roles: the four WKNavigationDelegate callbacks AND the four
;;;;     toolbar target-actions (go:/back:/forward:/reload:, address field Return→go:).
;;;;   - FIRST nav-delegate selectors with TWO and THREE object args (`v@:@@`, `v@:@@@`).
;;;;     The dispatcher reads arg count + types live off the NSInvocation's
;;;;     NSMethodSignature, so the 2-/3-arg shapes marshal through the same path the
;;;;     1-arg notification observer (pdfkit-viewer) used — no per-arity machinery.
;;;;
;;;; Every WebKit/AppKit/Foundation call is plain ObjC (`:load-residual nil`); the app
;;;; loads `libAPIAnywareSbcl` ONLY for the `aw_sbcl_subclass_*` bounce shim its custom
;;;; delegate needs (as scenekit-viewer/pdfkit-viewer), not for trampoline residual.
;;;;
;;;; DUMP/REVIVE of a synthesized subclass: the ObjC class pair lives in libobjc, not the
;;;; Lisp heap, so `ensure-browser-controller` re-synthesizes it from `-main` in the
;;;; revived image (the runtime re-registers the forwarding dispatcher + re-conforms the
;;;; protocol at startup). defclass/defmethod re-evaluation is idempotent.
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like the other ladder apps).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; The standard app menu (Quit -> -[NSApplication terminate:]), as the other apps.
;;; ---------------------------------------------------------------------------
(defun install-app-menu (app app-name)
  (let ((main-menu   (make-instance 'ns:ns-menu :init-with-title @""))
        (app-item    (make-instance 'ns:ns-menu-item
                       :init-with-title @"" :action "" :key-equivalent @""))
        (app-submenu (make-instance 'ns:ns-menu :init-with-title @""))
        (quit-item   (make-instance 'ns:ns-menu-item
                       :init-with-title (aw-wrap (aw-make-nsstring
                                                  (format nil "Quit ~A" app-name)) t)
                       :action "terminate:"
                       :key-equivalent @"q")))
    (ns:add-item_ app-submenu quit-item)
    (ns:add-item_ main-menu app-item)
    (ns:set-submenu_for-item_ main-menu app-submenu app-item)
    (ns:set-main-menu_ app main-menu)))

;;; ---------------------------------------------------------------------------
;;; Geometry + helpers.
;;; ---------------------------------------------------------------------------
(defconstant +window-w+ 800)
(defconstant +window-h+ 600)
(defconstant +toolbar-h+ 32)
(defconstant +status-h+ 22)
(defconstant +margin+ 12)

(defun ns->str (obj)
  "A wrapped `ns:ns-string` (or any object whose `ptr` is an NSString) -> a Lisp string;
   nil (a wrap of a null id) -> \"\". `nsstring->string` takes the id SAP, so unwrap with
   `aw-ptr`."
  (if obj (nsstring->string (aw-ptr obj)) ""))

;;; --- URL normalisation (hand-rolled scanners; no regex — matches the scheme targets). ---
(defun trim-ws (s)
  (let* ((n (length s))
         (start (loop for i from 0 below n
                      while (member (char s i) '(#\Space #\Tab #\Newline #\Return))
                      finally (return i)))
         (end   (loop for j from n above start
                      while (member (char s (1- j)) '(#\Space #\Tab #\Newline #\Return))
                      finally (return j))))
    (subseq s start end)))

(defun has-uri-scheme-p (s)
  "True if S begins with an RFC-3986 scheme followed by a colon (alpha, then
   alnum / + / - / . up to the colon)."
  (let ((n (length s)))
    (and (> n 0)
         (alpha-char-p (char s 0))
         (loop for i from 1 below n
               for c = (char s i)
               do (cond ((char= c #\:) (return t))
                        ((or (alphanumericp c) (member c '(#\+ #\. #\-)))) ; keep scanning
                        (t (return nil)))
               finally (return nil)))))

(defun normalize-url (text)
  "TEXT -> a navigable URL string, or nil if blank. A bare host (no scheme) gets
   \"https://\" prepended."
  (let ((trimmed (trim-ws text)))
    (cond ((string= trimmed "") nil)
          ((has-uri-scheme-p trimmed) trimmed)
          (t (concatenate 'string "https://" trimmed)))))

;;; ---------------------------------------------------------------------------
;;; UI refresh / status / navigation / error surfacing (pure functions of the
;;; controller's slots). Read with `slot-value` (not per-class `:accessor`s): the bodies
;;; compile when this file loads, but the accessors would only exist once the inner
;;; `define-objc-subclass` RUNS — `slot-value` is always defined, so this compiles
;;; warning-free (the scenekit-viewer / pdfkit-viewer pattern).
;;; ---------------------------------------------------------------------------
(defun set-status (controller text)
  (ns:set-string-value_ (slot-value controller 'status-label)
    (aw-wrap (aw-make-nsstring text) t)))

(defun refresh-chrome (controller)
  "Reconcile ◀/▶ enabled state, the window title, and the address bar with the WKWebView.
   Driven by `didFinishNavigation:`, so it tracks every settled load — typed URLs, ◀/▶
   history, and reloads — identically."
  (let ((web    (slot-value controller 'web-view))
        (back   (slot-value controller 'back-button))
        (fwd    (slot-value controller 'forward-button))
        (window (slot-value controller 'window))
        (field  (slot-value controller 'address-field)))
    (ns:set-enabled_ back (ns:can-go-back web))
    (ns:set-enabled_ fwd  (ns:can-go-forward web))
    (let ((title (ns->str (ns:title web))))
      (ns:set-title_ window
        (aw-wrap (aw-make-nsstring
                  (if (string= title "") "Mini Browser"
                      (concatenate 'string title " — Mini Browser"))) t)))
    (let ((u (ns:url web)))
      (when u
        (let ((url-text (ns->str (ns:absolute-string u))))
          (unless (string= url-text "")
            (ns:set-string-value_ field (aw-wrap (aw-make-nsstring url-text) t))))))))

(defun show-error (controller err phase)
  "Surface a WKNavigationDelegate error: a modal NSAlert built from the NSError, plus a
   status line. ERR arrives wrapped (the `@` arg of the failed-navigation selector)."
  (let ((message (if err (ns->str (ns:localized-description err)) "Unknown error")))
    (when err
      (let ((alert (ns:alert-with-error_ (find-class 'ns:ns-alert) err)))
        (when alert
          (ns:set-alert-style_ alert ns:ns-alert-style-warning)
          (ns:run-modal alert))))
    (set-status controller
      (concatenate 'string phase " failed: " message))))

(defun navigate-to-text (controller text)
  "Normalise TEXT and, if it yields a URL, load it into the WKWebView via an NSURLRequest.
   A blank field or an NSURL the system rejects updates the status line instead."
  (let ((normalized (normalize-url text)))
    (cond
      ((not normalized) (set-status controller "Enter a URL to navigate"))
      (t
       (let ((url (make-instance 'ns:ns-url
                    :init-with-string (aw-wrap (aw-make-nsstring normalized) t))))
         (if (not url)
             (set-status controller (concatenate 'string "Invalid URL: " normalized))
             (let ((request (make-instance 'ns:ns-url-request :init-with-url url)))
               (ns:load-request_ (slot-value controller 'web-view) request))))))))

;;; ---------------------------------------------------------------------------
;;; The controller — a real ObjC subclass of NSObject conforming to WKNavigationDelegate
;;; (contract §3.4/§3.5), holding the live UI refs as slots. Defined INSIDE a function so
;;; it re-synthesizes in a revived dumped image: `-main` is the dumped image's toplevel,
;;; and `aw-synthesize-subclass` / `aw-install-override` must re-run there (the ObjC class
;;; pair + the protocol conformance + the dispatch routing did not survive the dump).
;;; defclass/defmethod re-evaluation is idempotent.
;;; ---------------------------------------------------------------------------
(defvar *browser-controller-ready* nil
  "nil until `ensure-browser-controller` has defined the class in THIS process. A revived
   image starts nil again (the symbol survives the dump, a fresh `defvar` value does not)
   and re-defines.")

(defun ensure-browser-controller ()
  "Define the `browser-controller` ObjC subclass (conforming to WKNavigationDelegate) + its
   eight selectors. Called from `-main` so it runs in whatever process actually shows the UI
   (host pre-flight or revived dump). Idempotent within a process via
   `*browser-controller-ready*`."
  (unless *browser-controller-ready*
    (define-objc-subclass browser-controller (ns:ns-object)
      (:slots
       (web-view       :initarg :web-view)
       (back-button    :initarg :back-button)
       (forward-button :initarg :forward-button)
       (reload-button  :initarg :reload-button)
       (address-field  :initarg :address-field)
       (status-label   :initarg :status-label)
       (window         :initarg :window))
      (:protocols "WKNavigationDelegate"))

    ;; --- Toolbar target-actions (synthesized default v@:@; sender ignored) ---
    (define-objc-method (browser-controller "go:") (self sender)
      (declare (ignore sender))
      (navigate-to-text self (ns->str (ns:string-value (slot-value self 'address-field)))))
    (define-objc-method (browser-controller "back:") (self sender)
      (declare (ignore sender))
      (let ((web (slot-value self 'web-view)))
        (when (ns:can-go-back web) (ns:go-back web))))
    (define-objc-method (browser-controller "forward:") (self sender)
      (declare (ignore sender))
      (let ((web (slot-value self 'web-view)))
        (when (ns:can-go-forward web) (ns:go-forward web))))
    (define-objc-method (browser-controller "reload:") (self sender)
      (declare (ignore sender))
      (ns:reload (slot-value self 'web-view)))

    ;; --- WKNavigationDelegate callbacks (async, main-thread; ABI from the live protocol).
    ;; The webView/navigation args are ignored; the error arg is read via the NSError
    ;; surface. didStart/didFinish are v@:@@ (2 object args); didFail…:withError: is
    ;; v@:@@@ (3 object args) — both marshalled by the one forwarding dispatcher. ---
    (define-objc-method (browser-controller "webView:didStartProvisionalNavigation:")
        (self webview navigation)
      (declare (ignore webview navigation))
      (set-status self "Loading…"))
    (define-objc-method (browser-controller "webView:didFinishNavigation:")
        (self webview navigation)
      (declare (ignore webview navigation))
      (refresh-chrome self)
      (set-status self "Done"))
    (define-objc-method (browser-controller "webView:didFailNavigation:withError:")
        (self webview navigation error)
      (declare (ignore webview navigation))
      (show-error self error "Load"))
    (define-objc-method (browser-controller "webView:didFailProvisionalNavigation:withError:")
        (self webview navigation error)
      (declare (ignore webview navigation))
      (show-error self error "Request"))

    (setf *browser-controller-ready* t)))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun mini-browser-main (&key (run t))
  "Build the Mini-Browser UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060): it synthesizes the controller class
   (incl. WKNavigationDelegate conformance), builds the window + every control, wires
   target-action AND the navigation delegate, AND kicks the initial load — every FFI
   crossing the app does up to the run loop — then returns WITHOUT blocking on `-run`, so a
   bare `sbcl --load` validates marshalling (and, in the revived image, the startup
   re-resolution — frameworks, dispatcher, protocol conformance — plus re-synthesis) before
   the VM round-trip. The dumped image's toplevel calls RUN t."
  (ensure-browser-controller)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Mini Browser")
    (aw-with-rect (frame 0 0 +window-w+ +window-h+)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable
                                           ns:ns-window-style-mask-resizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content (ns:content-view window)))
        (ns:set-title_ window @"Mini Browser")
        (ns:center window)
        (aw-with-size (minsz 500 400) (ns:set-min-size_ window minsz))

        (let* ((toolbar-y (- +window-h+ +margin+ +toolbar-h+))
               (web-y     (+ +margin+ +status-h+ +margin+))
               (web-h     (- toolbar-y web-y +margin+))
               ;; --- WKWebView (needs initWithFrame:configuration:; no bare init) ---
               (web-config (make-instance 'ns:wk-web-view-configuration))
               (web-view   (aw-with-rect (wframe +margin+ web-y
                                                 (- +window-w+ (* 2 +margin+)) web-h)
                             (make-instance 'ns:wk-web-view
                               :init-with-frame wframe
                               :configuration web-config)))
               ;; --- Toolbar controls ---
               (back-button    (make-instance 'ns:ns-button))
               (forward-button (make-instance 'ns:ns-button))
               (reload-button  (make-instance 'ns:ns-button))
               (address-field  (make-instance 'ns:ns-text-field))
               (go-button      (make-instance 'ns:ns-button))
               ;; --- Status label (bottom) ---
               (status-label   (make-instance 'ns:ns-text-field)))

          ;; Web view: fills below the toolbar, above the status line.
          (ns:set-autoresizing-mask_ web-view
            (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))
          (ns:add-subview_ content web-view)

          ;; Toolbar controls.
          (ns:set-title_ back-button @"◀")
          (ns:set-bezel-style_ back-button ns:ns-bezel-style-rounded)
          (ns:set-enabled_ back-button nil)
          (ns:set-title_ forward-button @"▶")
          (ns:set-bezel-style_ forward-button ns:ns-bezel-style-rounded)
          (ns:set-enabled_ forward-button nil)
          (ns:set-title_ reload-button @"Reload")
          (ns:set-bezel-style_ reload-button ns:ns-bezel-style-rounded)

          (ns:set-string-value_ address-field @"https://example.com")
          (ns:set-editable_ address-field t)
          (ns:set-bordered_ address-field t)

          (ns:set-title_ go-button @"Go")
          (ns:set-bezel-style_ go-button ns:ns-bezel-style-rounded)

          ;; Status label.
          (ns:set-font_ status-label (ns:system-font-of-size_ (find-class 'ns:ns-font) 11.0d0))
          (ns:set-editable_ status-label nil)
          (ns:set-selectable_ status-label nil)
          (ns:set-bezeled_ status-label nil)
          (ns:set-draws-background_ status-label nil)
          (aw-with-rect (sframe +margin+ +margin+ (- +window-w+ (* 2 +margin+)) +status-h+)
            (ns:set-frame_ status-label sframe))
          (ns:set-autoresizing-mask_ status-label
            (logior ns:ns-view-width-sizable ns:ns-view-max-y-margin))
          (ns:add-subview_ content status-label)

          ;; --- The controller, holding the live controls (it IS the nav delegate). ---
          (let ((controller (make-instance 'browser-controller
                              :web-view web-view
                              :back-button back-button
                              :forward-button forward-button
                              :reload-button reload-button
                              :address-field address-field
                              :status-label status-label
                              :window window)))

            ;; --- Toolbar: horizontal stack pinned to the top edge, grows with width ---
            (let ((stack (make-instance 'ns:ns-stack-view)))
              (aw-with-rect (tframe +margin+ toolbar-y
                                    (- +window-w+ (* 2 +margin+)) +toolbar-h+)
                (ns:set-frame_ stack tframe))
              (ns:set-orientation_ stack ns:ns-user-interface-layout-orientation-horizontal)
              (ns:set-alignment_ stack ns:ns-layout-attribute-first-baseline)
              (ns:set-spacing_ stack 8.0d0)
              (ns:add-arranged-subview_ stack back-button)
              (ns:add-arranged-subview_ stack forward-button)
              (ns:add-arranged-subview_ stack reload-button)
              (ns:add-arranged-subview_ stack address-field)
              (ns:add-arranged-subview_ stack go-button)
              (ns:set-autoresizing-mask_ stack
                (logior ns:ns-view-width-sizable ns:ns-view-min-y-margin))
              (ns:add-subview_ content stack)

              (ns:set-string-value_ status-label @"Ready")

              ;; --- Wire the navigation delegate (weak property; the controller is held
              ;; by this closure + the *subclass-instances* registry). ---
              (ns:set-navigation-delegate_ web-view controller)

              ;; --- Target-action wiring (after the controller exists) ---
              (ns:set-target_ go-button controller)       (ns:set-action_ go-button "go:")
              (ns:set-target_ address-field controller)   (ns:set-action_ address-field "go:")
              (ns:set-target_ back-button controller)     (ns:set-action_ back-button "back:")
              (ns:set-target_ forward-button controller)  (ns:set-action_ forward-button "forward:")
              (ns:set-target_ reload-button controller)   (ns:set-action_ reload-button "reload:")

              ;; --- Initial load ---
              (navigate-to-text controller "https://example.com")

              ;; --- Show + run ---
              (ns:make-key-and-order-front_ window nil)
              (ns:activate-ignoring-other-apps_ app t)
              (when run
                (format t "~&Mini Browser opened. Type a URL + Return, navigate with ◀/▶/Reload. Quit with Cmd-Q.~%")
                (finish-output)
                (ns:run app))
              controller)))))))
