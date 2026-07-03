;;;; swift-native-probe.lisp — the §6d-invariant exemplar app (sbcl target, 060 ladder).
;;;;
;;;; A verification PROBE, not a portfolio app: it proves the complete-API Swift-native
;;;; **trampoline** lower layer (ADR-0038 / the racket spec §6d, ported to sbcl) works
;;;; end-to-end in a *loaded, dumped* GUI app — the project done-bar the in-process 050
;;;; integration smoke (`lib/runtime/tests/smoke-integration.lisp`, GATE D) does not
;;;; satisfy. It is the sbcl analogue of racket/chez/gerbil's swift-native-probe (whose
;;;; function/constant slice it merges with the method/init slice, since sbcl's design
;;;; defers the value-STRUCT-owner shape to 090 and the async-method shape by design).
;;;;
;;;; Every symbol it shows carries `objc_exposed: false` and has NO C symbol in its
;;;; framework — each is reachable only through `libAPIAnywareSbcl`'s `aw_sbcl_swift_*`
;;;; `@_cdecl` trampolines, bound by typed `sb-alien` (ADR-0015/0038). Rendering their
;;;; live values is unambiguous evidence the Swift-native path is bound. Five shapes
;;;; (the four 045/050 wired, each a labelled row):
;;;;
;;;;   1. FUNCTION       CoreGraphics.hypot(3,4) -> 5.0        (Swift math-overlay free fn)
;;;;   2. CONSTANT       Foundation.NSNotFound  -> NSIntegerMax (Swift-native Int global)
;;;;   3. CLASS-OWNER    NSNumber(integerLiteral: 42)          (Swift-native init -> a real
;;;;        INIT          -> intValue 42                         wrapped ns:ns-number)
;;;;   4. CLASS-OWNER    Scanner("APIAnyware:SBCL")            (Swift-native receiver-handle
;;;;        METHOD        .scanUpToString(":") -> "APIAnyware"   method on a real class)
;;;;   5. VALUE-OPAQUE   IndexSet(5) -> insert(7) round-trip   (a non-class Swift value
;;;;        BOX           via opaque AwSbclValueBox handles      crosses as a raw box handle)
;;;;
;;;; Unlike hello-window (pure ObjC, `:load-residual nil`), this app DEPENDS on the dylib:
;;;; the run/build harness loads `libAPIAnywareSbcl` (`aw-load-native-dylib`) and the
;;;; generated residual (`:load-residual t`). It is the FIRST ladder app to dump+revive
;;;; WITH the dylib (the §6d residual surviving `save-lisp-and-die`, ADR-0038 §5).
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like hello-window). The portable
;;;; Cocoa surface it names is `ns:`. Shape 4 now uses the NATURAL construct path —
;;;; `(make-instance 'ns:ns-scanner :init-with-string @"…")` — since the k38 fix keys
;;;; ObjC-bridged classes on their ObjC *runtime* name (not the Swift-overlay name), so the
;;;; unified `ns:ns-scanner` is registered as the live "NSScanner" and carries both the ObjC
;;;; `initWithString:` init and the Swift-native `ns:scan-up-to-string` method; the earlier
;;;; `:ptr` workaround over a Swift-overlay-named `ns:scanner` is gone (see learnings). One
;;;; probe-only deviation remains, inherent to a lower-layer probe (not app code):
;;;;   - shape 5 hand-binds three IndexSet trampolines as OPAQUE-handle functions (the
;;;;     value-opaque shape — no CLOS class), since the value-STRUCT-owner CLOS modelling is
;;;;     the parked 090 leaf; this mirrors the 050 smoke's D5 (hand-bound makePair/pair-sum).

(in-package #:apianyware-sbcl-impl)

;;; --- Shape 3 helper: read an NSNumber's integer value via plain ObjC (proves the
;;;     Swift-native init produced a REAL, usable NSNumber). ---
(defun probe-nsnumber-int-value (n)
  (sb-alien:alien-funcall
   (sb-alien:sap-alien +objc-msgsend+
     (sb-alien:function (sb-alien:signed 32) sb-alien:system-area-pointer sb-alien:system-area-pointer))
   (aw-ptr n) (aw-sel "intValue")))

