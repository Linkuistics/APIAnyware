;;;; note-editor.lisp — Note Editor sample app (sbcl target, the 060 ladder's seventh
;;;; and final app, the capstone). A Markdown editor with a live HTML preview: the left
;;;; pane is an NSTextView (in an NSScrollView) where the user types Markdown; the right
;;;; pane is a WKWebView that re-renders the text as HTML on every
;;;; NSTextDidChangeNotification. An NSSplitView (vertical divider) holds the two. A
;;;; toolbar carries New / Open… / Save… / Undo / Redo + a status line. The sbcl analogue
;;;; of racket/chez/gerbil's note-editor (mirrors generation/targets/gerbil/apps/
;;;; note-editor/note-editor.ss one piece at a time).
;;;;
;;;; Written against the CL-family interface contract (ADR-0033 / the contract spec): it
;;;; names only the `ns:` surface, `make-instance` typed inits (§3.3 — NSWindow's
;;;; initWithContentRect:…, NSTextView/NSScrollView's initWithFrame:, WKWebView's
;;;; initWithFrame:configuration:, NSMutableArray's initWithCapacity:), the per-selector
;;;; generics (§3.2), the `@"…"` NSString reader (§3.2), and the subclass macros
;;;; `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).
;;;;
;;;; Distinctive (vs. mini-browser, the prior subclass app): this is the FIRST sbcl app
;;;; to cross a **BLOCK BRIDGE**. NSSavePanel's
;;;; `beginSheetModalForWindow:completionHandler:` takes an ObjC block; the emitter wraps
;;;; the handler arg in `(aw-block handler)` (token-less — threading.lisp), so app code
;;;; just hands it a raw Lisp closure. The dylib builds a native block capturing an
;;;; integer id; when the save sheet dismisses, the block body BOUNCES TO MAIN (ADR-0035 —
;;;; a no-op pass-through here, since the sheet completion fires on main) and re-enters
;;;; Lisp through the ONE `aw-block-dispatcher`, handing the closure the NSModalResponse as
;;;; a raw SAP (read with `sb-sys:sap-int`). The block analogue of mini-browser's
;;;; WKNavigationDelegate callbacks.
;;;;
;;;; Also exercised, all on ONE `note-controller` (`define-objc-subclass` of NSObject) that
;;;; carries SIX selectors in two roles (like mini-browser's eight):
;;;;   - five toolbar target-actions (newDoc:/openDoc:/saveDoc:/undoDoc:/redoDoc:);
;;;;   - one NSTextDidChangeNotification observer (textDidChange:) — re-render + mark dirty.
;;;; Plus NSUndoManager (undo/redo via the NSTextView's manager on NSResponder), NSAlert
;;;; unsaved-changes confirmation, NSOpenPanel (runModal), window dirty-state
;;;; (`setDocumentEdited:`), and hand-rolled Markdown→HTML + Lisp-native UTF-8 file I/O.
;;;;
;;;; The editor STATE (`current-path`, `dirty`) lives in controller SLOTS, mutated via
;;;; `slot-value` — the sbcl idiom replaces gerbil's closure variables. The pure UI/state
;;;; helpers read those slots with `slot-value` (not per-class accessors): their bodies
;;;; compile when this file loads, but accessors would only exist once the inner
;;;; `define-objc-subclass` RUNS; `slot-value` is always defined (the mini-browser pattern).
;;;;
;;;; Framework loads: Foundation `:load-residual nil` (file I/O is Lisp-native; NSURL/
;;;; NSUndoManager/NSNotificationCenter/NSMutableArray are pure-ObjC classes), AppKit
;;;; `:load-residual t` (for the `NSTextDidChangeNotification` constant — the
;;;; swift-native-probe path), WebKit `:load-residual nil` (pure-ObjC WKWebView surface, as
;;;; mini-browser). The dylib is loaded for BOTH the `aw_sbcl_subclass_*` bounce shim (the
;;;; controller) AND the `aw_sbcl_make_block` block factory (the save handler).
;;;;
;;;; DUMP/REVIVE of a synthesized subclass: the ObjC class pair lives in libobjc, not the
;;;; Lisp heap, so `ensure-note-controller` re-synthesizes it from `-main` in the revived
;;;; image (the startup re-resolution pass re-registers the forwarding dispatcher AND the
;;;; block dispatcher, and re-resolves the AppKit constant surface). defclass/defmethod
;;;; re-evaluation is idempotent.
;;;;
;;;; Package: `apianyware-sbcl-impl` (the dev-harness home, like the other ladder apps).

(in-package #:apianyware-sbcl-impl)

;;; ---------------------------------------------------------------------------
;;; Modal-response / alert-button codes the collector does not extract as enums
;;; (NSModalResponse lives in AppKit but as plain #defines / typed constants). Parity
;;; with racket/chez/gerbil's local definitions.
;;; ---------------------------------------------------------------------------
(defconstant +ns-modal-response-ok+ 1)
(defconstant +ns-alert-first-button-return+ 1000)

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

;;; ---------------------------------------------------------------------------
;;; Geometry.
;;; ---------------------------------------------------------------------------
(defconstant +window-w+ 900)
(defconstant +window-h+ 600)
(defconstant +toolbar-h+ 32)
(defconstant +margin+ 12)

;;; ---------------------------------------------------------------------------
;;; NSString <-> Lisp string helpers.
;;; ---------------------------------------------------------------------------
(defun ns->str (obj)
  "A wrapped `ns:ns-string` (or any object whose `ptr` is an NSString) -> a Lisp string;
   nil (a wrap of a null id) -> \"\". `nsstring->string` takes the id SAP, so unwrap with
   `aw-ptr`."
  (if obj (nsstring->string (aw-ptr obj)) ""))

(defun nsstr (text)
  "A fresh autoreleased NSString from a Lisp string, wrapped (+0 transient)."
  (aw-wrap (aw-make-nsstring text) t))

;;; ============================================================
;;; String + path helpers
;;; ============================================================
(defun trim-both (s)
  (let* ((n (length s))
         (start (loop for i from 0 below n
                      while (member (char s i) '(#\Space #\Tab #\Newline #\Return))
                      finally (return i)))
         (end   (loop for j from n above start
                      while (member (char s (1- j)) '(#\Space #\Tab #\Newline #\Return))
                      finally (return j))))
    (subseq s start end)))

(defun basename (path)
  (let ((slash (position #\/ path :from-end t)))
    (if slash (subseq path (1+ slash)) path)))

;;; ============================================================
;;; Markdown → HTML (hand-rolled; mirrors the racket/chez/gerbil renderer; no regex)
;;; ============================================================
(defun substr-at? (s i sub)
  "True if SUB occurs in S starting at index I."
  (let ((ls (length sub)) (n (length s)))
    (and (<= (+ i ls) n)
         (loop for j from 0 below ls
               always (char= (char s (+ i j)) (char sub j))))))

(defun string-prefix? (prefix s) (substr-at? s 0 prefix))

(defun all-whitespace-from? (s start)
  (loop for i from start below (length s)
        always (member (char s i) '(#\Space #\Tab #\Newline #\Return))))

(defun blank-line? (s) (all-whitespace-from? s 0))
(defun fence-line? (s) (string-prefix? "```" s))
(defun fence-close? (s) (and (fence-line? s) (all-whitespace-from? s 3)))

(defun heading-match (s)
  "ATX heading: 1-6 '#', then whitespace, then text → (cons level text) or nil."
  (let ((n (length s)))
    (labels ((count-hashes (i)
               (cond
                 ((and (< i n) (char= (char s i) #\#)) (count-hashes (1+ i)))
                 ((and (>= i 1) (<= i 6) (< i n)
                       (member (char s i) '(#\Space #\Tab)))
                  (loop for j from i below n
                        while (member (char s j) '(#\Space #\Tab))
                        finally (return (cons i (subseq s j n)))))
                 (t nil))))
      (count-hashes 0))))

(defun list-item-match (s)
  "Unordered-list item: -/*/+ marker + whitespace + text → text or nil."
  (let ((n (length s)))
    (and (>= n 2)
         (member (char s 0) '(#\- #\* #\+))
         (member (char s 1) '(#\Space #\Tab))
         (loop for j from 1 below n
               while (member (char s j) '(#\Space #\Tab))
               finally (return (subseq s j n))))))

(defun html-escape (text)
  (with-output-to-string (out)
    (loop for c across text do
      (case c
        (#\& (write-string "&amp;" out))
        (#\< (write-string "&lt;" out))
        (#\> (write-string "&gt;" out))
        (t   (write-char c out))))))

(defun replace-delimited (s open close forbidden wrap)
  "Replace every open<content>close (content a maximal run of chars /= FORBIDDEN),
   wrapping content via WRAP. Mirrors the racket regexp-replace*."
  (let ((n (length s)) (lo (length open)) (lc (length close)))
    (with-output-to-string (out)
      (labels ((emit-from (i)
                 (cond
                   ((>= i n))
                   ((substr-at? s i open)
                    (labels ((scan (k)
                               (cond
                                 ((and (< k n) (char/= (char s k) forbidden)) (scan (1+ k)))
                                 ((and (> k (+ i lo)) (substr-at? s k close))
                                  (write-string (funcall wrap (subseq s (+ i lo) k)) out)
                                  (emit-from (+ k lc)))
                                 (t (write-char (char s i) out) (emit-from (1+ i))))))
                      (scan (+ i lo))))
                   (t (write-char (char s i) out) (emit-from (1+ i))))))
        (emit-from 0)))))

(defun render-inline (text)
  (let* ((escaped    (html-escape text))
         (with-code  (replace-delimited escaped "`" "`" #\`
                       (lambda (c) (concatenate 'string "<code>" c "</code>"))))
         (with-strong (replace-delimited with-code "**" "**" #\*
                        (lambda (c) (concatenate 'string "<strong>" c "</strong>"))))
         (with-em    (replace-delimited with-strong "*" "*" #\*
                       (lambda (c) (concatenate 'string "<em>" c "</em>")))))
    with-em))

(defun split-lines (s)
  (let ((n (length s)))
    (loop with start = 0
          for i from 0 below n
          when (char= (char s i) #\Newline)
            collect (subseq s start i) into acc
            and do (setf start (1+ i))
          finally (return (append acc (list (subseq s start n)))))))

(defun render-markdown (source)
  (with-output-to-string (out)
    (let ((in-fence nil) (in-list nil))
      (flet ((close-list () (when in-list (write-string "</ul>
" out) (setf in-list nil))))
        (dolist (line (split-lines source))
          (cond
            (in-fence
             (if (fence-close? line)
                 (progn (write-string "</code></pre>
" out) (setf in-fence nil))
                 (progn (write-string (html-escape line) out) (write-char #\Newline out))))
            ((fence-line? line)
             (close-list)
             (write-string "<pre><code>" out)
             (setf in-fence t))
            ((heading-match line)
             (close-list)
             (let* ((m (heading-match line)) (level (car m)))
               (format out "<h~D>~A</h~D>~%" level (render-inline (cdr m)) level)))
            ((list-item-match line)
             (unless in-list (write-string "<ul>
" out) (setf in-list t))
             (format out "<li>~A</li>~%" (render-inline (list-item-match line))))
            ((blank-line? line)
             (close-list)
             (write-char #\Newline out))
            (t
             (close-list)
             (format out "<p>~A</p>~%" (render-inline line)))))
        (close-list)
        (when in-fence (write-string "</code></pre>
" out))))))

(defparameter +preview-template-head+
  (concatenate 'string
   "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"
   "<style>"
   "body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;"
   "padding:16px;line-height:1.5;color:#222}"
   "h1,h2,h3{margin-top:0.8em;margin-bottom:0.4em}"
   "code{background:#f4f4f4;padding:1px 4px;border-radius:3px;"
   "font-family:ui-monospace,SFMono-Regular,Menlo,monospace}"
   "pre{background:#f4f4f4;padding:12px;border-radius:6px;overflow:auto}"
   "pre code{background:none;padding:0}"
   ".placeholder{color:#888;font-style:italic}"
   "</style></head><body>"))
(defparameter +preview-template-foot+ "</body></html>")
(defparameter +preview-placeholder+
  "<p class=\"placeholder\">Start typing Markdown on the left…</p>")

;;; ============================================================
;;; File I/O — Lisp-native UTF-8 (the sbcl analogue of racket file->string /
;;; gerbil call-with-input-file). `read-file->string` slurps the whole file.
;;; ============================================================
(defun read-file->string (path)
  (with-open-file (in path :direction :input :external-format :utf-8
                          :element-type 'character)
    (let* ((len (file-length in))
           (buf (make-string (or len 0)))
           (n   (read-sequence buf in)))
      (subseq buf 0 n))))

(defun write-string->file (str path)
  (with-open-file (out path :direction :output :if-exists :supersede
                            :if-does-not-exist :create :external-format :utf-8
                            :element-type 'character)
    (write-string str out)))

;;; ---------------------------------------------------------------------------
;;; UI refresh / status / file ops (pure functions of the controller's slots; read
;;; with `slot-value`, not per-class accessors — they compile before the inner
;;; `define-objc-subclass` runs; the mini-browser / pdfkit-viewer pattern).
;;; ---------------------------------------------------------------------------
(defun set-status (controller text)
  (ns:set-string-value_ (slot-value controller 'status-label) (nsstr text)))

(defun display-name (controller)
  (let ((path (slot-value controller 'current-path)))
    (if path (basename path) "Untitled")))

(defun refresh-title (controller)
  "Window title + close-box dirty dot track the document name and the dirty flag."
  (let* ((window (slot-value controller 'window))
         (name   (display-name controller))
         (dirty  (slot-value controller 'dirty)))
    (ns:set-title_ window
      (nsstr (if dirty
                (concatenate 'string name " — edited — Note Editor")
                (concatenate 'string name " — Note Editor"))))
    (ns:set-document-edited_ window (if dirty t nil))))

(defun current-editor-text (controller)
  "The NSTextView's text. Editing methods live on the NSText superclass (`ns:string`)."
  (ns->str (ns:string (slot-value controller 'text-view))))

(defun render-preview (controller markdown-text)
  "Render MARKDOWN-TEXT (or the placeholder, if blank) into the WKWebView via
   loadHTMLString:baseURL: (nil base URL)."
  (let ((body (if (string= (trim-both markdown-text) "")
                  +preview-placeholder+
                  (render-markdown markdown-text))))
    (ns:load-html-string_base-url_ (slot-value controller 'web-view)
      (nsstr (concatenate 'string +preview-template-head+ body +preview-template-foot+))
      nil)))

(defun refresh-preview (controller)
  (render-preview controller (current-editor-text controller)))

(defun load-file (controller path)
  (handler-case
      (let ((text (read-file->string path)))
        (ns:set-string_ (slot-value controller 'text-view) (nsstr text))
        (setf (slot-value controller 'current-path) path
              (slot-value controller 'dirty) nil)
        (refresh-title controller)
        (refresh-preview controller)
        (set-status controller (concatenate 'string "Opened " path))
        t)
    (error () (set-status controller (concatenate 'string "Open failed: " path)) nil)))

(defun write-current-file (controller path)
  (handler-case
      (progn
        (write-string->file (current-editor-text controller) path)
        (setf (slot-value controller 'current-path) path
              (slot-value controller 'dirty) nil)
        (refresh-title controller)
        (set-status controller (concatenate 'string "Saved " path))
        t)
    (error () (set-status controller (concatenate 'string "Save failed: " path)) nil)))

;;; Unsaved-changes confirmation (NSAlert).
(defun confirm-discard? (controller message)
  (if (not (slot-value controller 'dirty))
      t
      (let ((alert (make-instance 'ns:ns-alert)))
        (ns:set-alert-style_ alert ns:ns-alert-style-warning)
        (ns:set-message-text_ alert (nsstr message))
        (ns:set-informative-text_ alert (nsstr "Your changes will be lost if you continue."))
        (ns:add-button-with-title_ alert @"Discard")
        (ns:add-button-with-title_ alert @"Cancel")
        (= (ns:run-modal alert) +ns-alert-first-button-return+))))

;;; --- Save via the completion BLOCK (the `aw-block` bridge). The handler closure is
;;; bounced to main and re-entered through the one block dispatcher; `response` arrives as
;;; a raw SAP (the NSModalResponse), read with `sb-sys:sap-int`. ---
(defun prompt-save (controller)
  (let ((panel  (ns:save-panel (find-class 'ns:ns-save-panel)))
        (window (slot-value controller 'window)))
    (ns:set-can-create-directories_ panel t)
    (ns:set-name-field-string-value_ panel
      (nsstr (if (slot-value controller 'current-path) (display-name controller) "untitled.md")))
    (ns:begin-sheet-modal-for-window_completion-handler_ panel window
      (lambda (response)
        (when (= (sb-sys:sap-int response) +ns-modal-response-ok+)
          (let ((url (ns:url panel)))
            (when url
              (let ((raw-path (ns->str (ns:path url))))
                (unless (string= raw-path "")
                  (write-current-file controller raw-path))))))))))

(defun do-save (controller)
  (let ((path (slot-value controller 'current-path)))
    (if path (write-current-file controller path) (prompt-save controller))))

;;; Open via runModal (NSOpenPanel; allowed types via an NSMutableArray of strings).
(defun markdown-extensions ()
  (let ((a (make-instance 'ns:ns-mutable-array :init-with-capacity 3)))
    (dolist (e '("md" "markdown" "txt")) (ns:add-object_ a (nsstr e)))
    a))

(defun do-open (controller)
  (when (confirm-discard? controller "Discard unsaved changes?")
    (let ((panel (ns:open-panel (find-class 'ns:ns-open-panel))))
      (ns:set-can-choose-files_ panel t)
      (ns:set-can-choose-directories_ panel nil)
      (ns:set-allows-multiple-selection_ panel nil)
      (ns:set-allowed-file-types_ panel (markdown-extensions))
      (when (= (ns:run-modal panel) +ns-modal-response-ok+)
        (let ((url (ns:url panel)))
          (when url (load-file controller (ns->str (ns:path url)))))))))

(defun do-new (controller)
  (when (confirm-discard? controller "Discard unsaved changes and start a new note?")
    (ns:set-string_ (slot-value controller 'text-view) @"")
    (setf (slot-value controller 'current-path) nil
          (slot-value controller 'dirty) nil)
    (refresh-title controller)
    (refresh-preview controller)
    (set-status controller "New document")))

;;; Undo / Redo via the NSTextView's undo manager (on NSResponder).
(defun do-undo (controller)
  (let ((mgr (ns:undo-manager (slot-value controller 'text-view))))
    (when (and mgr (ns:can-undo mgr)) (ns:undo mgr))))
(defun do-redo (controller)
  (let ((mgr (ns:undo-manager (slot-value controller 'text-view))))
    (when (and mgr (ns:can-redo mgr)) (ns:redo mgr))))

;;; ---------------------------------------------------------------------------
;;; The controller — a real ObjC subclass of NSObject holding the live UI refs +
;;; editor state as slots. Defined INSIDE a function so it re-synthesizes in a revived
;;; dumped image (the ObjC class pair + dispatch routing did not survive the dump;
;;; defclass/defmethod re-evaluation is idempotent).
;;; ---------------------------------------------------------------------------
(defvar *note-controller-ready* nil
  "nil until `ensure-note-controller` has defined the class in THIS process. A revived
   image starts nil again and re-defines.")

(defun ensure-note-controller ()
  "Define the `note-controller` ObjC subclass + its six selectors. Called from `-main` so
   it runs in whatever process shows the UI (host pre-flight or revived dump). Idempotent
   within a process via `*note-controller-ready*`."
  (unless *note-controller-ready*
    (define-objc-subclass note-controller (ns:ns-object)
      (:slots
       (text-view    :initarg :text-view)
       (web-view     :initarg :web-view)
       (status-label :initarg :status-label)
       (window       :initarg :window)
       (current-path :initform nil)
       (dirty        :initform nil)))

    ;; --- Toolbar target-actions (synthesized default v@:@; sender ignored) ---
    (define-objc-method (note-controller "newDoc:") (self sender)
      (declare (ignore sender)) (do-new self))
    (define-objc-method (note-controller "openDoc:") (self sender)
      (declare (ignore sender)) (do-open self))
    (define-objc-method (note-controller "saveDoc:") (self sender)
      (declare (ignore sender)) (do-save self))
    (define-objc-method (note-controller "undoDoc:") (self sender)
      (declare (ignore sender)) (do-undo self))
    (define-objc-method (note-controller "redoDoc:") (self sender)
      (declare (ignore sender)) (do-redo self))

    ;; --- NSTextDidChangeNotification observer: mark dirty + re-render the preview.
    ;; Fires on every keystroke; the controller is pinned in *subclass-instances* (a
    ;; STRONG table), so the per-keystroke allocation never reaps it (the gerbil
    ;; weak-delegate GC bug cannot recur on sbcl). ---
    (define-objc-method (note-controller "textDidChange:") (self note)
      (declare (ignore note))
      (unless (slot-value self 'dirty)
        (setf (slot-value self 'dirty) t)
        (refresh-title self))
      (refresh-preview self))

    (setf *note-controller-ready* t)))

;;; ---------------------------------------------------------------------------
;;; The window.
;;; ---------------------------------------------------------------------------
(defun note-editor-main (&key (run t))
  "Build the Note-Editor UI and, unless RUN is nil, enter the AppKit run loop.

   RUN nil is the host construction PRE-FLIGHT (060): it synthesizes the controller
   class, builds the window + every control, wires target-action + the text-change
   observer, renders the initial preview (loadHTMLString — a WKWebView FFI crossing), AND
   constructs an `aw-block` to prove the block bridge is live in THIS image — then returns
   WITHOUT blocking on `-run`, so a bare `sbcl --load` validates marshalling (and, in the
   revived image, the startup re-resolution — frameworks, dispatcher, block dispatcher,
   constant surface — plus re-synthesis) before the VM round-trip. The dumped image's
   toplevel calls RUN t."
  (ensure-note-controller)
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Note Editor")
    (aw-with-rect (frame 0 0 +window-w+ +window-h+)
      (let* ((window (make-instance 'ns:ns-window
                       :init-with-content-rect frame
                       :style-mask (logior ns:ns-window-style-mask-titled
                                           ns:ns-window-style-mask-closable
                                           ns:ns-window-style-mask-miniaturizable
                                           ns:ns-window-style-mask-resizable)
                       :backing ns:ns-backing-store-buffered
                       :defer nil))
             (content (ns:content-view window)))
        (ns:center window)
        (aw-with-size (minsz 520 360) (ns:set-min-size_ window minsz))

        (let* ((toolbar-y (- +window-h+ +margin+ +toolbar-h+))
               (split-y   +margin+)
               (split-h   (- toolbar-y split-y +margin+))
               (split-w   (- +window-w+ (* 2 +margin+)))
               (editor-w  (floor split-w 2))
               ;; --- Editor: NSTextView in an NSScrollView ---
               (text-view    (aw-with-rect (tf 0 0 editor-w split-h)
                               (make-instance 'ns:ns-text-view :init-with-frame tf)))
               (editor-scroll (aw-with-rect (sf 0 0 editor-w split-h)
                                (make-instance 'ns:ns-scroll-view :init-with-frame sf)))
               ;; --- Preview: WKWebView ---
               (web-config (make-instance 'ns:wk-web-view-configuration))
               (web-view   (aw-with-rect (wf 0 0 (- split-w editor-w) split-h)
                             (make-instance 'ns:wk-web-view
                               :init-with-frame wf :configuration web-config)))
               ;; --- Split view ---
               (split-view (make-instance 'ns:ns-split-view))
               ;; --- Toolbar controls ---
               (new-button    (make-instance 'ns:ns-button))
               (open-button   (make-instance 'ns:ns-button))
               (save-button   (make-instance 'ns:ns-button))
               (undo-button   (make-instance 'ns:ns-button))
               (redo-button   (make-instance 'ns:ns-button))
               (status-label  (make-instance 'ns:ns-text-field))
               (toolbar-stack (make-instance 'ns:ns-stack-view)))

          ;; --- Toolbar buttons ---
          (loop for (btn . title) in (list (cons new-button "New")  (cons open-button "Open…")
                                           (cons save-button "Save…") (cons undo-button "Undo")
                                           (cons redo-button "Redo"))
                do (ns:set-title_ btn (nsstr title))
                   (ns:set-bezel-style_ btn ns:ns-bezel-style-rounded))

          ;; --- Status label ---
          (ns:set-string-value_ status-label @"Ready")
          (ns:set-font_ status-label (ns:system-font-of-size_ (find-class 'ns:ns-font) 11.0d0))
          (ns:set-editable_ status-label nil)
          (ns:set-selectable_ status-label nil)
          (ns:set-bezeled_ status-label nil)
          (ns:set-draws-background_ status-label nil)

          ;; --- Toolbar: horizontal stack pinned to the top edge ---
          (aw-with-rect (tframe +margin+ toolbar-y split-w +toolbar-h+)
            (ns:set-frame_ toolbar-stack tframe))
          (ns:set-orientation_ toolbar-stack ns:ns-user-interface-layout-orientation-horizontal)
          (ns:set-alignment_ toolbar-stack ns:ns-layout-attribute-first-baseline)
          (ns:set-spacing_ toolbar-stack 8.0d0)
          (dolist (v (list new-button open-button save-button undo-button redo-button status-label))
            (ns:add-arranged-subview_ toolbar-stack v))
          (ns:set-autoresizing-mask_ toolbar-stack
            (logior ns:ns-view-width-sizable ns:ns-view-min-y-margin))
          (ns:add-subview_ content toolbar-stack)

          ;; --- Split view (vertical divider → side-by-side panes) ---
          (aw-with-rect (spframe +margin+ split-y split-w split-h)
            (ns:set-frame_ split-view spframe))
          (ns:set-vertical_ split-view t)
          (ns:set-autoresizing-mask_ split-view
            (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))
          (ns:add-subview_ content split-view)

          ;; --- Editor pane ---
          (ns:set-editable_ text-view t)
          (ns:set-rich-text_ text-view nil)
          (ns:set-allows-undo_ text-view t)
          (ns:set-uses-find-bar_ text-view t)
          (ns:set-font_ text-view (ns:user-fixed-pitch-font-of-size_ (find-class 'ns:ns-font) 13.0d0))
          (ns:set-horizontally-resizable_ text-view nil)
          (ns:set-autoresizing-mask_ text-view
            (logior ns:ns-view-width-sizable ns:ns-view-height-sizable))

          (ns:set-has-vertical-scroller_ editor-scroll t)
          (ns:set-has-horizontal-scroller_ editor-scroll nil)
          (ns:set-document-view_ editor-scroll text-view)
          (ns:add-subview_ split-view editor-scroll)

          ;; --- Preview pane ---
          (ns:add-subview_ split-view web-view)

          ;; --- The controller, holding the live controls + editor state. ---
          (let ((controller (make-instance 'note-controller
                              :text-view text-view
                              :web-view web-view
                              :status-label status-label
                              :window window)))

            ;; Initial empty preview (placeholder).
            (render-preview controller "")

            ;; --- Text-change observer wiring (source filter = the text view). The name is
            ;; the re-resolved `NSTextDidChangeNotification` AppKit constant; the selector is
            ;; passed as a string (the runtime calls `aw-sel` on it). ---
            (ns:add-observer_selector_name_object_
              (ns:default-center (find-class 'ns:ns-notification-center))
              controller
              "textDidChange:"
              ns:ns-text-did-change-notification
              text-view)

            ;; --- Toolbar target-action wiring (after the controller exists) ---
            (loop for (btn . sel) in (list (cons new-button "newDoc:") (cons open-button "openDoc:")
                                           (cons save-button "saveDoc:") (cons undo-button "undoDoc:")
                                           (cons redo-button "redoDoc:"))
                  do (ns:set-target_ btn controller) (ns:set-action_ btn sel))

            (refresh-title controller)

            ;; --- Block-bridge liveness gate (host pre-flight evidence): `aw-block` must
            ;; project a closure to a non-null block SAP in THIS image. The real save
            ;; handler is constructed identically inside `prompt-save`. ---
            (let ((probe (aw-block (lambda (r) (declare (ignore r)) nil))))
              (when (aw-null-sap-p probe)
                (error "note-editor: aw-block returned a null block — block dispatcher not ~
                        registered (run `aw-init-block-dispatcher` after `aw-load-native-dylib`)")))

            ;; --- Show + run ---
            (ns:make-key-and-order-front_ window nil)
            (ns:activate-ignoring-other-apps_ app t)
            (when run
              (format t "~&Note Editor opened. Type Markdown on the left; preview renders on the right. Quit with Cmd-Q.~%")
              (finish-output)
              (ns:run app))
            controller))))))
