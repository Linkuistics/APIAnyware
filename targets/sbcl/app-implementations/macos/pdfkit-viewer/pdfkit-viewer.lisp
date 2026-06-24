;;;; pdfkit-viewer.lisp — PDFKit Viewer sample app (sbcl target, the 060 ladder's fifth
;;;; app). Open a .pdf via a modal NSOpenPanel, render it in a PDFView, navigate pages
;;;; via ◀/▶ toolbar buttons, and keep a "Page n of N" label in sync via the
;;;; PDFViewPageChangedNotification observer. The sbcl analogue of racket/chez/gerbil's
;;;; pdfkit-viewer.
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:` surface, `make-instance` typed inits (§3.3), the per-selector
;;;; generics (§3.2 — including the NSOpenPanel / NSNotificationCenter class factories via
;;;; the `(eql (find-class 'ns:…))` specializer), the `@"…"` NSString reader (§3.2), and
;;;; the subclass macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).
;;;;
;;;; Distinctive (vs. scenekit-viewer, the prior custom-delegate app):
;;;;   - FIRST sbcl app to use PDFKit (freshly generated for this leaf) AND a modal
;;;;     NSOpenPanel (`runModal`, inherited from NSSavePanel — reached by plain CLOS
;;;;     inheritance dispatch, the open panel IS an `ns:ns-save-panel`) AND an
;;;;     NSNotificationCenter observer.
;;;;   - ONE synthesized delegate, FOUR selectors: `pdf-controller` is a real
;;;;     `define-objc-subclass` of NSObject that is simultaneously the target-action
;;;;     target (`openDocument:`/`goPrev:`/`goNext:`) AND the notification observer
;;;;     (`pageChanged:`). The page-label update flows through the NOTIFICATION, not an
;;;;     explicit call — so it stays correct however the page turned (buttons, arrows,
;;;;     scroll). All four selectors get the synthesized default `v@:@` encoding and are
;;;;     forwarded — bounced to main, GC-safe — into CLOS `defmethod`s.
;;;;
;;;; FIRST ladder app to need a framework STRING CONSTANT inside a dumped image
;;;; (`PDFViewPageChangedNotification`). A `define-objc-constant` is read once at load and
;;;; is a dead pointer across `save-lisp-and-die`; this leaf added the runtime's startup
;;;; re-resolution of the constant surface (objc.lisp / startup.lisp), so the baked
;;;; notification name is re-derived in the revived image before `-main` registers the
;;;; observer. PDFKit is therefore loaded `:load-residual t` (for `constants.lisp`); like
;;;; scenekit-viewer the app LOADS `libAPIAnywareSbcl` for the `aw_sbcl_subclass_*` bounce
;;;; shim, not trampoline residual (every PDFKit/AppKit call is plain ObjC).
;;;;
;;;; DUMP/REVIVE of a synthesized subclass: the ObjC class pair lives in libobjc, not the
;;;; Lisp heap, so `ensure-pdf-controller` re-synthesizes it from `-main` in the revived
;;;; image (the runtime re-registers the forwarding dispatcher + re-resolves constants at
;;;; startup). defclass/defmethod re-evaluation is idempotent.
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

;;; NSModalResponseOK is not in the AppKit enums — define locally, matching the
;;; racket/chez/gerbil source's identical workaround.
(defconstant +ns-modal-response-ok+ 1)

;;; ---------------------------------------------------------------------------
;;; UI refresh (pure function of the controller's slots). Read with `slot-value` (not
;;; per-class `:accessor`s): the bodies compile when this file loads, but the accessors
;;; would only exist once the inner `define-objc-subclass` RUNS — `slot-value` is always
;;; defined, so this compiles warning-free (the scenekit-viewer pattern).
;;; ---------------------------------------------------------------------------
(defun refresh-pdf-ui (controller)
  "Reconcile the page label + ◀/▶ enabled state with the PDFView. With no document:
   \"No PDF loaded\", both buttons off. With one: \"Page n of N\" (1-based) and the
   buttons reflect `canGoTo{Previous,Next}Page`. Driven by `pageChanged:` on every page
   turn, so it tracks buttons, arrow keys, and scrolls identically."
  (let ((doc      (slot-value controller 'document))
        (pdf-view (slot-value controller 'pdf-view))
        (prev     (slot-value controller 'prev-button))
        (next     (slot-value controller 'next-button))
        (label    (slot-value controller 'page-label)))
    (if (not doc)
        (progn
          (ns:set-string-value_ label @"No PDF loaded")
          (ns:set-enabled_ prev nil)
          (ns:set-enabled_ next nil))
        (let* ((total   (ns:page-count doc))
               ;; nil current-page (transient, mid-swap) collapses to index 0.
               (current (ns:current-page pdf-view))
               (index   (if current (ns:index-for-page_ doc current) 0)))
          (ns:set-string-value_ label
            (aw-wrap (aw-make-nsstring
                      (format nil "Page ~D of ~D" (1+ index) total)) t))
          (ns:set-enabled_ prev (ns:can-go-to-previous-page pdf-view))
          (ns:set-enabled_ next (ns:can-go-to-next-page pdf-view))))))

;;; ---------------------------------------------------------------------------
;;; The delegate — a real ObjC subclass of NSObject (contract §3.4/§3.5), holding the
;;; live UI refs as slots. Defined INSIDE a function so it re-synthesizes in a revived
;;; dumped image: `-main` is the dumped image's toplevel, and `aw-synthesize-subclass` /
;;; `aw-install-override` must re-run there (the ObjC class pair + the dispatch routing
;;; did not survive the dump). defclass/defmethod re-evaluation is idempotent.
;;; ---------------------------------------------------------------------------

(defvar *pdf-controller-ready* nil
  "nil until `ensure-pdf-controller` has defined the class in THIS process. A revived
   image starts nil again (the symbol survives the dump, a fresh `defvar` value does
   not) and re-defines.")

(defun ensure-pdf-controller ()
  "Define the `pdf-controller` ObjC subclass + its four target-action / observer methods.
   Called from `-main` so it runs in whatever process actually shows the UI (host
   pre-flight or revived dump). Idempotent within a process via `*pdf-controller-ready*`."
  (unless *pdf-controller-ready*
    (define-objc-subclass pdf-controller (ns:ns-object)
      (:slots
       (pdf-view    :initarg :pdf-view)
       (prev-button :initarg :prev-button)
       (next-button :initarg :next-button)
       (page-label  :initarg :page-label)
       (pdf-types   :initarg :pdf-types)
       (document    :initform nil)))

    ;; openDocument: — modal NSOpenPanel filtered to .pdf; load the chosen URL into a
    ;; PDFDocument and hand it to the PDFView. `make-instance :init-with-url` returns nil
    ;; for a non-PDF (initWithURL: -> nil -> aw-wrap -> nil), so the load is guarded.
    (define-objc-method (pdf-controller "openDocument:") (self sender)
      (declare (ignore sender))
      (let ((panel (ns:open-panel (find-class 'ns:ns-open-panel))))
        (ns:set-can-choose-files_ panel t)
        (ns:set-can-choose-directories_ panel nil)
        (ns:set-allows-multiple-selection_ panel nil)
        ;; setAllowedFileTypes: / runModal / URL are inherited from NSSavePanel; plain
        ;; CLOS inheritance dispatch reaches them on the open-panel instance.
        (ns:set-allowed-file-types_ panel (slot-value self 'pdf-types))
        (when (= (ns:run-modal panel) +ns-modal-response-ok+)
          (let ((url (ns:url panel)))
            (when url
              (let ((doc (make-instance 'ns:pdf-document :init-with-url url)))
                (when doc
                  (setf (slot-value self 'document) doc)
                  (ns:set-document_ (slot-value self 'pdf-view) doc)
                  (refresh-pdf-ui self))))))))

    ;; goPrev:/goNext: — the sender id PDFKit ignores (nil -> nil). The resulting page
    ;; change fires PDFViewPageChangedNotification, which refreshes the UI via pageChanged:.
    (define-objc-method (pdf-controller "goPrev:") (self sender)
      (declare (ignore sender))
      (ns:go-to-previous-page_ (slot-value self 'pdf-view) nil))
    (define-objc-method (pdf-controller "goNext:") (self sender)
      (declare (ignore sender))
      (ns:go-to-next-page_ (slot-value self 'pdf-view) nil))

    ;; pageChanged: — fires on EVERY page change (buttons, arrows, scroll). One observer
    ;; keeps the label + buttons correct however the page was turned.
    (define-objc-method (pdf-controller "pageChanged:") (self note)
      (declare (ignore note))
      (refresh-pdf-ui self))

    (setf *pdf-controller-ready* t)))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun pdfkit-viewer-main (&key (run t))
  "Build the PDFKit-viewer UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060): it synthesizes the delegate class,
   builds the window + every control, wires target-action, AND registers the notification
   observer (reading the re-resolved `PDFViewPageChangedNotification`) — every FFI crossing
   the app does up to the run loop — then returns WITHOUT blocking on `-run`, so a bare
   `sbcl --load` validates marshalling (and, in the revived image, the startup
   re-resolution — frameworks, dispatcher, AND the constant surface — plus re-synthesis)
   before the VM round-trip. The dumped image's toplevel calls RUN t."
  (ensure-pdf-controller)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "PDFKit Viewer")
    (aw-with-rect (frame 0 0 720 540)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable
                                           ns:ns-window-style-mask-resizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content (ns:content-view window)))
        (ns:set-title_ window @"PDFKit Viewer")
        (ns:center window)
        (aw-with-size (minsz 480 360) (ns:set-min-size_ window minsz))

        ;; --- PDFView: fills below the toolbar, auto-scaling, single-page-continuous ---
        (let ((pdf-view (make-instance 'ns:pdf-view)))
          (aw-with-rect (vframe 0 0 720 492) (ns:set-frame_ pdf-view vframe))
          (ns:set-autoresizing-mask_ pdf-view
            (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))
          (ns:set-auto-scales_ pdf-view t)
          (ns:set-display-mode_ pdf-view ns:k-pdf-display-single-page-continuous)
          (ns:add-subview_ content pdf-view)

          ;; --- Toolbar controls ---
          (let ((open-button (make-instance 'ns:ns-button))
                (prev-button (make-instance 'ns:ns-button))
                (next-button (make-instance 'ns:ns-button))
                (page-label  (make-instance 'ns:ns-text-field))
                ;; File-type filter for NSOpenPanel: a one-element NSArray of "pdf".
                (pdf-types   (let ((arr (make-instance 'ns:ns-mutable-array
                                          :init-with-capacity 1)))
                               (ns:add-object_ arr @"pdf")
                               arr)))
            (ns:set-title_ open-button @"Open…")
            (ns:set-bezel-style_ open-button ns:ns-bezel-style-rounded)
            (ns:set-title_ prev-button @"◀")
            (ns:set-bezel-style_ prev-button ns:ns-bezel-style-rounded)
            (ns:set-title_ next-button @"▶")
            (ns:set-bezel-style_ next-button ns:ns-bezel-style-rounded)

            (ns:set-font_ page-label (ns:system-font-of-size_ (find-class 'ns:ns-font) 13.0d0))
            (ns:set-editable_ page-label nil)
            (ns:set-selectable_ page-label nil)
            (ns:set-bezeled_ page-label nil)
            (ns:set-draws-background_ page-label nil)

            ;; --- The delegate, holding the live controls + the document slot ---
            (let ((controller (make-instance 'pdf-controller
                                :pdf-view pdf-view
                                :prev-button prev-button
                                :next-button next-button
                                :page-label page-label
                                :pdf-types pdf-types)))

              ;; --- Toolbar: horizontal stack pinned to the top edge, grows with width ---
              (let ((stack (make-instance 'ns:ns-stack-view)))
                (aw-with-rect (sframe 12 500 696 32) (ns:set-frame_ stack sframe))
                (ns:set-orientation_ stack ns:ns-user-interface-layout-orientation-horizontal)
                (ns:set-alignment_ stack ns:ns-layout-attribute-first-baseline)
                (ns:set-spacing_ stack 8.0d0)
                (ns:add-arranged-subview_ stack open-button)
                (ns:add-arranged-subview_ stack prev-button)
                (ns:add-arranged-subview_ stack next-button)
                (ns:add-arranged-subview_ stack page-label)
                (ns:set-autoresizing-mask_ stack
                  (logior ns:ns-view-width-sizable ns:ns-view-min-y-margin))
                (ns:add-subview_ content stack)

                ;; --- Target-action wiring (after the controller exists) ---
                (ns:set-target_ open-button controller)
                (ns:set-action_ open-button "openDocument:")
                (ns:set-target_ prev-button controller)
                (ns:set-action_ prev-button "goPrev:")
                (ns:set-target_ next-button controller)
                (ns:set-action_ next-button "goNext:")

                ;; --- Notification observer: pageChanged: on every PDFView page change.
                ;; The name is the re-resolved `PDFViewPageChangedNotification` constant
                ;; (correct in a revived image thanks to the startup constant pass); the
                ;; object filter is the PDFView, so only its notifications fire it. ---
                (ns:add-observer_selector_name_object_
                  (ns:default-center (find-class 'ns:ns-notification-center))
                  controller "pageChanged:"
                  ns:pdf-view-page-changed-notification
                  pdf-view)

                ;; Initial (empty) state.
                (refresh-pdf-ui controller)

                ;; --- Show + run ---
                (ns:make-key-and-order-front_ window nil)
                (ns:activate-ignoring-other-apps_ app t)
                (when run
                  (format t "~&PDFKit Viewer opened. Open a .pdf, navigate with ◀/▶. Quit with Cmd-Q.~%")
                  (finish-output)
                  (ns:run app))
                controller))))))))