;;; --- Shape 5 helpers: IndexSet (a Swift value struct) reached as OPAQUE box handles.
;;;     Hand-bound (not generated): the generated bindings model value structs as CLOS
;;;     classes only once 090 lands; here each trampoline is a plain function taking/
;;;     returning a raw AwSbclValueBox SAP — the value-OPAQUE shape (050 smoke D5). The
;;;     box is freed with the one uniform `aw-box-free`. ---
(defun probe-indexset-make (n)
  "IndexSet(integer: N) -> a +1 AwSbclValueBox handle (raw SAP)."
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_init_Foundation_IndexSet_15866e27"
                          (sb-alien:function sb-alien:system-area-pointer (sb-alien:signed 64)))
   n))
(defun probe-indexset-contains (box n)
  "IndexSet.contains(N) on the boxed receiver -> boolean."
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_m_Foundation_IndexSet_contains_077304da"
                          (sb-alien:function (sb-alien:boolean 8) sb-alien:system-area-pointer (sb-alien:signed 64)))
   box n))
(defun probe-indexset-insert (box n)
  "IndexSet.insert(N): mutates the boxed receiver in place; returns the insert-result box."
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_m_Foundation_IndexSet_insert_27a24baa"
                          (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer (sb-alien:signed 64)))
   box n))

(defun probe-indexset-roundtrip ()
  "init(5) -> contains(7)=NIL -> insert(7) -> contains(7)=T -> contains(5)=T, all on ONE
   opaque box handle, then freed. Returns a human string + the booleans."
  (let* ((box (probe-indexset-make 5))
         (before (probe-indexset-contains box 7))
         (ins (probe-indexset-insert box 7))
         (after (probe-indexset-contains box 7))
         (still5 (probe-indexset-contains box 5)))
    (aw-box-free ins)
    (aw-box-free box)
    (values (format nil "init(5)+insert(7): contains 7 = ~:[NO~;YES~] (was ~:[NO~;YES~]), contains 5 = ~:[NO~;YES~]"
                    after before still5)
            (and after (not before) still5))))

