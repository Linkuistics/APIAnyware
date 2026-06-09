;;; note-editor.ss — Note Editor sample app (gerbil target). The capstone.
;;;
;;; Markdown editor with live HTML preview. Left pane is an NSTextView (in an
;;; NSScrollView); right pane is a WKWebView that re-renders the Markdown as HTML
;;; on every NSTextDidChangeNotification. Mirrors
;;; generation/targets/chez/apps/note-editor/note-editor.sls one piece at a time.
;;;
;;; The widest feature surface of any gerbil sample, and the FIRST to cross a
;;; **block bridge**: NSSavePanel's beginSheetModalForWindow:completionHandler:
;;; takes an ObjC block, supplied via `make-objc-block` (runtime native core,
;;; ADR-0017). The handler runs asynchronously when the sheet dismisses,
;;; re-entering Gerbil through the block trampoline — the block analogue of the
;;; WKNavigationDelegate callbacks in mini-browser. It fires on the main thread,
;;; so the ADR-0022 path runs it directly.
;;;
;;; Also exercises: NSTextView + NSScrollView + NSSplitView, NSUndoManager
;;; (undo/redo), NSAlert confirmations, NSOpenPanel (runModal), an
;;; NSTextDidChangeNotification observer, and hand-rolled Markdown→HTML + file I/O.
;;;
;;; Gerbil idiom notes:
;;;   - Editing methods live on the NSText superclass: `nstext-string`,
;;;     `nstext-set-string!`, `nstext-set-font!`, `nstext-set-horizontally-resizable!`;
;;;     `undoManager` is on NSResponder (`nsresponder-undo-manager`).
;;;   - `make-objc-block` boxes the Scheme completion proc; the block's
;;;     NSModalResponse (NSInteger) arg uses the 'int64 token (→ ptr->int).
;;;   - `with-catch` replaces R6RS `guard`; `string-append` replaces `format`;
;;;     file I/O is plain Gambit `call-with-input/output-file`.
;;;
;;; Build via bundle-gerbil; uses the bottle toolchain.
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nsresponder
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nsbutton
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/nsstackview
        :gerbil-bindings/appkit/nstext
        :gerbil-bindings/appkit/nstextview
        :gerbil-bindings/appkit/nsscrollview
        :gerbil-bindings/appkit/nssplitview
        :gerbil-bindings/appkit/nsalert
        :gerbil-bindings/appkit/nsopenpanel
        :gerbil-bindings/appkit/nssavepanel
        :gerbil-bindings/appkit/nsfont
        :gerbil-bindings/appkit/enums
        :gerbil-bindings/appkit/constants
        :gerbil-bindings/foundation/nsurl
        :gerbil-bindings/foundation/nsundomanager
        :gerbil-bindings/foundation/nsnotificationcenter
        :gerbil-bindings/foundation/nsmutablearray
        :gerbil-bindings/webkit/wkwebview
        :gerbil-bindings/webkit/wkwebviewconfiguration)
(export main)

;; --- Constants the collector has not extracted (parity with racket/chez) ---
(def NSModalResponseOK    1)
(def NSAlertFirstButtonReturn 1000)

;; --- Window geometry ---
(def WINDOW-W 900.)
(def WINDOW-H 600.)
(def TOOLBAR-H 32.)
(def MARGIN 12.)

