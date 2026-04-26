#lang racket/base
;; ui/panel-manager.rkt — NSPanel + WKWebView management
;;
;; Manages WKWebView-backed NSPanels. Each panel is identified by a
;; string id and can be configured as activating (takes keyboard focus)
;; or non-activating (floating overlay).
;;
;; API:
;;   (create-panel! id [options ...]) — create a panel with WKWebView
;;   (close-panel! id)               — close and destroy a panel
;;   (panel-set-html! id html)       — set full HTML content
;;   (panel-eval-js! id script)      — evaluate JavaScript
;;   (panel-set-message-handler! id handler) — register message handler
;;   (panel-resize! id height)       — resize panel height (top edge fixed)

(require "../bindings/runtime/objc-interop.rkt"
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/runtime/delegate.rkt"
         "../bindings/runtime/dynamic-class.rkt"
         "../bindings/runtime/type-mapping.rkt"
         "../bindings/generated/oo/appkit/nspanel.rkt"
         ;; nsscreen.rkt has a duplicate definition bug — use raw tell instead
         "../bindings/generated/oo/appkit/nscolor.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../bindings/generated/oo/webkit/wkwebview.rkt"
         "../bindings/generated/oo/webkit/wkwebviewconfiguration.rkt"
         "../bindings/generated/oo/webkit/wkusercontentcontroller.rkt"
         "../bindings/generated/oo/webkit/wkscriptmessage.rkt")

(provide create-panel!
         close-panel!
         panel-set-html!
         panel-eval-js!
         panel-set-message-handler!
         panel-resize!
         ;; ObjC dictionary helpers (used by chooser.rkt for message extraction)
         objc-dict-get
         objc-dict-get-number)

;; ─── Style Mask Constants ─────────────────────────────────────

(define NSWindowStyleMaskBorderless 0)
(define NSWindowStyleMaskNonactivatingPanel 128)  ; 1 << 7

;; NSWindow level
(define NSFloatingWindowLevel 3)    ; kCGFloatingWindowLevel
(define NSNormalWindowLevel 0)

;; NSWindow collection behavior
(define NSWindowCollectionBehaviorCanJoinAllSpaces 1)  ; 1 << 0

;; NSBackingStoreType
(define NSBackingStoreBuffered 2)

;; NSViewAutoresizingMask
(define NSViewWidthSizable 2)   ; 1 << 1
(define NSViewHeightSizable 16) ; 1 << 4

;; ─── KeyablePanel (activating panels) ────────────────────────
;; A borderless NSPanel can't become the key window by default,
;; which prevents keyboard input in WKWebView. Create a dynamic
;; ObjC subclass that overrides canBecomeKeyWindow/canBecomeMainWindow.
;;
;; The IMP proc must be held at module scope — if only held as a local,
;; GC will collect it and the dynamic dispatch becomes a dangling pointer.

