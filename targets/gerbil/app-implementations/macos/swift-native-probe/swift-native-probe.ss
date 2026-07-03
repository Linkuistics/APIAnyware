;;; swift-native-probe.ss — Swift-native API coverage probe (gerbil target).
;;;
;;; Closes the gerbil slice of the add-swift-native-api-coverage grove (leaf
;;; 070/030): proves the complete-API trampoline mechanism (ADR-0025 / ADR-0027,
;;; ported to gerbil in ADR-0029) works end-to-end in a real GUI app, not just
;;; the in-process CLI smoke (runtime/tests/smoke-swift-trampoline.ss).
;;;
;;; It calls a Swift-native FREE FUNCTION (CreateML.timestampSeed -> Int) and
;;; reads a Swift-native CONSTANT (CreateML.MLCreateErrorDomain: String). Neither
;;; has a C symbol in CreateML.framework — both carry objc_exposed: false and are
;;; reachable only through libAPIAnywareGerbil's @_cdecl trampolines, bound here
;;; via define-c-lambda (the ADR-0017 idiom, the thing `gsc` structurally cannot
;;; do). A window showing their live values is unambiguous evidence the
;;; Swift-native path is bound.
;;;
;;; Per ADR-0015 the gerbil String coercion is Scheme-side: the constant
;;; trampoline returns an `id` (NSString) and (gerbil-bindings createml constants)
;;; coerces it with the existing aw-swift-string-result — no native string bridge.
;;;
;;; AppSpec instrumentation (gerbil-impl-k146): the k141 logging contract
;;; (apps/macos/swift-native-probe/docs/logging-contract.md). Beyond the shown
;;; values, each of the two shapes is checked against a known-good expected and
;;; emitted as a [probe] result to the events.log the runner tails, plus a
;;; [probe] complete all-ok summary (scenario 01's target-agnostic coverage
;;; assertion) and the lifecycle triad. Events emit INLINE (the drawing-canvas
;;; gerbil house style, k136; the racket sibling racket-impl-k144 uses a separate
;;; events.rkt, the chez sibling chez-impl-k145 emits inline like here). Under
;;; `launch-via 'open` LaunchServices discards stdout, so events.log — not
;;; stdout — is the runner's read path; the stdout echo below is kept for humans
;;; running the app unbundled.
;;;
;;; Mirrors targets/chez/app-implementations/macos/swift-native-probe/swift-native-probe.sls
;;; (and the racket original) one control at a time.
;;;
;;; Build the standalone bundle (compiles the whole closure + links + relocates
;;; libAPIAnywareGerbil into Contents/Frameworks) via build.sh; GUI testing uses
;;; TestAnyware (see README); never run the app from the CLI.
(import :gerbil-bindings/runtime/objc      ; make-delegate / define-entry-point (terminate hook)
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/nscolor
        :gerbil-bindings/appkit/enums
        ;; The Swift-native residual — trampolined through libAPIAnywareGerbil:
        :gerbil-bindings/createml/functions    ; timestampSeed (free function)
        :gerbil-bindings/createml/constants)   ; MLCreateErrorDomain (constant)
(export main)