;; --- NSString object → Scheme string (wrap→#f for nil → ""). ---
(def (ns->str obj) (if obj (nsstring->string (->ptr obj)) ""))

;; ============================================================
;; String + path helpers
;; ============================================================
(def (trim-both s)
  (let* ((n (string-length s))
         (start (let loop ((i 0))
                  (if (and (< i n) (char-whitespace? (string-ref s i))) (loop (+ i 1)) i)))
         (end (let loop ((j n))
                (if (and (> j start) (char-whitespace? (string-ref s (- j 1)))) (loop (- j 1)) j))))
    (substring s start end)))

(def (basename path)
  (let loop ((i (- (string-length path) 1)))
    (cond
      ((< i 0) path)
      ((char=? (string-ref path i) #\/) (substring path (+ i 1) (string-length path)))
      (else (loop (- i 1))))))

;; ============================================================
;; Markdown → HTML (hand-rolled; mirrors the racket/chez renderer)
;; ============================================================
(def (substr-at? s i sub)
  (let ((ls (string-length sub)) (n (string-length s)))
    (and (<= (+ i ls) n)
         (let loop ((j 0))
           (cond
             ((= j ls) #t)
             ((char=? (string-ref s (+ i j)) (string-ref sub j)) (loop (+ j 1)))
             (else #f))))))

(def (string-prefix? prefix s) (substr-at? s 0 prefix))

(def (all-whitespace-from? s start)
  (let ((n (string-length s)))
    (let loop ((i start))
      (cond ((= i n) #t)
            ((char-whitespace? (string-ref s i)) (loop (+ i 1)))
            (else #f)))))

(def (blank-line? s) (all-whitespace-from? s 0))
(def (fence-line? s) (string-prefix? "```" s))
(def (fence-close? s) (and (fence-line? s) (all-whitespace-from? s 3)))

;; ATX heading: 1-6 '#', then whitespace, then text → (cons level text) or #f.
(def (heading-match s)
  (let ((n (string-length s)))
    (let count ((i 0))
      (cond
        ((and (< i n) (char=? (string-ref s i) #\#)) (count (+ i 1)))
        ((and (>= i 1) (<= i 6) (< i n) (char-whitespace? (string-ref s i)))
         (let skip ((j i))
           (if (and (< j n) (char-whitespace? (string-ref s j))) (skip (+ j 1))
               (cons i (substring s j n)))))
        (else #f)))))

;; Unordered-list item: -/*/+ marker + whitespace + text → text or #f.
(def (list-item-match s)
  (let ((n (string-length s)))
    (and (>= n 2)
         (memv (string-ref s 0) '(#\- #\* #\+))
         (char-whitespace? (string-ref s 1))
         (let skip ((j 1))
           (if (and (< j n) (char-whitespace? (string-ref s j))) (skip (+ j 1))
               (substring s j n))))))

(def (html-escape text)
  (let ((out (open-output-string)) (n (string-length text)))
    (let loop ((i 0))
      (if (= i n) (get-output-string out)
          (begin
            (case (string-ref text i)
              ((#\&) (display "&amp;" out))
              ((#\<) (display "&lt;" out))
              ((#\>) (display "&gt;" out))
              (else (write-char (string-ref text i) out)))
            (loop (+ i 1)))))))

;; Replace every open<content>close (content a maximal run of chars != forbidden),
;; wrapping content via `wrap`. Mirrors the racket regexp-replace*.
(def (replace-delimited s open close forbidden wrap)
  (let ((n (string-length s)) (lo (string-length open)) (lc (string-length close))
        (out (open-output-string)))
    (let loop ((i 0))
      (cond
        ((>= i n) (get-output-string out))
        ((substr-at? s i open)
         (let scan ((k (+ i lo)))
           (cond
             ((and (< k n) (not (char=? (string-ref s k) forbidden))) (scan (+ k 1)))
             ((and (> k (+ i lo)) (substr-at? s k close))
              (display (wrap (substring s (+ i lo) k)) out)
              (loop (+ k lc)))
             (else (write-char (string-ref s i) out) (loop (+ i 1))))))
        (else (write-char (string-ref s i) out) (loop (+ i 1)))))))

(def (render-inline text)
  (let* ((escaped (html-escape text))
         (with-code (replace-delimited escaped "`" "`" #\`
                      (lambda (c) (string-append "<code>" c "</code>"))))
         (with-strong (replace-delimited with-code "**" "**" #\*
                        (lambda (c) (string-append "<strong>" c "</strong>"))))
         (with-em (replace-delimited with-strong "*" "*" #\*
                    (lambda (c) (string-append "<em>" c "</em>")))))
    with-em))

(def (split-lines s)
  (let ((n (string-length s)))
    (let loop ((start 0) (i 0) (acc '()))
      (cond
        ((= i n) (reverse (cons (substring s start n) acc)))
        ((char=? (string-ref s i) #\newline)
         (loop (+ i 1) (+ i 1) (cons (substring s start i) acc)))
        (else (loop start (+ i 1) acc))))))

(def (render-markdown source)
  (let ((out (open-output-string)))
    (let loop ((lines (split-lines source)) (in-fence? #f) (in-list? #f))
      (if (null? lines)
        (begin
          (when in-list? (display "</ul>\n" out))
          (when in-fence? (display "</code></pre>\n" out))
          (get-output-string out))
        (let ((line (car lines)) (rest (cdr lines)))
          (cond
            (in-fence?
             (if (fence-close? line)
               (begin (display "</code></pre>\n" out) (loop rest #f in-list?))
               (begin (display (html-escape line) out) (display "\n" out) (loop rest #t in-list?))))
            ((fence-line? line)
             (when in-list? (display "</ul>\n" out))
             (display "<pre><code>" out)
             (loop rest #t #f))
            ((heading-match line)
             => (lambda (m)
                  (when in-list? (display "</ul>\n" out))
                  (let ((level (car m)))
                    (display "<h" out) (display level out) (display ">" out)
                    (display (render-inline (cdr m)) out)
                    (display "</h" out) (display level out) (display ">\n" out))
                  (loop rest #f #f)))
            ((list-item-match line)
             => (lambda (item-text)
                  (unless in-list? (display "<ul>\n" out))
                  (display "<li>" out) (display (render-inline item-text) out) (display "</li>\n" out)
                  (loop rest #f #t)))
            ((blank-line? line)
             (when in-list? (display "</ul>\n" out))
             (display "\n" out)
             (loop rest #f #f))
            (else
             (when in-list? (display "</ul>\n" out))
             (display "<p>" out) (display (render-inline line) out) (display "</p>\n" out)
             (loop rest #f #f))))))))

(def PREVIEW-TEMPLATE-HEAD
  (string-append
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
(def PREVIEW-TEMPLATE-FOOT "</body></html>")
(def PREVIEW-PLACEHOLDER "<p class=\"placeholder\">Start typing Markdown on the left…</p>")

;; ============================================================
;; File I/O (UTF-8, plain Gambit; read-line with #f separator reads to EOF)
;; ============================================================
(def (read-file->string path)
  (call-with-input-file path
    (lambda (port) (let (s (read-line port #f)) (if (eof-object? s) "" s)))))

(def (write-string->file str path)
  (call-with-output-file path (lambda (port) (display str port))))

;; ============================================================
;; Application
;; ============================================================
(define-entry-point (main)
  ;; --- Definitions ---
  (def app (nsapplication-shared-application))

  (def window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-rect 0. 0. WINDOW-W WINDOW-H)
      (bitwise-ior NSWindowStyleMaskTitled NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable NSWindowStyleMaskResizable)
      NSBackingStoreBuffered #f))

  (def content-view (nswindow-content-view window))

  ;; Editor state
  (def current-path #f)
  (def dirty? #f)

  ;; Toolbar controls
  (def new-button   (make-nsbutton))
  (def open-button  (make-nsbutton))
  (def save-button  (make-nsbutton))
  (def undo-button  (make-nsbutton))
  (def redo-button  (make-nsbutton))
  (def status-label (make-nstextfield))
  (def toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
  (def toolbar-stack (make-nsstackview))

  ;; Split view: editor (left) + preview (right)
  (def split-y MARGIN)
  (def split-h (- toolbar-y split-y MARGIN))
  (def split-w (- WINDOW-W (* 2. MARGIN)))
  (def split-view (make-nssplitview))
  (def editor-w (/ split-w 2.))

  (def text-view (make-nstextview-init-with-frame (make-rect 0. 0. editor-w split-h)))
  (def editor-scroll (make-nsscrollview-init-with-frame (make-rect 0. 0. editor-w split-h)))
  (def web-config (make-wkwebviewconfiguration))
  (def web-view
    (make-wkwebview-init-with-frame-configuration
      (make-rect 0. 0. (- split-w editor-w) split-h) web-config))

  (def (set-status! text) (nscontrol-set-string-value! status-label (string->nsstring text)))

  ;; Title / dirty indicator
  (def (display-name) (if current-path (basename current-path) "Untitled"))
  (def (refresh-title!)
    (let (name (display-name))
      (nswindow-set-title! window
        (string->nsstring
          (if dirty? (string-append name " — edited — Note Editor")
              (string-append name " — Note Editor"))))
      (nswindow-set-document-edited! window dirty?)))

  ;; Editor text + preview
  (def (current-editor-text) (ns->str (nstext-string text-view)))
  (def (render-preview! markdown-text)
    (let (body (if (string=? (trim-both markdown-text) "")
                 PREVIEW-PLACEHOLDER
                 (render-markdown markdown-text)))
      (wkwebview-load-html-string-base-url web-view
        (string->nsstring (string-append PREVIEW-TEMPLATE-HEAD body PREVIEW-TEMPLATE-FOOT))
        #f)))
  (def (refresh-preview!) (render-preview! (current-editor-text)))

  ;; File operations
  (def (load-file! path)
    (with-catch
      (lambda (e) (set-status! (string-append "Open failed: " path)) #f)
      (lambda ()
        (let (text (read-file->string path))
          (nstext-set-string! text-view (string->nsstring text))
          (set! current-path path) (set! dirty? #f)
          (refresh-title!) (refresh-preview!)
          (set-status! (string-append "Opened " path)) #t))))

  (def (write-current-file! path)
    (with-catch
      (lambda (e) (set-status! (string-append "Save failed: " path)) #f)
      (lambda ()
        (write-string->file (current-editor-text) path)
        (set! current-path path) (set! dirty? #f)
        (refresh-title!)
        (set-status! (string-append "Saved " path)) #t)))

  ;; Unsaved-changes confirmation
  (def (confirm-discard? message)
    (if (not dirty?) #t
        (let (alert (make-nsalert))
          (nsalert-set-alert-style! alert NSAlertStyleWarning)
          (nsalert-set-message-text! alert (string->nsstring message))
          (nsalert-set-informative-text! alert
            (string->nsstring "Your changes will be lost if you continue."))
          (nsalert-add-button-with-title! alert (string->nsstring "Discard"))
          (nsalert-add-button-with-title! alert (string->nsstring "Cancel"))
          (= (nsalert-run-modal alert) NSAlertFirstButtonReturn))))

  ;; Save via completion block (the make-objc-block bridge). `response` is the
  ;; NSModalResponse NSInteger, delivered through the 'int64 token.
  (def (prompt-save!)
    (let (panel (nssavepanel-save-panel))
      (nssavepanel-set-can-create-directories! panel #t)
      (with-catch (lambda (e) (void))
        (lambda ()
          (nssavepanel-set-name-field-string-value! panel
            (string->nsstring (if current-path (display-name) "untitled.md")))))
      (nssavepanel-begin-sheet-modal-for-window-completion-handler!
        panel window
        (make-objc-block
          (lambda (response)
            (when (= response NSModalResponseOK)
              (let (url (nssavepanel-url panel))
                (when url
                  (let (raw-path (ns->str (nsurl-path url)))
                    (unless (string=? raw-path "")
                      (write-current-file! raw-path)))))))
          (list 'int64) 'void))))

  (def (do-save!) (if current-path (write-current-file! current-path) (prompt-save!)))

  ;; Open via run-modal (NSOpenPanel; allowed types via NSMutableArray)
  (def markdown-extensions
    (let (a (make-nsmutablearray-init-with-capacity 3))
      (for-each (lambda (e) (nsmutablearray-add-object! a (string->nsstring e)))
                '("md" "markdown" "txt"))
      a))

  (def (do-open!)
    (when (confirm-discard? "Discard unsaved changes?")
      (let (panel (nsopenpanel-open-panel))
        (nsopenpanel-set-can-choose-files! panel #t)
        (nsopenpanel-set-can-choose-directories! panel #f)
        (nsopenpanel-set-allows-multiple-selection! panel #f)
        (nssavepanel-set-allowed-file-types! panel markdown-extensions)
        (when (= (nssavepanel-run-modal panel) NSModalResponseOK)
          (let (url (nssavepanel-url panel))
            (when url (load-file! (ns->str (nsurl-path url)))))))))

  (def (do-new!)
    (when (confirm-discard? "Discard unsaved changes and start a new note?")
      (nstext-set-string! text-view (string->nsstring ""))
      (set! current-path #f) (set! dirty? #f)
      (refresh-title!) (refresh-preview!)
      (set-status! "New document")))

  ;; Undo / Redo via NSTextView's undo manager (on NSResponder)
  (def (do-undo!)
    (let (mgr (nsresponder-undo-manager text-view))
      (when (and mgr (nsundomanager-can-undo mgr)) (nsundomanager-undo mgr))))
  (def (do-redo!)
    (let (mgr (nsresponder-undo-manager text-view))
      (when (and mgr (nsundomanager-can-redo mgr)) (nsundomanager-redo mgr))))

  ;; Toolbar target-action delegate (one record, five selectors)
  (def ui-target
    (make-delegate
      (list
        (list "newDoc:"  (lambda (s) (do-new!))  (list 'object) 'void)
        (list "openDoc:" (lambda (s) (do-open!)) (list 'object) 'void)
        (list "saveDoc:" (lambda (s) (do-save!)) (list 'object) 'void)
        (list "undoDoc:" (lambda (s) (do-undo!)) (list 'object) 'void)
        (list "redoDoc:" (lambda (s) (do-redo!)) (list 'object) 'void))))

  ;; Text-change observer: NSTextDidChangeNotification → mark dirty + re-render.
  (def text-change-observer
    (make-delegate
      (list
        (list "textDidChange:"
              (lambda (note)
                (unless dirty? (set! dirty? #t) (refresh-title!))
                (refresh-preview!))
              (list 'object) 'void))))

  ;; --- Expressions ---
  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (install-standard-app-menu! app "Note Editor")

  (nswindow-center! window)
  (nswindow-set-min-size! window (make-size 520. 360.))

  ;; Toolbar controls
  (for-each
    (lambda (pair)
      (nsbutton-set-title! (car pair) (string->nsstring (cdr pair)))
      (nsbutton-set-bezel-style! (car pair) NSBezelStyleRounded))
    (list (cons new-button "New") (cons open-button "Open…") (cons save-button "Save…")
          (cons undo-button "Undo") (cons redo-button "Redo")))

  (nscontrol-set-string-value! status-label (string->nsstring "Ready"))
  (nscontrol-set-font! status-label (nsfont-system-font-of-size 11.))
  (nscontrol-set-alignment! status-label NSTextAlignmentLeft)
  (nstextfield-set-editable! status-label #f)
  (nstextfield-set-selectable! status-label #f)
  (nstextfield-set-bezeled! status-label #f)
  (nstextfield-set-draws-background! status-label #f)

  (nsview-set-frame! toolbar-stack (make-rect MARGIN toolbar-y split-w TOOLBAR-H))
  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.)
  (for-each (lambda (v) (nsstackview-add-arranged-subview! toolbar-stack v))
            (list new-button open-button save-button undo-button redo-button status-label))
  (nsview-set-autoresizing-mask! toolbar-stack (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; Split view (vertical divider → side-by-side panes)
  (nsview-set-frame! split-view (make-rect MARGIN split-y split-w split-h))
  (nssplitview-set-vertical! split-view #t)
  (nsview-set-autoresizing-mask! split-view (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view split-view)

  ;; Editor pane
  (nstextview-set-editable! text-view #t)
  (nstextview-set-rich-text! text-view #f)
  (nstextview-set-allows-undo! text-view #t)
  (nstextview-set-uses-find-bar! text-view #t)
  (nstext-set-font! text-view (nsfont-user-fixed-pitch-font-of-size 13.))
  (nstext-set-horizontally-resizable! text-view #f)
  (nsview-set-autoresizing-mask! text-view (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

  (nsscrollview-set-has-vertical-scroller! editor-scroll #t)
  (nsscrollview-set-has-horizontal-scroller! editor-scroll #f)
  (nsscrollview-set-document-view! editor-scroll text-view)
  (nsview-add-subview! split-view editor-scroll)

  ;; Preview pane
  (nsview-add-subview! split-view web-view)
  (render-preview! "")

  ;; Text-change observer wiring (source = the text view)
  (nsnotificationcenter-add-observer-selector-name-object!
    (nsnotificationcenter-default-center)
    text-change-observer
    "textDidChange:"
    NSTextDidChangeNotification
    text-view)

  ;; Toolbar target-action wiring
  (for-each
    (lambda (pair)
      (nscontrol-set-target! (car pair) ui-target)
      (nscontrol-set-action! (car pair) (cdr pair)))
    (list (cons new-button "newDoc:") (cons open-button "openDoc:") (cons save-button "saveDoc:")
          (cons undo-button "undoDoc:") (cons redo-button "redoDoc:")))

  ;; Show window and run
  (refresh-title!)
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  (displayln "Note Editor running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

(main)