;;; --- Shape 4 helper: build an NSScanner via the NATURAL construct path. Since the k38
;;;     fix keys ObjC-bridged classes on their ObjC runtime name (not the Swift-overlay
;;;     name), the unified `ns:ns-scanner` is registered as the live "NSScanner" and carries
;;;     BOTH the ObjC `initWithString:` init and the Swift-native receiver-handle method
;;;     `ns:scan-up-to-string` — so a plain `make-instance` (routing through the generated
;;;     init, exactly like `ns:ns-url-request :init-with-url`) reaches it, no `:ptr`
;;;     workaround. A live `NSScanner` likewise auto-wraps to `ns:ns-scanner` now. ---
(defun probe-make-scanner ()
  (make-instance 'ns:ns-scanner :init-with-string @"APIAnyware:SBCL"))

;;; --- The standard app menu (Quit -> -[NSApplication terminate:]), as hello-window. ---
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

;;; --- Terminate delegate (logging contract: [lifecycle] shutdown reason=menu) ---------
;;; `applicationWillTerminate:` is the only hook that fires on the menu/Cmd-Q quit path:
;;; -[NSApplication terminate:] ends in a C exit(), which bypasses sb-ext:*exit-hooks*, so an
;;; AppKit-level delegate callback is the reliable shutdown signal. The subclass is synthesized
;;; at RUNTIME (not load) so it registers in the process that shows the UI — a class synthesized
;;; during `save-lisp-and-die` does NOT survive into the revived image (fresh ObjC runtime).
;;; `*snp-delegate-ready*` stays nil through the dump (dump.lisp never calls -main) and
;;; re-synthesizes at revive. The hello-window `ensure-hw-delegate` / drawing-canvas k137
;;; pattern; the dylib's subclass bounce shim (already loaded for the trampoline residual)
;;; self-registers on this first `define-objc-method`.
(defvar *snp-delegate-ready* nil
  "nil until `ensure-snp-delegate` has synthesized the delegate class in THIS process. A
   revived image starts nil again and re-synthesizes.")

(defun ensure-snp-delegate ()
  "Define the `snp-app-delegate` ObjC subclass + its `applicationWillTerminate:` method.
   Idempotent within a process via `*snp-delegate-ready*`."
  (unless *snp-delegate-ready*
    (define-objc-subclass snp-app-delegate (ns:ns-object))   ; no slots — pure callback target
    (define-objc-method (snp-app-delegate "applicationWillTerminate:") (self notification)
      (declare (ignore self notification))
      (handler-case
          (progn (snp-events:emit-shutdown 'menu) (snp-events:close-events!))
        (error (e)
          (format *error-output* "applicationWillTerminate delegate error: ~A~%" e)
          (finish-output *error-output*))))
    (setf *snp-delegate-ready* t)))

;;; NSIntegerMax on the LP64 platform (2^63 - 1) — the known-good expected NSNotFound equals.
(defparameter +ns-integer-max+ (1- (expt 2 63)))

(defun swift-native-probe-main (&key (run t))
  "Build the probe UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT: it calls EVERY Swift-native trampoline the
   app shows (plus the generated value-opaque RETURN binding `ns:lgamma` and the free fn
   `ns:pow`, as extra generated-path checks), EMITS the full k141 logging contract to the
   events.log (so a bare `sbcl --load` CLI-smokes the [probe] vocabulary), and builds the
   whole UI, then returns WITHOUT blocking on `-run` — validating the residual marshalling +
   the window construction before the VM round-trip. The dumped image's toplevel calls RUN t.
   Emission is NOT gated on RUN (unlike hello-window) precisely so the CLI-smoke sees the log;
   only the run loop + its stdout 'opened' echo are RUN-gated."
  (ensure-snp-delegate)
  ;; --- Application setup ---
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Swift Native Probe")

    ;; --- Structured event log: open + [lifecycle] startup BEFORE probing ---
    ;; `startup` must precede everything downstream (the runner's `wait-ready` readiness
    ;; probe). Test-config compatibility (logging-contract.md): the probe reads no runtime
    ;; config, so it honours SWIFT_NATIVE_PROBE_TEST_CONFIG by reading the env var and
    ;; treating absent/empty as "no config" — a deliberate no-op.
    (snp-events:events-init!)
    (snp-events:emit-startup)
    (sb-ext:posix-getenv "SWIFT_NATIVE_PROBE_TEST_CONFIG")

    ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
    ;; Installed unconditionally so the pre-flight / revive smoke exercises the subclass bounce
    ;; shim + set-delegate. Pinned in *subclass-instances* (a STRONG table), so Cocoa's weak
    ;; delegate reference never reaps it.
    (ns:set-delegate_ app (make-instance 'snp-app-delegate))

    ;; --- Probe each shape NOW (before any UI) so a binding failure surfaces loudly rather
    ;;     than as a blank row; each result is checked vs its known-good expected and emitted
    ;;     as a [probe] result, then the coverage summary. Do NOT abort on a failed probe —
    ;;     the window stays diagnostic (a failed row is visible on screen). ---
    (let* ((fn-result    (ns:hypot 3.0d0 4.0d0))                     ; shape 1: free function
           (const-result ns:ns-not-found)                            ; shape 2: constant
           (num          (ns:make-ns-number-integer-literal 42))     ; shape 3: class-owner init
           (num-result   (probe-nsnumber-int-value num))
           (scanner      (probe-make-scanner))                       ; shape 4: class-owner method
           (scan-result  (ns:scan-up-to-string scanner ":")))
      (multiple-value-bind (iset-str iset-ok) (probe-indexset-roundtrip)  ; shape 5: value box
        ;; Extra generated-path sanity (not GUI rows, not probe events): the generated
        ;; value-opaque RETURN binding (lgamma -> box, freed) and a second free fn (pow).
        (let ((lgamma-box (ns:lgamma 5.0d0)))
          (aw-box-free lgamma-box))
        (ns:pow 2.0d0 10.0d0)

        ;; --- Per-shape ok-checks (contract "Known-good expecteds") ---
        (let ((ok-fn     (= fn-result 5.0d0))
              (ok-const  (= const-result +ns-integer-max+))
              (ok-init   (= num-result 42))
              (ok-method (and (stringp scan-result) (string= scan-result "APIAnyware"))))
          (snp-events:emit-probe-result
           'function  "CoreGraphics.hypot"        ok-fn     (format nil "~a" fn-result))
          (snp-events:emit-probe-result
           'constant  "Foundation.NSNotFound"     ok-const  (format nil "~d" const-result))
          (snp-events:emit-probe-result
           'init      "NSNumber.integerLiteral"   ok-init   (format nil "~d" num-result))
          (snp-events:emit-probe-result
           'method    "NSScanner.scanUpToString"  ok-method (format nil "~s" scan-result))
          (snp-events:emit-probe-result
           'value-box "Foundation.IndexSet.roundtrip" iset-ok (format nil "~s" iset-str))
          (let* ((oks (list ok-fn ok-const ok-init ok-method iset-ok))
                 (ok-count (count-if #'identity oks)))
            (snp-events:emit-probe-complete 5 ok-count (= ok-count 5))))

        (format t "~&Swift-native results (all via libAPIAnywareSbcl trampolines):~%")
        (format t "  1 function  hypot(3,4)             = ~A~%" fn-result)
        (format t "  2 constant  NSNotFound             = ~D~%" const-result)
        (format t "  3 init      NSNumber(42).intValue  = ~D~%" num-result)
        (format t "  4 method    Scanner.scanUpToString = ~S~%" scan-result)
        (format t "  5 value-box ~A~%" iset-str)
        (finish-output)

        ;; --- Window (640x300, centred) ---
        (aw-with-rect (frame 0 0 640 300)
        (let* ((window (make-instance 'ns:ns-window
                         :init-with-content-rect frame
                         :style-mask (logior ns:ns-window-style-mask-titled
                                             ns:ns-window-style-mask-closable
                                             ns:ns-window-style-mask-miniaturizable)
                         :backing ns:ns-backing-store-buffered
                         :defer nil))
               (content (ns:content-view window))
               (blue (ns:system-blue-color (find-class 'ns:ns-color)))
               (gray (ns:secondary-label-color (find-class 'ns:ns-color))))
          (ns:set-title_ window @"Swift-Native API Coverage")
          (ns:center window)

          ;; A non-editable label at FRAME, added to this window's content view.
          (flet ((lbl (text x y w h size align &optional color)
                   (let ((field (make-instance 'ns:ns-text-field)))
                     (aw-with-rect (r x y w h) (ns:set-frame_ field r))
                     (ns:set-string-value_ field (aw-wrap (aw-make-nsstring text) t))
                     (ns:set-font_ field (ns:system-font-of-size_ (find-class 'ns:ns-font)
                                                                  (coerce size 'double-float)))
                     (ns:set-alignment_ field align)
                     (ns:set-editable_ field nil)
                     (ns:set-selectable_ field nil)
                     (ns:set-bezeled_ field nil)
                     (ns:set-draws-background_ field nil)
                     (when color (ns:set-text-color_ field color))
                     (ns:add-subview_ content field)
                     field)))
            ;; --- Heading ---
            (lbl "Swift-native APIs via libAPIAnywareSbcl trampolines"
                 20 258 600 26 16 ns:ns-text-alignment-center)
            ;; --- Four shape rows: name (left) -> live value (right, blue) ---
            (flet ((row (y name value)
                     (lbl name  30 y 360 22 14 ns:ns-text-alignment-left)
                     (lbl value 396 y 224 22 14 ns:ns-text-alignment-left blue)))
              (row 216 "1  function  hypot(3, 4)"            (format nil "→ ~A" fn-result))
              (row 184 "2  constant  NSNotFound"             (format nil "→ ~D" const-result))
              (row 152 "3  class-owner init  NSNumber(42)"   (format nil "→ intValue ~D" num-result))
              (row 120 "4  class-owner method  Scanner"      (format nil "→ ~S" scan-result)))
            ;; --- Shape 5 spans the full width (longer round-trip text) ---
            (lbl "5  value-opaque box  IndexSet" 30 88 360 22 14 ns:ns-text-alignment-left)
            (lbl (format nil "→ ~A" iset-str) 48 66 572 22 13 ns:ns-text-alignment-left blue)
            ;; --- Footer ---
            (lbl "Each symbol is Swift-native (objc_exposed: false) — no C symbol exists;"
                 20 36 600 18 11 ns:ns-text-alignment-center gray)
            (lbl "all reached only via libAPIAnywareSbcl @_cdecl trampolines (what the FFI alone cannot do)."
                 20 18 600 18 11 ns:ns-text-alignment-center gray))

          ;; --- Show + run ---
          (ns:make-key-and-order-front_ window nil)
          (ns:activate-ignoring-other-apps_ app t)
          ;; Launch diagnostic: the bare line the runner's `wait-for-log` matches in
          ;; events.log — emitted unconditionally so the CLI-smoke (:run nil) sees it — plus
          ;; the human-friendly stdout line (RUN-gated; kept for unbundled runs, since
          ;; LaunchServices discards stdout under `open`). Dual emission.
          (snp-events:emit-launch-line)
          (when run
            (format t "~&Swift-Native Probe opened. Quit with Cmd-Q.~%")
            (finish-output)
            (ns:run app))))))))
