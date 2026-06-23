;;;; tests/smoke-integration.lisp — leaf 050/080, the 050 NODE DONE-BAR.
;;;;
;;;; Run from the repo root (after `swift build` has built libAPIAnywareSbcl):
;;;;   SDKROOT=macosx sbcl --non-interactive --disable-debugger \
;;;;        --load generation/targets/sbcl/lib/runtime/tests/smoke-integration.lisp
;;;;   (or: generation/targets/sbcl/lib/runtime/tests/run-integration-smoke.sh)
;;;;
;;;; NOT a unit smoke (each 050 leaf has its own). This is the INTEGRATION gate the node
;;;; BRIEF's "Done when (node)" names: the WHOLE 050 stack — the sb-alien seam, the MOP
;;;; object model, subclass synthesis, lifetime, conditions, threading/callbacks, the
;;;; startup pass, AND the native dylib — composed together, proven end-to-end against a
;;;; REAL framework, with the EMITTED bindings (040) loaded on top. Five gates:
;;;;
;;;;   GATE A — the emitter's ACTUAL output (the committed TestKit goldens) LOADS on the
;;;;            runtime: package model, metaclass-backed classes, the defgeneric/defmethod
;;;;            lockstep, the register-objc-{class,init,protocol} baked tables. (The first
;;;;            thing in the grove to load emitted output on the runtime — it surfaced the
;;;;            geometry-struct + define-objc-constant + baked-table-quoting fixes below.)
;;;;   GATE B — the four MOP operations against LIVE Foundation: instantiate (alloc/init +
;;;;            an explicit-init), dispatch (chain + call-next-method + class method),
;;;;            subclass (define-objc-subclass + override driven by a framework callback),
;;;;            callback (a block from a FOREIGN thread bounces to main, ADR-0035).
;;;;   GATE C — background-release (ADR-0036): a +1 wrap finalized OFF-main enqueues; the
;;;;            main-thread pool drain releases it exactly once.
;;;;   GATE D — the §6d Swift-native residual resolves BY SHAPE (a first-class outcome,
;;;;            equal to the ObjC/MOP work): a Swift-native function / constant / class-owner
;;;;            method / class-owner init / value-opaque box / value-STRUCT owner
;;;;            (ADR-0042 CLOS class + defmethod + box-wrapping constructor) /
;;;;            `throws`→`ns:cocoa-error` each links + calls through libAPIAnywareSbcl (+ the
;;;;            committed fixture dylib standing in for the gitignored
;;;;            Generated/Trampolines.swift). Shapes that need a still-open leaf
;;;;            (async-method trampoline → a deferred follow-up) are RECORDED PENDING,
;;;;            never silently skipped.
;;;;
;;;; Self-contained: compiles its own C foreign-thread harness (clang, peer
;;;; smoke-threading-callbacks.c) + the Swift residual fixture (swiftc) at run time, so a
;;;; bare `sbcl --load` after `swift build` is the whole story.

