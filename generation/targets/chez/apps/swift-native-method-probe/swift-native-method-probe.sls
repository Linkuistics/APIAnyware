;; swift-native-method-probe.sls — Swift-native METHOD frontier probe (chez target).
;;
;; Closes the chez slice of add-swift-native-method-coverage (leaf
;; 040-chez/020-rerun-verify) the way swift-native-probe closed the
;; free-function/constant slice: proves the receiver-handle METHOD trampoline
;; mechanism (ADR-0030 pioneered in racket, ported to chez in ADR-0031, spec §8/§9)
;; works end-to-end in a real GUI app, not just the in-process CLI smoke
;; (runtime/tests/smoke-swift-method.sls).
;;
;; Two Swift-native (`objc_exposed: false`) method exemplars, reached ONLY through
;; libAPIAnywareChez's `aw_chez_swift_{init,m}_*` @_cdecl trampolines:
;;
;;   pop-B — Foundation.IndexSet (value struct): init(integer:) producer →
;;           contains(_:) → insert(_:) mutating write-back → contains(_:). The
;;           SAME boxed AwChezValueBox handle observing the inserted member is live
;;           proof of the D2 init producer + D3 mutating write-back on one receiver.
;;   pop-A — Foundation.URLSession.data(from:) (async method, the headline):
;;           the generated async binding drives async-bridge.sls (R4) against a
;;           file:// source; the completion fires on the main thread (MainActor hop,
;;           drained by nsapplication-run) and fills the byte-count label.
;;
;; Mirrors generation/targets/racket/apps/swift-native-method-probe/
;; swift-native-method-probe.rkt one control at a time.
;;
;; Run unbundled with:
;;   chez --libdirs generation/targets/chez \
;;        --script generation/targets/chez/apps/swift-native-method-probe/swift-native-method-probe.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- swift-native-method-probe`. GUI testing uses TestAnyware (see README).

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)                 ; coerce-arg
        ;; The Swift-native METHOD residual — trampolined through libAPIAnywareChez:
        (only (apianyware foundation indexset)     ; pop-B value-struct methods
              make-indexset-integer indexset-contains indexset-insert!)
        ;; After k38 the Swift-overlay `URLSession` merged into the runtime-name
        ;; `NSURLSession`, so `data(from:)` binds as `nsurlsession-data-from` there.
        (only (apianyware foundation nsurlsession)
              nsurlsession-shared-session nsurlsession-data-from)
        (only (apianyware foundation nsurl) nsurl-file-url-with-path))

(define-entry-point (main)
  ;; --- pop-B: IndexSet init → contains → insert! write-back round-trip (sync) ---
  ;;     Run NOW (before any UI) so a binding failure surfaces loudly rather than
  ;;     as a blank row. One stable boxed handle through every step.
  (let* ([index-set (make-indexset-integer 5)]                 ; D2 init producer
         [before-insert (indexset-contains index-set 7)]       ; #f — 7 not present
         [_ (indexset-insert! index-set 7)]                    ; D3 mutating write-back
         [after-insert (indexset-contains index-set 7)]        ; #t — same handle sees 7
         [still-has-5 (indexset-contains index-set 5)]         ; #t — original preserved
         [indexset-result
          (format "init(5) -> insert!(7): contains 7 = ~a (was ~a), contains 5 = ~a"
                  after-insert before-insert still-has-5)])
    (printf "Swift-native IndexSet round-trip: ~a\n" indexset-result)

    ;; --- Application setup ---
    (let ([app (nsapplication-shared-application)])
      (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
      (install-standard-app-menu! app "Swift-Native Method Probe")

      (let* ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                       (make-nsrect 0 0 620 260)
                       (bitwise-ior NSWindowStyleMaskTitled
                                    NSWindowStyleMaskClosable
                                    NSWindowStyleMaskMiniaturizable)
                       NSBackingStoreBuffered
                       #f)]
             [content-view (nswindow-content-view window)])
        ;; --- Label factory (internal defines must precede body expressions) ---
        (define (add-label! text x y w h size align color)
          (let ([field (make-nstextfield-init-with-frame (make-nsrect x y w h))])
            (nstextfield-set-string-value! field text)
            (nstextfield-set-font! field (nsfont-system-font-of-size size))
            (nstextfield-set-alignment! field align)
            (nstextfield-set-editable! field #f)
            (nstextfield-set-selectable! field #f)
            (nstextfield-set-bezeled! field #f)
            (nstextfield-set-draws-background! field #f)
            (when color (nstextfield-set-text-color! field color))
            (nsview-add-subview! content-view field)
            field))

        (nswindow-set-title! window "Swift-Native Method Frontier")
        (nswindow-center! window)

        ;; --- Heading ---
        (add-label! "Swift-native METHODS via libAPIAnywareChez receiver-handle trampolines"
                    20 212 580 28 16.0 NSTextAlignmentCenter #f)

        ;; --- pop-B row: IndexSet value-struct method round-trip ---
        (add-label! "IndexSet.init(integer:) -> insert(_:) -> contains(_:)"
                    30 168 560 22 14.0 NSTextAlignmentLeft #f)
        (add-label! (string-append "-> " indexset-result)
                    48 144 552 22 13.0 NSTextAlignmentLeft (nscolor-system-blue-color))

        ;; --- pop-A row: URLSession.data(from:) async method ---
        (add-label! "URLSession.data(from: file://...)  [async]"
                    30 104 560 22 14.0 NSTextAlignmentLeft #f)
        (let ([async-label
               (add-label! "-> (awaiting completion...)"
                           48 80 552 22 13.0 NSTextAlignmentLeft (nscolor-system-blue-color))]
              ;; Write a deterministic local payload; read it back via the async method.
              [tmp "/tmp/aw-chez-method-probe.txt"]
              [payload "the chez swift-native method frontier resolves end-to-end"])
          (call-with-port (open-file-output-port tmp (file-options no-fail))
            (lambda (p) (put-bytevector p (string->utf8 payload))))
          (let ([session (nsurlsession-shared-session)]
                ;; R1: the @_cdecl reconstructs URL from NSURL, so unwrap the wrapper.
                [file-url (coerce-arg (nsurl-file-url-with-path tmp))])
            ;; Kick off the async method; the completion fires on the main thread (the
            ;; app's Cocoa loop drives it) and fills the label with the byte count.
            (nsurlsession-data-from
             session file-url
             (lambda (handle err)
               (nstextfield-set-string-value!
                async-label
                (cond
                  [err "-> error delivering (Data, URLResponse)"]
                  [(and (integer? handle) (> handle 0))
                   (format "-> delivered a real (Data, URLResponse) -- ~a expected bytes"
                           (string-length payload))]
                  [else "-> completed with no payload"])))))

          ;; --- Footer ---
          (add-label! "Both decls are Swift-native (objc_exposed: false) -- no C symbol exists;"
                      20 44 580 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))
          (add-label! "each is reached only via an aw_chez_swift_{init,m}_* @_cdecl trampoline."
                      20 24 580 20 12.0 NSTextAlignmentCenter (nscolor-secondary-label-color))

          ;; --- Show window and run ---
          (nswindow-make-key-and-order-front window #f)
          (nsapplication-activate-ignoring-other-apps app #t)
          (display "Swift-Native Method Probe opened. Close the window or press Ctrl+C to exit.\n")
          (nsapplication-run app))))))

(main)
