;;; swift-native-method-probe.ss — Swift-native METHOD frontier probe (gerbil target).
;;;
;;; Closes the gerbil slice of add-swift-native-method-coverage (leaf
;;; 050-gerbil/020-rerun-verify) the way swift-native-probe closed the
;;; free-function/constant slice: proves the receiver-handle METHOD trampoline
;;; mechanism (ADR-0030 pioneered in racket, ported to gerbil in ADR-0032, spec
;;; §method) works end-to-end in a real GUI app, not just the in-process CLI smoke
;;; (runtime/tests/smoke-swift-method.ss).
;;;
;;; Two Swift-native (`objc_exposed: false`) method exemplars, reached ONLY through
;;; libAPIAnywareGerbil's `aw_gerbil_swift_{init,m}_*` @_cdecl trampolines:
;;;
;;;   pop-B — Foundation.IndexSet (value struct): init(integer:) producer →
;;;           contains(_:) → insert(_:) mutating write-back → contains(_:). The
;;;           SAME boxed AwGerbilValueBox handle observing the inserted member is
;;;           live proof of the D2 init producer + D3 mutating write-back on one
;;;           receiver (no ObjC class to wrap to — a raw opaque handle, ADR-0032 §4).
;;;   pop-A — Foundation.URLSession.data(from:) (async method, the headline): the
;;;           generated async binding drives async-bridge.ss's callback runtime (R4,
;;;           the FIRST gerbil async path, ADR-0032 §5) against a file:// source; the
;;;           completion fires on the main thread (MainActor hop, drained by
;;;           nsapplication-run) and fills the byte-count label.
;;;
;;; Mirrors generation/targets/{racket,chez}/apps/swift-native-method-probe/ one
;;; control at a time (the chez .sls is the closest sibling — same exemplars).
;;;
;;; Build the standalone bundle (compiles the whole closure + links + relocates
;;; libAPIAnywareGerbil into Contents/Frameworks):
;;;   cargo run --example bundle_app -p apianyware-bundle-gerbil -- swift-native-method-probe
;;; (prerequisite: SDKROOT=macosx cargo run -p apianyware-generate -- --target gerbil
;;;  then  (cd swift && SDKROOT=macosx swift build -c release --product APIAnywareGerbil)).
;;; GUI testing uses TestAnyware (see README); never run the app from the CLI.
(import :gerbil-bindings/runtime/objc            ; ->ptr, ptr-null?, wrap
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/enums
        ;; The Swift-native METHOD residual — trampolined through libAPIAnywareGerbil:
        :gerbil-bindings/foundation/indexset      ; pop-B value-struct methods
        ;; After k38 the Swift-overlay `URLSession` merged into the runtime-name
        ;; `NSURLSession`, so `data(from:)` binds as `nsurlsession-data-from` there.
        :gerbil-bindings/foundation/nsurlsession  ; nsurlsession-shared-session, nsurlsession-data-from (pop-A async)
        :gerbil-bindings/foundation/nsurl)        ; nsurl-file-url-with-path
(export main)

(define (handle? p) (and p (not (ptr-null? p))))