(in-package #:cl-user)
(defparameter *here* (or *load-truename* *load-pathname*))
(defparameter *repo-root*
  (let ((d (make-pathname :directory (pathname-directory *here*))))
    (dotimes (_ 6 d) (setf d (make-pathname :directory (butlast (pathname-directory d)))))))
(load (merge-pathnames "generation/targets/sbcl/lib/runtime/load.lisp" *repo-root*))

(in-package #:apianyware-sbcl-impl)

(defvar *fails* 0)
(defvar *pending* '())
(defmacro check (form expected)
  `(let ((got ,form))
     (if (equal got ,expected)
         (format t "### ok    ~S => ~S~%" ',form got)
         (progn (incf *fails*) (format t "### FAIL  ~S => ~S (expected ~S)~%" ',form got ,expected)))))
(defun record-pending (shape why)
  (push (cons shape why) *pending*)
  (format t "### PENDING ~A — ~A~%" shape why))

(defun repo (rel) (namestring (merge-pathnames rel cl-user::*repo-root*)))

;;; ===========================================================================
;;; Setup — Foundation + the native dylib + the Swift residual fixture + a C
;;; foreign-thread harness. The dylib must be `swift build`-fresh (run-integration-
;;; smoke.sh ensures it); the fixture + harness are compiled here.
;;; ===========================================================================

(aw-load-framework "Foundation")

(defparameter *build-dir* (repo "swift/.build/arm64-apple-macosx/debug"))
(defparameter *main-dylib* (format nil "~A/libAPIAnywareSbcl.dylib" *build-dir*))
(unless (probe-file *main-dylib*)
  (format t "### FATAL: ~A not built — run `swift build` (or run-integration-smoke.sh).~%" *main-dylib*)
  (sb-ext:exit :code 2))
(setf *native-dylib-path* *main-dylib*)
(aw-load-native-dylib)
(aw-init-subclass-dispatcher)
(aw-init-block-dispatcher)

(defun sdk-path ()
  (let ((s (make-string-output-stream)))
    (sb-ext:run-program "xcrun" '("--show-sdk-path" "--sdk" "macosx") :search t :output s)
    (string-right-trim '(#\Newline) (get-output-stream-string s))))

;; Compile the Swift residual fixture into a dylib next to the main one (so the
;; @rpath/libAPIAnywareSbcl.dylib link resolves) — the committed stand-in for the
;; gitignored Generated/Trampolines.swift (see swift-residual-fixture.swift).
(defparameter *fixture-dylib* "/tmp/libAwResidualFixture.dylib")
(let ((p (sb-ext:run-program
          "swiftc"
          (list "-emit-library" "-target" "arm64-apple-macosx26.0"
                "-sdk" (sdk-path)
                "-I" (format nil "~A/Modules" *build-dir*)
                "-L" *build-dir* "-lAPIAnywareSbcl"
                "-Xlinker" "-rpath" "-Xlinker" *build-dir*
                "-o" *fixture-dylib*
                (repo "generation/targets/sbcl/lib/runtime/tests/swift-residual-fixture.swift"))
          :search t :error *error-output*)))
  (unless (zerop (sb-ext:process-exit-code p))
    (format t "### FATAL: swiftc could not build the residual fixture~%")
    (sb-ext:exit :code 2)))
(sb-alien:load-shared-object *fixture-dylib*)

;; Compile the C foreign-thread storm harness (clang -fblocks, peer smoke-threading-
;; callbacks.c) for the GATE B callback op.
(defparameter *harness-dylib* "/tmp/libsbclintegsmoke.dylib")
(let ((p (sb-ext:run-program
          "clang" (list "-fblocks" "-dynamiclib" "-O2" "-framework" "CoreFoundation"
                        "-o" *harness-dylib*
                        (repo "generation/targets/sbcl/lib/runtime/tests/smoke-threading-callbacks.c"))
          :search t :error *error-output*)))
  (unless (zerop (sb-ext:process-exit-code p))
    (format t "### FATAL: clang could not build the C harness~%")
    (sb-ext:exit :code 2)))
(sb-alien:load-shared-object *harness-dylib*)
(sb-alien:define-alien-routine ("aw_sbcl_smoke_block_storm" smoke-block-storm)
    sb-alien:long (block sb-alien:system-area-pointer) (outer sb-alien:long) (inner sb-alien:long))
(sb-alien:define-alien-routine ("aw_sbcl_smoke_is_main" smoke-is-main) sb-alien:int)

;; A tiny raw-msgSend helper for the smoke's own framework setup calls.
(defun send0 (recv sel) (%msgsend-id-0 recv (aw-sel sel)))
(defun send1 (recv sel arg) (%msgsend-id-1 recv (aw-sel sel) arg))

;;; ===========================================================================
;;; GATE A — the emitter's ACTUAL output (committed TestKit goldens) loads on the
;;; runtime. Loads the structural tree (facade → generics → classes superclass-first →
;;; protocols → enums); the synthetic plain-C `constants.lisp`/`functions.lisp` bind
;;; TestKit.framework C symbols that exist only in a real build, so they are out of this
;;; LOAD gate (their forms are paren/lockstep-checked by emit-sbcl/tests; define-objc-
;;; constant + the residual fn binding are proven for real in GATE D).
;;; ===========================================================================
(format t "~%========== GATE A — emitted tree loads on the runtime ==========~%")
(defparameter *golden* (repo "generation/crates/emit-sbcl/tests/golden/testkit/"))
(handler-bind ((warning #'muffle-warning))
  (load (repo "generation/crates/emit-sbcl/tests/golden/testkit.lisp"))
  (dolist (f '("generics.lisp" "tkobject.lisp" "tkview.lisp" "tkbutton.lisp"
               "tkhelper.lisp" "tkmanager.lisp" "protocols.lisp" "enums.lisp"))
    (load (merge-pathnames f *golden*))))

;; the metaclass projection is real over the emitted graph
(check (typep (find-class 'ns:tk-button) 'objc-class) t)
(check (and (subtypep 'ns:tk-button 'ns:tk-view)
            (subtypep 'ns:tk-view 'ns:tk-object)
            (subtypep 'ns:tk-object 'ns:ns-object)) t)
;; the baked tables populated (register-objc-class / -init / -protocol — the macro fix)
(check (and (gethash "TKButton" *objc-class-registry*) t) t)
(check (and (gethash (find-class 'ns:tk-view) *objc-init-registry*) t) t)   ; initWithFrame:
(check (getf (gethash "TKCopying" *objc-protocol-registry*) :required)
       '(("copyWithZone:" ns:copy-with-zone_)))
;; the lockstep: a per-class defmethod's generic was declared in generics/protocols
(check (and (fboundp 'ns:frame) (fboundp 'ns:label) (fboundp 'ns:copy-with-zone_) t) t)
;; a geometry-returning method LOADED (the ns-rect typedef this leaf added) — `ns:frame`
(check (and (find-method #'ns:frame '() (list (find-class 'ns:tk-view)) nil) t) t)

;;; ===========================================================================
;;; GATE B — the four MOP operations against LIVE Foundation. A hand-authored slice in
;;; the emitter's EXACT output shape (cross-checked against the goldens), composed on the
;;; full runtime + dylib (not the isolated per-leaf smoke runtime).
;;; ===========================================================================
(format t "~%========== GATE B — four MOP operations vs live Foundation ==========~%")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("NS-STRING" "NS-ARRAY" "NS-MUTABLE-ARRAY" "NS-NUMBER"
               "LENGTH" "COUNT" "OBJECT-AT-INDEX_" "ADD-OBJECT_" "INT-VALUE"
               "NUMBER-WITH-INT_" "TAGGED-COUNT"))
    (export (intern n '#:ns) '#:ns)))
(defclass ns:ns-string (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-string "NSString" "NSObject")
(register-objc-init 'ns:ns-string "initWithString:" (:string))       ; explicit-init (macro)
(defclass ns:ns-array (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-array "NSArray" "NSObject")
(defclass ns:ns-mutable-array (ns:ns-array) () (:metaclass objc-class))
(register-objc-class 'ns:ns-mutable-array "NSMutableArray" "NSArray")
(defclass ns:ns-number (ns:ns-object) () (:metaclass objc-class))
(register-objc-class 'ns:ns-number "NSNumber" "NSObject")

(defgeneric ns:length (r))
(defmethod ns:length ((self ns:ns-string))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:unsigned-long sb-alien:system-area-pointer sb-alien:system-area-pointer))
    (aw-ptr self) (aw-sel "length")))
(defgeneric ns:count (r))
(defmethod ns:count ((self ns:ns-array))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:unsigned-long sb-alien:system-area-pointer sb-alien:system-area-pointer))
    (aw-ptr self) (aw-sel "count")))
(defgeneric ns:object-at-index_ (r i))
(defmethod ns:object-at-index_ ((self ns:ns-array) i)
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer sb-alien:unsigned-long))
    (aw-ptr self) (aw-sel "objectAtIndex:") i)))
(defgeneric ns:add-object_ (r o))
(defmethod ns:add-object_ ((self ns:ns-mutable-array) o)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer))
    (aw-ptr self) (aw-sel "addObject:") (aw-ptr o)))
(defgeneric ns:int-value (r))
(defmethod ns:int-value ((self ns:ns-number))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function (sb-alien:signed 32) sb-alien:system-area-pointer sb-alien:system-area-pointer))
    (aw-ptr self) (aw-sel "intValue")))
(defgeneric ns:number-with-int_ (class value))                        ; a class method
(defmethod ns:number-with-int_ ((class (eql (find-class 'ns:ns-number))) value)
  (declare (ignore class))
  (aw-wrap (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer (sb-alien:signed 32)))
    (aw-class "NSNumber") (aw-sel "numberWithInt:") value)))
(defgeneric ns:tagged-count (r))                                     ; call-next-method chain
(defmethod ns:tagged-count ((self ns:ns-array)) (ns:count self))
(defmethod ns:tagged-count ((self ns:ns-mutable-array)) (+ 1000 (call-next-method)))

;; (B1) INSTANTIATE — alloc/init + an explicit-init (initWithString:)
(let* ((seed (aw-wrap (aw-make-nsstring "seeded") t))
       (copy (make-instance 'ns:ns-string :string seed)))      ; explicit-init via register-objc-init
  (check (typep copy 'ns:ns-string) t)
  (check (ns:length copy) 6))
;; (B2) DISPATCH — chain + inherited dispatch + class method + call-next-method
(let* ((arr (make-instance 'ns:ns-mutable-array))              ; bare alloc/init
       (n42 (ns:number-with-int_ (find-class 'ns:ns-number) 42)))
  (check (ns:count arr) 0)
  (ns:add-object_ arr n42)
  (ns:add-object_ arr (ns:number-with-int_ (find-class 'ns:ns-number) 7))
  (check (ns:count arr) 2)                                     ; inherited from ns-array
  (check (ns:int-value (ns:object-at-index_ arr 0)) 42)         ; covariant wrap -> ns-number
  (check (ns:tagged-count arr) 1002))                          ; call-next-method up the chain

;; (B3) SUBCLASS — define a real ObjC subclass + override a selector a FRAMEWORK invokes.
(defvar *note-fired* nil)
(defvar *note-on-main* nil)
(define-objc-subclass aw-integ-observer (ns:ns-object)
  (:slots (tag :initarg :tag :initform :unset :accessor obs-tag)))
(define-objc-method (aw-integ-observer "handleNote:") ((self aw-integ-observer) note)
  (declare (ignore note))
  (setf *note-fired* (obs-tag self)
        *note-on-main* (= 1 (smoke-is-main))))
(let* ((observer (make-instance 'aw-integ-observer :tag :observed))
       (center (send0 (aw-class "NSNotificationCenter") "defaultCenter"))
       (nm (aw-make-nsstring "AwIntegNote")))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer sb-alien:system-area-pointer))
    center (aw-sel "addObserver:selector:name:object:")
    (aw-ptr observer) (aw-sel "handleNote:") nm (aw-null-sap))
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:void sb-alien:system-area-pointer sb-alien:system-area-pointer
                       sb-alien:system-area-pointer sb-alien:system-area-pointer))
    center (aw-sel "postNotificationName:object:") nm (aw-null-sap))
  (send1 center "removeObserver:" (aw-ptr observer)))
(check *note-fired* :observed)                                ; the framework dispatched into Lisp
(check *note-on-main* t)                                      ; ADR-0035: delivered on main

;; (B4) CALLBACK — a Lisp block fired from FOREIGN GCD workers bounces to main + returns.
(let ((calls 0) (off-main nil) (stop (list nil)))
  (let* ((blk (aw-block (lambda (a1 a2 a3)
                          (declare (ignore a1 a3))
                          (unless (= 1 (smoke-is-main)) (setf off-main t))
                          (incf calls)
                          (1+ (sb-sys:sap-int a2)))))
         (forcer (sb-thread:make-thread (lambda () (loop until (car stop) do (sb-ext:gc :full t) (sleep 0.005)))
                                        :name "gc-forcer"))
         (sum (smoke-block-storm blk 4 50)))             ; 4 foreign workers x 50
    (setf (car stop) t) (sb-thread:join-thread forcer)
    (check calls 200)                                          ; every invocation ran
    (check off-main nil)                                       ; ... all on the main thread
    (check sum (* 4 (loop for j from 0 below 50 sum (1+ j))))))  ; value crossed the sync bounce

;;; ===========================================================================
;;; GATE C — background release (ADR-0036), in the integrated runtime: a +1 wrap finalized
;;; OFF main enqueues its raw id; the main-thread pool drain releases it exactly once.
;;; ===========================================================================
(format t "~%========== GATE C — background-release lifetime ==========~%")
(defun integ-new-nsobject ()
  (%msgsend-id-0 (%msgsend-id-0 (aw-class "NSObject") (aw-sel "alloc")) (aw-sel "init")))
(defun integ-retain-count (id)
  (sb-alien:alien-funcall (sb-alien:sap-alien +objc-msgsend+
    (sb-alien:function sb-alien:unsigned-long sb-alien:system-area-pointer sb-alien:system-area-pointer))
    id (aw-sel "retainCount")))
(let ((id-int
        (let ((id (integ-new-nsobject)))
          (%objc-retain id)                                   ; guard retain (keeps it readable)
          (let ((w (aw-wrap id t))) (setf w nil))             ; +1 wrap armed, then dropped
          (sb-sys:sap-int id))))
  (loop repeat 400
        until (sb-thread:with-mutex (*release-queue-lock*) (member id-int *release-queue*))
        do (sb-sys:scrub-control-stack) (sb-ext:gc :full t) (sleep 0.003))
  (check (sb-thread:with-mutex (*release-queue-lock*) (and (member id-int *release-queue*) t)) t)
  (check (integ-retain-count (sb-sys:int-sap id-int)) 2)      ; finalizer ENQUEUED, did NOT release
  (with-autorelease-pool (aw-drain-release-queue))            ; main-thread drain releases
  (check (integ-retain-count (sb-sys:int-sap id-int)) 1)      ; released exactly the wrap's +1
  (%objc-release (sb-sys:int-sap id-int)))                    ; drop the guard -> dealloc

;;; ===========================================================================
;;; GATE D — the §6d Swift-native residual resolves BY SHAPE. Each binding is in the
;;; emitter's EXACT output shape (the `sb-alien:extern-alien "<entry>" …` crossing of
;;; render_binding / render_defmethod / render_constructor) against the fixture's
;;; `aw_sbcl_swift_*` entries (swift-residual-fixture.swift), through the REAL dylib
;;; bridges. At least one of EACH shape links + calls through.
;;; ===========================================================================
(format t "~%========== GATE D — §6d Swift-native residual, by shape ==========~%")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (n '("SCALE" "FIXTURE-GREETING" "SWIFT-DOUBLE-LENGTH" "MAKE-FIXTURE-STRING"
               "MAKE-PAIR" "PAIR-SUM" "RISKY"
               "PAIR" "PAIR-TOTAL" "MAKE-PAIR-STRUCT"))   ; ADR-0042 value-struct owner
    (export (intern n '#:ns) '#:ns)))

;; (D1) FUNCTION — scalar in/out.
(defun ns:scale (a0)
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_FixtureKit_scale" (sb-alien:function sb-alien:double sb-alien:double))
   a0))
(check (ns:scale 21.0d0) 42.0d0)

;; (D2) CONSTANT — Swift-native String global (define-objc-constant + aw-swift-string-result).
(define-objc-constant ns:fixture-greeting
  (aw-swift-string-result
   (sb-alien:alien-funcall
    (sb-alien:extern-alien "aw_sbcl_swift_const_FixtureKit_greeting"
                           (sb-alien:function sb-alien:system-area-pointer)))))
(check ns:fixture-greeting "hello from FixtureKit")

;; (D3) CLASS-OWNER METHOD (045) — receiver-specialized defmethod over a real receiver.
(defgeneric ns:swift-double-length (r))
(defmethod ns:swift-double-length ((self ns:ns-string))
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_m_FixtureKit_NSString_swiftDoubleLength"
                          (sb-alien:function (sb-alien:signed 64) sb-alien:system-area-pointer))
   (aw-ptr self)))
(check (ns:swift-double-length (aw-wrap (aw-make-nsstring "abcd") t)) 8)   ; length 4 * 2

;; (D4) CLASS-OWNER INIT (045) — make-<owner> constructor wraps the +1 id.
(defun ns:make-fixture-string (value)
  (aw-wrap (sb-alien:alien-funcall
            (sb-alien:extern-alien "aw_sbcl_swift_init_FixtureKit_NSString"
                                   (sb-alien:function sb-alien:system-area-pointer (sb-alien:signed 64)))
            value)
           t))
(let ((s (ns:make-fixture-string 99)))
  (check (typep s 'ns:ns-string) t)
  (check (nsstring->string (aw-ptr s)) "fixture-99"))

;; (D5) VALUE/OPAQUE RETURN — a non-bridged Swift value crosses as an AwSbclValueBox
;; handle (raw SAP, no aw-wrap), read back via the box accessor, freed via aw-box-free.
(defun ns:make-pair (a0 a1)
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_FixtureKit_makePair"
                          (sb-alien:function sb-alien:system-area-pointer (sb-alien:signed 64) (sb-alien:signed 64)))
   a0 a1))
(defun ns:pair-sum (handle)
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_m_FixtureKit_Pair_sum"
                          (sb-alien:function (sb-alien:signed 64) sb-alien:system-area-pointer))
   handle))
(let ((box (ns:make-pair 15 27)))
  (check (aw-null-sap-p box) nil)                             ; a real +1 box handle crossed
  (check (ns:pair-sum box) 42)                                ; the boxed value survived
  (aw-box-free box))                                          ; the one uniform free reclaims it

;; (ADR-0042) VALUE-STRUCT OWNER — a nameable Swift value struct (`Pair`) projects to a
;; PLAIN CLOS class on `ns:value-struct`: its constructor WRAPS the produced box into an
;; instance, its method dispatches as a `defmethod` whose receiver coerces through the
;; SAME `(aw-ptr self)` as a class owner (the box rides the `ptr` slot). This is the exact
;; shape emit-sbcl's `structs.lisp` emits — proven here against the real dylib.
(defclass ns:pair (ns:value-struct) ())
(defgeneric ns:pair-total (receiver))
(defmethod ns:pair-total ((self ns:pair))
  (sb-alien:alien-funcall
   (sb-alien:extern-alien "aw_sbcl_swift_m_FixtureKit_Pair_sum"
                          (sb-alien:function (sb-alien:signed 64) sb-alien:system-area-pointer))
   (aw-ptr self)))
(defun ns:make-pair-struct (a0 a1)
  (make-instance 'ns:pair :ptr
                 (sb-alien:alien-funcall
                  (sb-alien:extern-alien "aw_sbcl_swift_FixtureKit_makePair"
                                         (sb-alien:function sb-alien:system-area-pointer
                                                            (sb-alien:signed 64) (sb-alien:signed 64)))
                  a0 a1)))
(let ((p (ns:make-pair-struct 20 22)))
  (check (typep p 'ns:value-struct) t)                       ; the box is wrapped in a CLOS instance
  (check (typep p 'ns:pair) t)
  (check (aw-null-sap-p (aw-ptr p)) nil)                      ; (aw-ptr self) yields the box (receiver path)
  (check (ns:pair-total p) 42))                              ; defmethod dispatch -> unbox -> value survived

;; (D6) THROWS — ThrowsBridge → ns:cocoa-error (the 050/050 aw-swift-call/error consumer,
;; which releases the +1 NSError the bridge writes). Success returns the value; throw signals.
(defun ns:risky (a0)
  (aw-swift-call/error (%err)
    (aw-wrap (sb-alien:alien-funcall
              (sb-alien:extern-alien "aw_sbcl_swift_FixtureKit_risky"
                                     (sb-alien:function sb-alien:system-area-pointer
                                                        (sb-alien:signed 64) sb-alien:system-area-pointer))
              a0 %err)
             t)))
(check (nsstring->string (aw-ptr (ns:risky 0))) "ok")          ; success path, no signal
(check (handler-case (progn (ns:risky 1) :unexpectedly-returned)
         (ns:cocoa-error (e) (list (ns:domain e) (ns:code e) (and (ns:localized-description e) t))))
       (list "FixtureKitErrorDomain" 42 t))                    ; throw -> ns:cocoa-error, fields read
(check (handler-bind ((ns:cocoa-error (lambda (c) (declare (ignore c)) (invoke-restart 'return-nil))))
         (ns:risky 1))
       nil)                                                    ; the restart works

;; Shapes that need a still-open leaf — RECORDED, never silently skipped (080 done-when).
;; (value-struct-owner method/init is now PROVEN above — ADR-0042 / leaf 090.)
(record-pending "async-method trampoline (AsyncBridge)"
                "the Lisp async-completion consumer is a deferred follow-up (threading.lisp); the CallbackBounce family is proven by GATE B4")

;;; ===========================================================================
;;; Verdict
;;; ===========================================================================
(format t "~%========================================================~%")
(when *pending*
  (format t "### ~D shape(s) recorded PENDING (open leaves), not skipped:~%" (length *pending*))
  (dolist (p (reverse *pending*)) (format t "###   - ~A~%" (car p))))
(format t "### smoke-integration (050 node done-bar): ~A (~D failure~:P)~%"
        (if (zerop *fails*) "PASS" "FAIL") *fails*)
(sb-ext:exit :code (if (zerop *fails*) 0 1))