(define returns-yes-proc (lambda (self sel) #t))
(define returns-yes-fptr
  (function-ptr returns-yes-proc (_cprocedure (list _pointer _pointer) _bool)))

(define KeyablePanel-class
  (make-dynamic-subclass
   "NSPanel" "ModaliserKeyablePanel"
   (list (list "canBecomeKeyWindow"  returns-yes-fptr "B@:")
         (list "canBecomeMainWindow" returns-yes-fptr "B@:"))))

(define (make-keyable-panel rect style-mask)
  (tell (tell (coerce-arg KeyablePanel-class) alloc)
        initWithContentRect: #:type _NSRect rect
        styleMask: #:type _uint64 style-mask
        backing: #:type _uint64 NSBackingStoreBuffered
        defer: #:type _bool #t))

;; ─── Panel Registry ──────────────────────────────────────────

;; Stores panel state: hash of id -> (hash 'panel 'webview 'handler 'delegate)
(define panels (make-hash))

;; GC roots — prevent Cocoa-weak objects from being collected.
;; Per-panel roots stored in panel-gc-roots (id -> list), cleared on close.
;; Global roots for objects that outlive any single panel.
(define panel-gc-roots (make-hash))
(define global-gc-roots '())

(define (gc-root! id obj)
  (hash-set! panel-gc-roots id
    (cons obj (hash-ref panel-gc-roots id '())))
  obj)

(define (gc-root-global! obj)
  (set! global-gc-roots (cons obj global-gc-roots))
  obj)

(define (gc-unroot-panel! id)
  (hash-remove! panel-gc-roots id))

;; ─── Script Message Handler ──────────────────────────────────
;; Single delegate implements WKScriptMessageHandler protocol.
;; Routes messages to the appropriate panel's handler based on
;; matching the userContentController.

(define (dispatch-script-message user-content-controller message)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (displayln (format "panel-manager: script message error: ~a"
                                        (exn-message e))))])
  ;; Extract message body — JS objects arrive as NSDictionary/NSString/NSNumber
  (define body (wkscriptmessage-body (borrow-objc-object message)))
  ;; Find which panel this came from by checking each panel's WKWebView config
  (for ([(id info) (in-hash panels)])
    (define wv (hash-ref info 'webview #f))
    (when wv
      (define config (wkwebview-configuration wv))
      (define ucc (wkwebviewconfiguration-user-content-controller config))
      (when (ptr-equal? (coerce-arg ucc) (coerce-arg user-content-controller))
        ;; Check for resize messages — handle natively
        (define msg-type (objc-dict-get body "type"))
        (cond
          [(and msg-type (string=? msg-type "resize"))
           (define height (objc-dict-get-number body "height"))
           (when height
             (panel-resize! id height))]
          [else
           ;; Route to registered handler
           (define handler (hash-ref info 'handler #f))
           (when handler
             (handler body))]))))))

;; ─── ObjC Dictionary Helpers ─────────────────────────────────
;; WKScriptMessage body from JS objects is an NSDictionary.
;; These helpers extract string and number values.

(import-class NSString NSNumber)

(define (objc-dict-get dict key)
  ;; dict[key] via objectForKey:, returns string or #f
  ;; coerce-arg needed: body from wkscriptmessage-body is objc-object wrapper
  (define ns-key (tell NSString stringWithUTF8String: #:type _string key))
  (define val (tell (coerce-arg dict) objectForKey: ns-key))
  (if (objc-nil? val)
      #f
      (tell #:type _string val UTF8String)))

(define (objc-dict-get-number dict key)
  ;; dict[key] via objectForKey:, returns number or #f
  (define ns-key (tell NSString stringWithUTF8String: #:type _string key))
  (define val (tell (coerce-arg dict) objectForKey: ns-key))
  (if (objc-nil? val)
      #f
      (tell #:type _double val doubleValue)))

;; ─── Create Panel ────────────────────────────────────────────

(define (create-panel! id
                       #:width [width 300]
                       #:height [height 400]
                       #:x [x #f]
                       #:y [y #f]
                       #:activating [activating #f]
                       #:floating [floating #t]
                       #:transparent [transparent #f]
                       #:shadow [shadow #t])
  ;; Close existing panel with same id
  (close-panel! id)

  ;; Style mask
  (define style-mask
    (if activating
        NSWindowStyleMaskBorderless
        (bitwise-ior NSWindowStyleMaskBorderless
                     NSWindowStyleMaskNonactivatingPanel)))

  ;; Create NSPanel (KeyablePanel subclass for activating panels)
  (define panel-rect (make-nsrect 0.0 0.0 (exact->inexact width) (exact->inexact height)))
  (define panel
    (if activating
        (make-keyable-panel panel-rect style-mask)
        (make-nspanel-init-with-content-rect-style-mask-backing-defer
         panel-rect style-mask NSBackingStoreBuffered #t)))
  (gc-root! id panel)

  ;; Configure panel properties
  (nspanel-set-level! panel (if floating NSFloatingWindowLevel NSNormalWindowLevel))
  (nspanel-set-opaque! panel #f)
  (nspanel-set-background-color! panel
    (if transparent (nscolor-clear-color) (nscolor-window-background-color)))
  ;; Transparent panels use CSS box-shadow; no system shadow
  (nspanel-set-has-shadow! panel (if transparent #f shadow))
  (nspanel-set-movable-by-window-background! panel #f)
  (nspanel-set-hides-on-deactivate! panel #f)
  ;; Allow panel to appear on all Spaces
  (nspanel-set-collection-behavior! panel NSWindowCollectionBehaviorCanJoinAllSpaces)

  ;; Create WKWebViewConfiguration with message handler
  (import-class WKWebViewConfiguration)
  (define config (gc-root! id (wrap-objc-object (tell (tell WKWebViewConfiguration alloc) init))))
  (define ucc (wkwebviewconfiguration-user-content-controller config))

  ;; Create a delegate for WKScriptMessageHandler
  (define msg-handler-delegate
    (gc-root! id
     (make-delegate
      "userContentController:didReceiveScriptMessage:"
      (lambda (controller message)
        (dispatch-script-message controller message)))))

  ;; Register the message handler with name "modaliser"
  (wkusercontentcontroller-add-script-message-handler-name!
   ucc msg-handler-delegate "modaliser")

  ;; Create WKWebView
  (define content-view (nspanel-content-view panel))
  (define content-bounds (tell #:type _NSRect (coerce-arg content-view) bounds))
  (define webview
    (gc-root! id
     (make-wkwebview-init-with-frame-configuration content-bounds config)))

  ;; Set autoresizing mask so webview fills panel.
  ;; Not in generated WKWebView bindings (inherited from NSView).
  (tell (coerce-arg webview)
        setAutoresizingMask: #:type _uint64
        (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

  ;; Transparent background for WKWebView
  (when transparent
    (wkwebview-set-under-page-background-color! webview (nscolor-clear-color))
    ;; drawsBackground is not a standard binding — use KVC
    (tell (coerce-arg webview) setValue: (tell NSNumber numberWithBool: #:type _bool #f)
                               forKey: (coerce-arg "drawsBackground")))

  ;; Add webview to panel
  (tell (coerce-arg content-view) addSubview: (coerce-arg webview))

  ;; Position panel
  (cond
    [(and x y)
     (nspanel-set-frame-origin! panel (make-nspoint (exact->inexact x) (exact->inexact y)))]
    [else
     ;; Center horizontally, upper-fifth vertically
     ;; Using raw tell for NSScreen because generated binding has duplicate def bug
     (import-class NSScreen)
     (define screen (tell NSScreen mainScreen))
     (when screen
       (define sf (tell #:type _NSRect screen visibleFrame))
       (define sf-x (NSPoint-x (NSRect-origin sf)))
       (define sf-y (NSPoint-y (NSRect-origin sf)))
       (define sf-w (NSSize-width (NSRect-size sf)))
       (define sf-h (NSSize-height (NSRect-size sf)))
       (define px (- (+ sf-x (/ sf-w 2.0)) (/ (exact->inexact width) 2.0)))
       (define py (- (+ sf-y sf-h) (* sf-h 0.2) (exact->inexact height)))
       (nspanel-set-frame-origin! panel (make-nspoint px py)))])

  ;; Show panel
  (if activating
      (begin
        (void (nsapplication-activate-ignoring-other-apps
               (nsapplication-shared-application) #t))
        (nspanel-make-key-and-order-front panel #f))
      (nspanel-order-front! panel #f))

  ;; Resign-key delegate — dismiss activating panels on click-outside.
  ;; Body is wrapped in with-handlers — unhandled exceptions in ObjC
  ;; delegate callbacks crash the app with no Racket stack trace.
  (define resign-delegate
    (if activating
        (let ([panel-id id])
          (gc-root! id
            (make-delegate
              "windowDidResignKey:"
              (lambda (notif)
                (with-handlers ([exn:fail?
                                 (lambda (e)
                                   (eprintf "windowDidResignKey delegate error: ~a\n"
                                            (exn-message e)))])
                  (define info (hash-ref panels panel-id #f))
                  (when info
                    (define handler (hash-ref info 'handler #f))
                    (when handler
                      (handler (list (cons 'type "cancel"))))))))))
        #f))
  (when resign-delegate
    (tell (coerce-arg panel) setDelegate: (coerce-arg resign-delegate)))

  ;; Store in registry
  (hash-set! panels id
    (make-hash (list (cons 'panel panel)
                     (cons 'webview webview)
                     (cons 'handler #f)
                     (cons 'msg-delegate msg-handler-delegate)
                     (cons 'resign-delegate resign-delegate)))))

;; ─── Close Panel ─────────────────────────────────────────────

(define (close-panel! id)
  (define info (hash-ref panels id #f))
  (when info
    (define webview (hash-ref info 'webview #f))
    (when webview
      (define config (wkwebview-configuration webview))
      (define ucc (wkwebviewconfiguration-user-content-controller config))
      (wkusercontentcontroller-remove-script-message-handler-for-name! ucc "modaliser"))
    (define panel (hash-ref info 'panel #f))
    (when panel
      ;; Remove resign-key delegate before closing to prevent spurious callbacks
      (tell (coerce-arg panel) setDelegate: #f)
      (nspanel-order-out! panel #f)
      (nspanel-close! panel))
    (hash-remove! panels id)
    (gc-unroot-panel! id)))

;; ─── Set HTML ────────────────────────────────────────────────

(define (panel-set-html! id html)
  (define info (hash-ref panels id #f))
  (when info
    (define webview (hash-ref info 'webview #f))
    (when webview
      (wkwebview-load-html-string-base-url webview html #f))))

;; ─── Evaluate JavaScript ─────────────────────────────────────

(define (panel-eval-js! id script)
  (define info (hash-ref panels id #f))
  (when info
    (define webview (hash-ref info 'webview #f))
    (when webview
      ;; Pass no-op lambda (not #f) — make-objc-block wraps the proc in a
      ;; C block that WKWebView invokes on completion. #f causes "not a procedure" crash.
      (wkwebview-evaluate-java-script-completion-handler webview script
        (lambda (result error) (void))))))

;; ─── Set Message Handler ─────────────────────────────────────

(define (panel-set-message-handler! id handler)
  (define info (hash-ref panels id #f))
  (when info
    (hash-set! info 'handler handler)))

;; ─── Resize Panel ────────────────────────────────────────────
;; Resize height while keeping the top edge fixed.
;; In Cocoa, window origin is at bottom-left, so we must adjust
;; origin.y when changing height.

(define (panel-resize! id height)
  (define info (hash-ref panels id #f))
  (when info
    (define panel (hash-ref info 'panel #f))
    (when panel
      (define frame (nspanel-frame panel))
      (define old-height (NSSize-height (NSRect-size frame)))
      (define delta (- (exact->inexact height) old-height))
      (define new-origin
        (make-nspoint (NSPoint-x (NSRect-origin frame))
                      (- (NSPoint-y (NSRect-origin frame)) delta)))
      (define new-frame
        (make-nsrect (NSPoint-x new-origin)
                     (NSPoint-y new-origin)
                     (NSSize-width (NSRect-size frame))
                     (exact->inexact height)))
      (nspanel-set-frame-display! panel new-frame #t))))
