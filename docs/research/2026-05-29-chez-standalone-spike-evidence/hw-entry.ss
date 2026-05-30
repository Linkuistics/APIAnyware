;; hw-entry.ss — hello-window entry for the standalone spike.
;; Identical imports + (main) body as apps/hello-window/hello-window.sls,
;; but ends by installing (scheme-start) rather than calling (main) at top
;; level, so the embedding host (embed_main.c) drives the entry.
;; SPIKE FINDING (2026-05-29): as a strict R6RS top-level program (what
;; compile-program/compile-whole-program require), exactly 4 identifiers
;; are exported by more than one of these import sets — a hard
;; duplicate-import error. The source-exec/`--script` path tolerates them
;; (interaction env rebinds, last-wins); whole-program does not. Resolved
;; by having the framework facades yield to the curated runtime API and to
;; (chezscheme):
;;   nserror-code, nserror-domain    : foundation facade vs runtime objc record
;;   reverse                         : foundation (re-exported enum) vs (chezscheme)
;;   nsevent-location-in-window      : appkit (NSEvent accessor) vs runtime cocoa
;; hello-window uses the runtime/(chezscheme) side of all four. See spike report.
(import (chezscheme)
        (except (apianyware appkit) nsevent-location-in-window)
        (except (apianyware foundation) nserror-code nserror-domain reverse)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types))

(define-entry-point (main)
  (let ([app (nsapplication-shared-application)])
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)

    ;; Standard macOS app menu (About / Hide / Quit). The bold app-name
    ;; slot in the menu bar comes from CFBundleName when launched as a
    ;; .app bundle (see bundle-chez); unbundled it reads "chez".
    (install-standard-app-menu! app "Hello Window")

    ;; --- Create window (400x200, centred) ---
    (let ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                    (make-nsrect 0 0 400 200)
                    (bitwise-ior NSWindowStyleMaskTitled
                                 NSWindowStyleMaskClosable
                                 NSWindowStyleMaskMiniaturizable)
                    NSBackingStoreBuffered
                    #f)])
      (nswindow-set-title! window "Hello from Chez")
      (nswindow-center! window)

      ;; --- Create label (centred in window) ---
      (let ([label (make-nstextfield-init-with-frame
                     (make-nsrect 0 70 400 60))])
        (nstextfield-set-string-value! label "Hello, macOS!")
        (nstextfield-set-font! label (nsfont-system-font-of-size 24.0))
        (nstextfield-set-alignment! label NSTextAlignmentCenter)
        (nstextfield-set-editable! label #f)
        (nstextfield-set-selectable! label #f)
        (nstextfield-set-bezeled! label #f)
        (nstextfield-set-draws-background! label #f)

        (nsview-add-subview! (nswindow-content-view window) label))

      ;; --- Show window and run ---
      (nswindow-make-key-and-order-front window #f)
      (nsapplication-activate-ignoring-other-apps app #t)

      (display "Hello Window opened. Close the window or press Ctrl+C to exit.\n")
      (nsapplication-run app))))

;; --- Synthetic dynamic-load proof (BRIEF D2 / requirement 1) ----------
;; hello-window itself loads nothing, so this is added scaffolding. Runs
;; only when AW_SPIKE_PROVE is set, prints a transcript, and exits WITHOUT
;; entering the run loop (pure console — no GUI). In the OPEN-world binary
;; every step should pass (compiler present). In the CLOSED-world binary
;; the eval/foreign-callable steps must FAIL (no compiler) — that failure
;; IS the closed-world contract, captured as proof.
(define (try label thunk)
  (call/cc
    (lambda (k)
      (with-exception-handler
        (lambda (e)
          (printf "  [~a] REFUSED/ERROR: ~a\n" label
                  (call-with-string-output-port (lambda (p) (display-condition e p))))
          (k #f))
        (lambda () (printf "  [~a] ~a\n" label (thunk)))))))

(define (prove-dynamic-load)
  (display "=== DYNAMIC-LOAD PROOF ===\n")
  (printf "boot kind: ~a\n" (scheme-version))
  ;; 1. eval a fresh form not seen at link time
  (try "eval fresh form (sum 0..100), expect 5050"
       (lambda ()
         (eval '(let loop ([n 0] [acc 0])
                  (if (> n 100) acc (loop (+ n 1) (+ acc n))))
               (interaction-environment))))
  ;; 2. read+eval a fresh definition from a string, then call it
  (try "load fresh def from string; (spike-dyn 7), expect 49"
       (lambda ()
         (eval (read (open-input-string "(define (spike-dyn x) (* x x))"))
               (interaction-environment))
         (eval '(spike-dyn 7) (interaction-environment))))
  ;; 3. build a foreign-callable via runtime eval (the dispatch.sls
  ;;    mechanism) and call it round-trip, expect 42
  (try "foreign-callable via eval, round-trip call(41), expect 42"
       (lambda ()
         (let ([cb (eval '(foreign-callable (lambda (x) (+ x 1)) (int) int)
                         (interaction-environment))])
           (lock-object cb)
           (let* ([ep (foreign-callable-entry-point cb)]
                  [f  (foreign-procedure ep (int) int)]
                  [r  (f 41)])
             (unlock-object cb)
             r))))
  ;; 4. guardian drain under the embedded kernel (independent of objc):
  ;;    register an object, drop the strong ref, gc, confirm it surfaces.
  (try "Chez guardian drains after gc, expect 'drained"
       (lambda ()
         (let ([g (make-guardian)])
           (g (cons 'x 'y))           ; register; no other ref kept
           (collect (collect-maximum-generation))
           (if (g) 'drained 'NOT-DRAINED))))
  (display "=== PROOF COMPLETE ===\n")
  (flush-output-port (current-output-port)))

(scheme-start
  (lambda args
    (if (getenv "AW_SPIKE_PROVE")
        (prove-dynamic-load)        ; console proof, no window
        (main))                     ; normal: open window + run loop
    0))