;; ============================================================
;; Structured event log (logging contract)
;; ============================================================
;; The k141 logging contract (apps/macos/swift-native-probe/docs/
;; logging-contract.md): the hello-window lifecycle triad plus the [probe]
;; events that carry THIS app's coverage proof — one [probe] result per probed
;; shape (each an explicit ok-check vs a known-good expected) and a [probe]
;; complete summary whose all-ok=#t is the single target-agnostic coverage
;; assertion scenario 01 consumes:
;;   [lifecycle] startup                                        — readiness probe (`wait-ready`)
;;   [probe] result shape=<s> name="<sym>" ok=<#t|#f> value=<v> — once per probed shape
;;   [probe] complete count=<n> ok=<n> all-ok=<#t|#f>           — the coverage assertion (01)
;;   Swift-Native Probe opened.                                 — window key+front; BARE line
;;   [lifecycle] shutdown reason=<r>                            — terminate; reason ∈ {menu,signal,error}
;;
;; Events emit INLINE (no separate module) — the drawing-canvas gerbil house
;; style (gerbil-instrument-build-k136): the bundler's closure walk (deps.rs)
;; follows only `:gerbil-bindings/…` references, and these defines use only
;; Gambit primitives (open-output-file, getenv, create-directory, force-output,
;; write), so they ride the statically-linked prelude with no new import.
;;
;; Unlike drawing-canvas (whose events carry only bare integers) this app's
;; [probe] events carry STRING values — `name` always, and the constant shape's
;; value ("com.apple.CreateML") — so this section keeps a `snp-quote-string`
;; helper: Gambit `write` produces the contract's re-readable double-quoted form
;; (escaping "/\/newline), matching racket's/chez's ~s.
;;
;; Single writer: the probe computes on the main thread before the run loop, and
;; the only later writes are the launch line and the shutdown line (also main
;; thread) — one port with a post-write force-output suffices, no lock.

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails the
;; same file whether or not #:log-env (SWIFT_NATIVE_PROBE_EVENTS_LOG) propagates
;; through LaunchServices.
(define snp-default-events-path "/tmp/swift-native-probe/events.log")
(define snp-events-port #f)

;; SWIFT_NATIVE_PROBE_EVENTS_LOG if set and non-empty, else the fixed default.
(define (snp-resolve-events-path)
  (let ((env (getenv "SWIFT_NATIVE_PROBE_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env snp-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (snp-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in snp-emit-line, so a
;; tail sees each promptly.
(define (snp-events-init!)
  (let* ((target (snp-resolve-events-path))
         (parent (snp-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! snp-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (snp-emit-line line)
  (when snp-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line snp-events-port)
        (newline snp-events-port)
        (force-output snp-events-port)))))

;; Scheme-style boolean literal for the contract's ok/all-ok alphabet.
(define (snp-bool->hash b) (if b "#t" "#f"))

;; Re-readable double-quoted form (the contract's string-value alphabet): Gambit
;; `write` escapes "/\/newline. Used for `name` (always) and any string `value`.
(define (snp-quote-string s)
  (let ((port (open-output-string)))
    (write s port)
    (get-output-string port)))

(define (snp-emit-startup)
  (snp-emit-line "[lifecycle] startup"))

;; The §step-6 launch diagnostic — the bare (unbracketed) line the runner's
;; `wait-for-log` matches; dual-emitted (the stdout print stays in `main` for
;; unbundled runs). Identical wording across all four impls (the contract's
;; stable launch line).
(define (snp-emit-launch-line)
  (snp-emit-line "Swift-Native Probe opened."))

(define (snp-emit-shutdown reason)
  (snp-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; One coverage-set shape's result. SHAPE a bare symbol (function/constant/…),
;; NAME the probed symbol (emitted double-quoted), OK a boolean (#t/#f),
;; VALUE-REPR the ALREADY-rendered value string — the caller renders numbers
;; bare and strings quoted (only the call site knows each shape's live type),
;; per the contract's value semantics.
(define (snp-emit-probe-result shape name ok value-repr)
  (snp-emit-line (string-append "[probe] result"
                                " shape=" (symbol->string shape)
                                " name=" (snp-quote-string name)
                                " ok=" (snp-bool->hash ok)
                                " value=" value-repr)))

;; The coverage summary scenario 01 asserts. ALL-OK must be #t iff OK = COUNT.
(define (snp-emit-probe-complete count ok all-ok)
  (snp-emit-line (string-append "[probe] complete"
                                " count=" (number->string count)
                                " ok=" (number->string ok)
                                " all-ok=" (snp-bool->hash all-ok))))

(define (snp-close-events!)
  (when snp-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output snp-events-port)
        (close-output-port snp-events-port))))
  (set! snp-events-port #f))
;; --- End structured event log ----------------------------------------------

;; ============================================================
;; Application
;; ============================================================
(define-entry-point (main)
  ;; --- Probe each shape NOW (before any UI) so a binding failure surfaces
  ;;     loudly rather than as an empty window; each result is checked vs its
  ;;     known-good expected and emitted as a [probe] result, then the coverage
  ;;     summary (contract emission order: probe before UI). Do NOT abort on a
  ;;     failed probe — the window stays diagnostic. ---
  (let ((seed-value (timestampSeed))            ; shape 1: Swift-native Int via trampoline
        (error-domain MLCreateErrorDomain))     ; shape 2: Swift-native String constant

    ;; Per-shape ok-checks (contract "Known-good expecteds"):
    ;;   - timestampSeed is time-derived, never value-equality: the check is
    ;;     STRUCTURAL (an exact integer was returned — the binding produced a
    ;;     well-typed result). (integer?+exact? mirrors the chez sibling.)
    ;;   - MLCreateErrorDomain is the fixed domain string.
    (let* ((ok-fn    (and (integer? seed-value) (exact? seed-value)))
           (ok-const (and (string? error-domain)
                          (string=? error-domain "com.apple.CreateML")))
           (ok-count (+ (if ok-fn 1 0) (if ok-const 1 0))))
      (snp-emit-probe-result 'function "CreateML.timestampSeed"       ok-fn    (number->string seed-value))
      (snp-emit-probe-result 'constant "CreateML.MLCreateErrorDomain" ok-const (snp-quote-string error-domain))
      (snp-emit-probe-complete 2 ok-count (= ok-count 2)))

    ;; Human-friendly stdout echo (kept for unbundled runs; not the contract).
    (displayln (string-append "Swift-native CreateML.timestampSeed() = "
                              (number->string seed-value)))
    (displayln (string-append "Swift-native MLCreateErrorDomain = " error-domain))

    ;; --- Application setup ---
    ;; The app delegate's applicationWillTerminate: is the [lifecycle] shutdown
    ;; reason=menu hook the runner's graceful quit (quit-impl! / the Command-Q
    ;; scenario) routes through. make-delegate pins the synthesized instance in
    ;; *delegate-roots* for the process (AppKit holds the delegate weakly); this
    ;; let* keeps it lexically reachable too. The callback body is guarded
    ;; because an unhandled exception in an ObjC callback crashes the app with no
    ;; Scheme backtrace.
    (let* ((app (nsapplication-shared-application))
           (app-delegate
            (make-delegate
              (list (list "applicationWillTerminate:"
                          (lambda (notification)
                            (with-exception-catcher (lambda (e) #f)
                              (lambda ()
                                (snp-emit-shutdown 'menu)
                                (snp-close-events!))))
                          (list 'object) 'void)))))
      (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
      (install-standard-app-menu! app "Swift-Native Probe")
      (nsapplication-set-delegate! app app-delegate)

      ;; --- Window (560x240, centred) ---
      (let* ((window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                       (make-rect 0. 0. 560. 240.)
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

        (nswindow-set-title! window (string->nsstring "Swift-Native API Coverage"))
        (nswindow-center! window)

        ;; --- Heading ---
        (add-label! "Swift-native APIs via libAPIAnywareGerbil trampolines"
                    20. 190. 520. 28. 17. NSTextAlignmentCenter #f)

        ;; --- Function row: CreateML.timestampSeed() -> Int (Swift-native free function) ---
        (add-label! "CreateML.timestampSeed()"
                    30. 142. 280. 24. 15. NSTextAlignmentLeft #f)
        (add-label! (string-append "→ " (number->string seed-value))
                    310. 142. 220. 24. 15. NSTextAlignmentLeft
                    (nscolor-system-blue-color))

        ;; --- Constant row: CreateML.MLCreateErrorDomain: String (Swift-native constant) ---
        (add-label! "CreateML.MLCreateErrorDomain"
                    30. 106. 280. 24. 15. NSTextAlignmentLeft #f)
        (add-label! (string-append "→ " error-domain)
                    310. 106. 220. 24. 15. NSTextAlignmentLeft
                    (nscolor-system-blue-color))

        ;; --- Footer ---
        (add-label! "Neither symbol exists as a C symbol in CreateML.framework —"
                    20. 52. 520. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))
        (add-label! "both are Swift-native (objc_exposed: false), reached only via @_cdecl trampolines."
                    20. 32. 520. 20. 12. NSTextAlignmentCenter (nscolor-secondary-label-color))

        ;; --- Show window and run ---
        (nswindow-make-key-and-order-front window #f)
        (nsapplication-activate-ignoring-other-apps app #t)

        ;; §step-6 launch diagnostic — dual emission (logging contract): keep the
        ;; human-friendly stdout line AND write the same bare line to events.log
        ;; (LaunchServices discards stdout under `open`). Emitted UNCONDITIONALLY
        ;; so the headless smoke below sees it.
        (displayln "Swift-Native Probe opened. Close the window or press Ctrl+C to exit.")
        (snp-emit-launch-line)

        ;; AW_PROBE_SMOKE is the host construction pre-flight: the whole probe +
        ;; full k141 contract has now been emitted and the window built +
        ;; ordered-front, so exit WITHOUT the run loop — the window is never
        ;; serviced/composited (no event loop) so no GUI grabs the host. This
        ;; CLI-smokes the [probe] vocabulary before the VM round-trip; the live
        ;; GUI verify is forward-gen-live-run's ([[use_testanyware]] — never run
        ;; the GUI from the CLI).
        (unless (getenv "AW_PROBE_SMOKE" #f)
          (nsapplication-run app))))))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; startup must land before the AppKit run loop (or the runner's `wait-ready`
;; readiness probe times out). The probe computes and emits its [probe] results
;; inside `main` before building the UI (contract emission order).
(snp-events-init!)
(snp-emit-startup)

;; Test-config compatibility (logging-contract.md): the probe reads no runtime
;; config — its coverage set is fixed — so it honours SWIFT_NATIVE_PROBE_TEST_CONFIG
;; by reading the env var and treating absent/empty (and a missing file) as "no
;; config" — a deliberate no-op.
(getenv "SWIFT_NATIVE_PROBE_TEST_CONFIG" #f)

(main)
