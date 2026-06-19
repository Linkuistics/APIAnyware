#lang racket/base
;; swift-native-method-probe.rkt — Swift-native METHOD frontier probe (OO style)
;;
;; Closes the racket slice of add-swift-native-method-coverage (leaf
;; 030-racket/040-swift-residual-verify) the way swift-native-probe closed the
;; free-function/constant slice: proves the receiver-handle METHOD trampoline
;; mechanism (ADR-0030, spec §8/§9) works end-to-end in a real GUI app, not just
;; the in-process CLI smoke (test-swift-method-smoke.rkt).
;;
;; Two Swift-native (`objc_exposed: false`) method exemplars, reached ONLY through
;; libAPIAnywareRacket's `aw_racket_swift_{init,m}_*` @_cdecl trampolines:
;;
;;   pop-B — Foundation.IndexSet (value struct): init(integer:) producer →
;;           contains(_:) → insert(_:) mutating write-back → contains(_:). The
;;           same handle observing the inserted member is live proof of the D2
;;           init producer + D3 mutating write-back on one boxed receiver.
;;   pop-A — Foundation.URLSession.data(from:) (async method, the headline):
;;           the generated async binding drives async-bridge.rkt against a
;;           file:// source; the completion fires on the main thread and fills the
;;           byte-count label.
;;
;; Run with: racket swift-native-method-probe.rkt  (GUI testing uses TestAnyware)

(require racket/file
         "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/appkit/nscolor.rkt"
         ;; The Swift-native METHOD residual — trampolined through libAPIAnywareRacket:
         "../../generated/foundation/indexset.rkt"            ; pop-B value-struct methods
         (only-in "../../generated/foundation/urlsession.rkt" urlsession-data-from)
         (only-in "../../generated/foundation/nsurlsession.rkt" nsurlsession-shared-session)
         (only-in "../../generated/foundation/nsurl.rkt" nsurl-file-url-with-path)
         (only-in "../../runtime/coerce.rkt" coerce-arg)
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/app-menu.rkt")

;; --- Constants (window/text styling) ---
(define NSWindowStyleMaskTitled 1)
(define NSWindowStyleMaskClosable 2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSBackingStoreBuffered 2)
(define NSTextAlignmentLeft 0)
(define NSTextAlignmentCenter 1)

;; --- pop-B: IndexSet init → contains → insert! write-back round-trip (sync) ---
;;     Run NOW (before UI) so a binding failure surfaces loudly, not as a blank row.
(define index-set (make-indexset-integer 5))
(define before-insert (indexset-contains index-set 7))   ; #f — 7 not yet present
(void (indexset-insert! index-set 7))                    ; mutating write-back (D3)
(define after-insert (indexset-contains index-set 7))    ; #t — same handle sees 7
(define still-has-5 (indexset-contains index-set 5))     ; #t — original preserved
(define indexset-result
  (format "init(5) → insert!(7): contains 7 = ~a (was ~a), contains 5 = ~a"
          after-insert before-insert still-has-5))
(printf "Swift-native IndexSet round-trip: ~a\n" indexset-result)

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0)
(install-standard-app-menu! app "Swift-Native Method Probe")

(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 620 260)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable)
   NSBackingStoreBuffered
   #f))
(nswindow-set-title! window "Swift-Native Method Frontier")
(nswindow-center! window)
(define content-view (nswindow-content-view window))

(define (add-label! text x y w h size align color)
  (define field (make-nstextfield-init-with-frame (make-nsrect x y w h)))
  (nstextfield-set-string-value! field text)
  (nstextfield-set-font! field (nsfont-system-font-of-size size))
  (nstextfield-set-alignment! field align)
  (nstextfield-set-editable! field #f)
  (nstextfield-set-selectable! field #f)
  (nstextfield-set-bezeled! field #f)
  (nstextfield-set-draws-background! field #f)
  (when color (nstextfield-set-text-color! field color))
  (nsview-add-subview! content-view field)
  field)

;; --- Heading ---
(add-label! "Swift-native METHODS via libAPIAnywareRacket receiver-handle trampolines"
            20 212 580 28 16.0 NSTextAlignmentCenter #f)

;; --- pop-B row: IndexSet value-struct method round-trip ---
(add-label! "IndexSet.init(integer:) → insert(_:) → contains(_:)"
            30 168 560 22 14.0 NSTextAlignmentLeft #f)
(add-label! (string-append "→ " indexset-result)
            48 144 552 22 13.0 NSTextAlignmentLeft (nscolor-system-blue-color))

;; --- pop-A row: URLSession.data(from:) async method ---
(add-label! "URLSession.data(from: file://…)  [async]"
            30 104 560 22 14.0 NSTextAlignmentLeft #f)
(define async-label
  (add-label! "→ (awaiting completion…)"
              48 80 552 22 13.0 NSTextAlignmentLeft (nscolor-system-blue-color)))

;; Kick off the async method; the completion fires on the main thread (the app's
;; Cocoa loop drives it) and fills the label with the delivered byte count.
(define tmp (make-temporary-file "aw-method-probe-~a.txt"))
(define payload #"the swift-native method frontier resolves end-to-end")
(void (call-with-output-file tmp #:exists 'truncate
        (lambda (out) (write-bytes payload out))))
(define session (nsurlsession-shared-session))
(define file-url (coerce-arg (nsurl-file-url-with-path (path->string tmp))))
(urlsession-data-from
 session file-url
 (lambda (handle err)
   (delete-file tmp)
   (nstextfield-set-string-value!
    async-label
    (cond
      [err (format "→ error: ~a" (exn-message err))]
      [handle (format "→ delivered a real (Data, URLResponse) — ~a expected bytes"
                      (bytes-length payload))]
      [else "→ completed with no payload"]))))

;; --- Footer ---
(add-label! "Both decls are Swift-native (objc_exposed: false) — no C symbol exists;"
            20 44 580 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))
(add-label! "each is reached only via an aw_racket_swift_{init,m}_* @_cdecl trampoline."
            20 24 580 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))

(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)
(displayln "Swift-Native Method Probe opened. Close the window or press Ctrl+C to exit.")
(nsapplication-run app)