(define-entry-point (main)
  ;; --- pop-B: IndexSet init → contains → insert! write-back round-trip (sync) ---
  ;;     Run NOW (before any UI) so a binding failure surfaces loudly rather than
  ;;     as a blank row. One stable boxed handle through every step.
  (let* ((index-set (make-indexset-integer 5))                 ; D2 init producer
         (before-insert (indexset-contains index-set 7))       ; #f — 7 not present
         (_ (indexset-insert! index-set 7))                    ; D3 mutating write-back
         (after-insert (indexset-contains index-set 7))        ; #t — same handle sees 7
         (still-has-5 (indexset-contains index-set 5))         ; #t — original preserved
         (indexset-result
          (string-append "init(5) -> insert!(7): contains 7 = "
                         (if after-insert "#t" "#f")
                         " (was " (if before-insert "#t" "#f")
                         "), contains 5 = " (if still-has-5 "#t" "#f"))))
    (displayln (string-append "Swift-native IndexSet round-trip: " indexset-result))

    ;; --- Application setup ---
    (let (app (nsapplication-shared-application))
      (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
      (install-standard-app-menu! app "Swift-Native Method Probe")

      (let* ((window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                       (make-rect 0. 0. 620. 260.)
                       (bitwise-ior NSWindowStyleMaskTitled
                                    NSWindowStyleMaskClosable
                                    NSWindowStyleMaskMiniaturizable)
                       NSBackingStoreBuffered
                       #f))
             (content-view (nswindow-content-view window)))
        ;; --- Label factory (internal defines precede body expressions) ---
        (define (add-label! text x y w h size align color)
          (let (field (make-nstextfield))
            (nsview-set-frame! field (make-rect x y w h))
            (nscontrol-set-string-value! field (string->nsstring text))
            (nscontrol-set-font! field (nsfont-system-font-of-size size))
            (nscontrol-set-alignment! field align)
            (nstextfield-set-editable! field #f)
            (nstextfield-set-selectable! field #f)
            (nstextfield-set-bezeled! field #f)
            (nstextfield-set-draws-background! field #f)
            (when color (nstextfield-set-text-color! field color))
            (nsview-add-subview! content-view field)
            field))

        (nswindow-set-title! window (string->nsstring "Swift-Native Method Frontier"))
        (nswindow-center! window)

        ;; --- Heading ---
        (add-label! "Swift-native METHODS via libAPIAnywareGerbil receiver-handle trampolines"
                    20. 212. 580. 28. 16. NSTextAlignmentCenter #f)

        ;; --- pop-B row: IndexSet value-struct method round-trip ---
        (add-label! "IndexSet.init(integer:) -> insert(_:) -> contains(_:)"
                    30. 168. 560. 22. 14. NSTextAlignmentLeft #f)
        (add-label! (string-append "-> " indexset-result)
                    48. 144. 552. 22. 13. NSTextAlignmentLeft (nscolor-system-blue-color))

        ;; --- pop-A row: URLSession.data(from:) async method ---
        (add-label! "URLSession.data(from: file://...)  [async]"
                    30. 104. 560. 22. 14. NSTextAlignmentLeft #f)
        (let ((async-label
               (add-label! "-> (awaiting completion...)"
                           48. 80. 552. 22. 13. NSTextAlignmentLeft (nscolor-system-blue-color)))
              ;; Write a deterministic local payload; read it back via the async method.
              (tmp "/tmp/aw-gerbil-method-probe.txt")
              (payload "the gerbil swift-native method frontier resolves end-to-end"))
          (call-with-output-file tmp
            (lambda (p) (display payload p)))
          (let ((session (nsurlsession-shared-session))
                ;; The ObjC fileURLWithPath: binding takes an NSString id; bridge first.
                (file-url (nsurl-file-url-with-path (string->nsstring tmp))))
            ;; Kick off the async method; the completion fires on the main thread (the
            ;; app's Cocoa loop drives it) and fills the label with the byte count.
            (nsurlsession-data-from
             session file-url
             (lambda (result err)
               (nscontrol-set-string-value!
                async-label
                (string->nsstring
                 (cond
                   (err "-> error delivering (Data, URLResponse)")
                   ((handle? result)
                    (string-append "-> delivered a real (Data, URLResponse) -- "
                                   (number->string (string-length payload))
                                   " expected bytes"))
                   (else "-> completed with no payload")))))))

          ;; --- Footer ---
          (add-label! "Both decls are Swift-native (objc_exposed: false) -- no C symbol exists;"
                      20. 44. 580. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))
          (add-label! "each is reached only via an aw_gerbil_swift_{init,m}_* @_cdecl trampoline."
                      20. 24. 580. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))

          ;; --- Show window and run ---
          (nswindow-make-key-and-order-front window #f)
          (nsapplication-activate-ignoring-other-apps app #t)
          (displayln "Swift-Native Method Probe opened. Close the window or press Ctrl+C to exit.")
          (nsapplication-run app))))))

(main)
