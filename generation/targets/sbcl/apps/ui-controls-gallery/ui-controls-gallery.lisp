;;;; ui-controls-gallery.lisp — AppKit Controls Gallery sample app (sbcl target, the
;;;; 060 ladder's third app). A single fixed-size window showing 16+ distinct AppKit
;;;; controls in a two-column, section-headed layout — the broad-surface app of the
;;;; ladder (hello-window = pipeline bootstrap; swift-native-probe = trampoline lower
;;;; layer; this = a wide slice of the generated AppKit binding).
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:` surface, `make-instance` (§3.3), the per-selector generics
;;;; (§3.2 — including the class-method convenience constructors via the
;;;; `(eql (find-class 'ns:…))` specializer), and the `@"…"` NSString reader (§3.2).
;;;;
;;;; CONSTRUCTION (the init-registry decision hello-window flagged): each control is
;;;; built either through its class **convenience constructor** (`+buttonWithTitle:…`,
;;;; `+checkboxWithTitle:…`, `+radioButtonWithTitle:…`, `+imageViewWithImage:`,
;;;; `+[NSImage imageWithSystemSymbolName:…]`) or by bare `make-instance` (alloc/init →
;;;; the control's own `initWithFrame:NSZeroRect`) followed by `setFrame:` + property
;;;; setters. NO control here needs a typed *inherited* init, so the exact-class init
;;;; registry (no superclass walk in `aw-apply-init`) is not exercised — the workaround,
;;;; not the runtime fix; see learnings.md.
;;;;
;;;; Inherited value setters (`setDoubleValue:`/`setIntegerValue:`/`setStringValue:`) live
;;;; on NSControl and resolve onto every control subclass by CLOS inheritance — the same
;;;; mechanism hello-window's label used for `ns:set-string-value_`.
;;;;
;;;; PURE ObjC — no Swift-native residual — so, like hello-window, the run/build harness
;;;; loads bindings with `:load-residual nil` and the artifact needs NO libAPIAnywareSbcl
;;;; dylib (VM provisioning is libzstd only).
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like hello-window). The two
;;;; not-yet-portable touchpoints (the impl-package home giving bare `make-instance`, and
;;;; the `aw-with-rect` geometry primitive) are the same contract-surface follow-ups
;;;; hello-window recorded — they do not affect the portable `ns:`-named Cocoa calls.

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; The standard app menu (Quit -> -[NSApplication terminate:]), as hello-window.
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
;;; Layout helpers. AppKit's content view is NOT flipped (origin bottom-left), so a
;;; control's ObjC y is `total-h - (top + h)` where TOP is its distance from the top
;;; edge — letting us lay rows out top-down. A column threads a mutable TOP cursor; each
;;; `g-row` / `g-header` returns the next cursor value.
;;; ---------------------------------------------------------------------------

(defun g-place (content total-h control x top w h)
  "Frame an existing CONTROL at (X, TOP, W, H) — TOP from the content top — and add it."
  (aw-with-rect (r x (- total-h (+ top h)) w h) (ns:set-frame_ control r))
  (ns:add-subview_ content control)
  control)

(defun gallery-label (content total-h text x top w h
                      &key (size 13) (align ns:ns-text-alignment-left) color bold)
  "A non-editable NSTextField caption (the hello-window label recipe), framed top-down
   and added to CONTENT. BOLD picks the bold system font; COLOR sets the text colour."
  (let ((field (make-instance 'ns:ns-text-field)))
    (aw-with-rect (r x (- total-h (+ top h)) w h) (ns:set-frame_ field r))
    (ns:set-string-value_ field (aw-wrap (aw-make-nsstring text) t))
    (ns:set-font_ field (let ((sz (coerce size 'double-float)))
                          (if bold
                              (ns:bold-system-font-of-size_ (find-class 'ns:ns-font) sz)
                              (ns:system-font-of-size_ (find-class 'ns:ns-font) sz))))
    (ns:set-alignment_ field align)
    (ns:set-editable_ field nil)
    (ns:set-selectable_ field nil)
    (ns:set-bezeled_ field nil)
    (ns:set-draws-background_ field nil)
    (when color (ns:set-text-color_ field color))
    (ns:add-subview_ content field)
    field))

(defun g-row (content total-h label-x label-w ctrl-x top caption control cw ch caption-color)
  "Place a right-aligned CAPTION and CONTROL (CW×CH), both vertically centred in the row,
   and return the next TOP. CAPTION nil places only the control."
  (let* ((row-h    (max ch 22))
         (cap-h    18)
         (cap-top  (+ top (floor (- row-h cap-h) 2)))
         (ctrl-top (+ top (floor (- row-h ch) 2))))
    (when caption
      (gallery-label content total-h caption label-x cap-top label-w cap-h
                     :size 13 :align ns:ns-text-alignment-right :color caption-color))
    (g-place content total-h control ctrl-x ctrl-top cw ch)
    (+ top row-h 14)))

(defun g-header (content total-h x w top text)
  "A bold section header + an NSBox separator line below it; returns the next TOP."
  (gallery-label content total-h text x (+ top 2) w 20
                 :size 15 :align ns:ns-text-alignment-left :bold t)
  (let ((sep (make-instance 'ns:ns-box)))
    (ns:set-box-type_ sep ns:ns-box-separator)
    (g-place content total-h sep x (+ top 25) w 1))
  (+ top 38))

;;; ---------------------------------------------------------------------------
;;; The control constructors. Each returns a configured, un-framed control; the row
;;; helper frames + adds it. Grouped by section to mirror the layout.
;;; ---------------------------------------------------------------------------

(defun gallery-color (name) (funcall name (find-class 'ns:ns-color)))

;; --- Buttons & toggles ---
(defun mk-push-button ()
  (ns:button-with-title_target_action_ (find-class 'ns:ns-button) @"Click Me" nil ""))

(defun mk-checkbox ()
  (let ((cb (ns:checkbox-with-title_target_action_
             (find-class 'ns:ns-button) @"Enable feature" nil "")))
    (ns:set-state_ cb 1)                 ; 1 = NSControlStateValueOn (not emitted as an enum)
    cb))

(defun mk-radio (title on)
  (let ((r (ns:radio-button-with-title_target_action_
            (find-class 'ns:ns-button) title nil "")))   ; siblings + same SEL -> a group
    (ns:set-state_ r (if on 1 0))
    r))

(defun mk-switch ()
  (let ((sw (make-instance 'ns:ns-switch)))
    (ns:set-state_ sw 1)
    sw))

(defun mk-segmented ()
  (let ((seg (make-instance 'ns:ns-segmented-control)))
    (ns:set-segment-count_ seg 3)
    (ns:set-label_for-segment_ seg @"List"    0)
    (ns:set-label_for-segment_ seg @"Grid"    1)
    (ns:set-label_for-segment_ seg @"Gallery" 2)
    (ns:set-selected-segment_ seg 1)
    seg))

;; --- Value selectors ---
(defun mk-slider ()
  (let ((s (make-instance 'ns:ns-slider)))
    (ns:set-min-value_ s 0.0d0)
    (ns:set-max-value_ s 100.0d0)
    (ns:set-double-value_ s 65.0d0)          ; inherited NSControl setter
    (ns:set-number-of-tick-marks_ s 11)
    s))

(defun mk-stepper ()
  (let ((s (make-instance 'ns:ns-stepper)))
    (ns:set-min-value_ s 0.0d0)
    (ns:set-max-value_ s 10.0d0)
    (ns:set-increment_ s 1.0d0)
    (ns:set-double-value_ s 3.0d0)
    s))

(defun mk-level ()
  (let ((l (make-instance 'ns:ns-level-indicator)))
    (ns:set-level-indicator-style_ l ns:ns-level-indicator-style-rating)
    (ns:set-min-value_ l 0.0d0)
    (ns:set-max-value_ l 5.0d0)
    (ns:set-double-value_ l 3.0d0)
    l))

(defun mk-progress-bar ()
  (let ((p (make-instance 'ns:ns-progress-indicator)))
    (ns:set-style_ p ns:ns-progress-indicator-style-bar)
    (ns:set-indeterminate_ p nil)
    (ns:set-min-value_ p 0.0d0)
    (ns:set-max-value_ p 100.0d0)
    (ns:set-double-value_ p 60.0d0)
    p))

(defun mk-spinner ()
  (let ((p (make-instance 'ns:ns-progress-indicator)))
    (ns:set-style_ p ns:ns-progress-indicator-style-spinning)
    (ns:set-indeterminate_ p t)
    p))                                  ; start-animation_ called after it is in the view

;; --- Pickers & fields ---
(defun mk-popup ()
  (let ((p (make-instance 'ns:ns-pop-up-button)))
    (ns:add-item-with-title_ p @"Red")
    (ns:add-item-with-title_ p @"Green")
    (ns:add-item-with-title_ p @"Blue")
    (ns:select-item-at-index_ p 2)
    p))

(defun mk-combo ()
  (let ((c (make-instance 'ns:ns-combo-box)))
    (ns:add-item-with-object-value_ c @"Small")
    (ns:add-item-with-object-value_ c @"Medium")
    (ns:add-item-with-object-value_ c @"Large")
    (ns:set-string-value_ c @"Medium")
    c))

(defun mk-text-field ()
  (let ((tf (make-instance 'ns:ns-text-field)))  ; default: editable + bezeled
    (ns:set-placeholder-string_ tf @"Type here...")
    tf))

(defun mk-secure-field ()
  (let ((sf (make-instance 'ns:ns-secure-text-field)))
    (ns:set-placeholder-string_ sf @"Password")
    sf))

(defun mk-color-well ()
  (let ((w (make-instance 'ns:ns-color-well)))
    (ns:set-color_ w (gallery-color 'ns:system-blue-color))
    w))

(defun mk-date-picker ()
  (let ((dp (make-instance 'ns:ns-date-picker)))
    (ns:set-date-picker-style_ dp ns:ns-date-picker-style-text-field-and-stepper)
    (ns:set-date-picker-elements_ dp ns:ns-date-picker-element-flag-year-month-day)
    (ns:set-date-value_ dp (ns:now (find-class 'ns:ns-date)))
    dp))

;; --- Display ---
(defun mk-image-view ()
  (let* ((img (ns:image-with-system-symbol-name_accessibility-description_
               (find-class 'ns:ns-image) @"star.fill" @"star"))
         (iv  (ns:image-view-with-image_ (find-class 'ns:ns-image-view) img)))
    (ns:set-image-scaling_ iv ns:ns-image-scale-proportionally-up-or-down)
    (ns:set-content-tint-color_ iv (gallery-color 'ns:control-accent-color))
    iv))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun ui-controls-gallery-main (&key (run t))
  "Build the controls-gallery UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060/040): it performs every FFI crossing
   the app does — all 16+ control constructors, their setters, the typed window/menu
   inits — then returns WITHOUT blocking on `-run`, so a bare `sbcl --load` validates
   marshalling before the VM round-trip. The dumped image's toplevel calls RUN t."
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Controls Gallery")
    (aw-with-rect (frame 0 0 820 500)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content (ns:content-view window))
             (h 500)
             (sec (gallery-color 'ns:secondary-label-color))
             (lt 18) (rt 18)
             (spinner (mk-spinner)))
        (ns:set-title_ window @"AppKit Controls - SBCL")
        (ns:center window)
        (flet ((lhdr (text) (setf lt (g-header content h 20 350 lt text)))
               (rhdr (text) (setf rt (g-header content h 430 350 rt text)))
               (lrow (cap ctrl cw ch) (setf lt (g-row content h 20 120 150 lt cap ctrl cw ch sec)))
               (rrow (cap ctrl cw ch) (setf rt (g-row content h 430 120 560 rt cap ctrl cw ch sec))))
          ;; ===== Left column =====
          (lhdr "Buttons & Toggles")
          (lrow "Push button" (mk-push-button) 130 30)
          (lrow "Checkbox"    (mk-checkbox)     170 22)
          ;; Radio pair on one row (two controls, advance the cursor once).
          (let* ((row-h 22) (ct (+ lt (floor (- row-h 20) 2))))
            (gallery-label content h "Radio group" 20 (+ lt 2) 120 18
                           :align ns:ns-text-alignment-right :color sec)
            (g-place content h (mk-radio @"Option A" t)   150 ct 96 20)
            (g-place content h (mk-radio @"Option B" nil) 250 ct 96 20)
            (setf lt (+ lt row-h 14)))
          (lrow "Switch"      (mk-switch)       40  24)
          (lrow "Segmented"   (mk-segmented)    230 24)
          (lhdr "Value Selectors")
          (lrow "Slider"      (mk-slider)       210 24)
          (lrow "Stepper"     (mk-stepper)      20  28)
          (lrow "Rating"      (mk-level)        120 20)
          (lrow "Progress"    (mk-progress-bar) 210 16)
          (lrow "Spinner"     spinner           28  28)
          ;; ===== Right column =====
          (rhdr "Pickers & Fields")
          (rrow "Pop-up"      (mk-popup)        170 26)
          (rrow "Combo box"   (mk-combo)        170 26)
          (rrow "Text field"  (mk-text-field)   210 24)
          (rrow "Secure"      (mk-secure-field) 210 24)
          (rrow "Colour well" (mk-color-well)   60  26)
          (rrow "Date"        (mk-date-picker)  200 26)
          (rhdr "Display")
          (rrow "SF Symbol"   (mk-image-view)   52  52))

        ;; --- Show + run ---
        (ns:make-key-and-order-front_ window nil)
        (ns:activate-ignoring-other-apps_ app t)
        (ns:start-animation_ spinner nil)      ; the spinner is now in the view tree
        (when run
          (format t "~&Controls Gallery opened. Quit with Cmd-Q.~%")
          (finish-output)
          (ns:run app))))))
