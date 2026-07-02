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
;;; Instrumented for the AppSpec scenario runner per the Note Editor logging
;;; contract (apps/macos/note-editor/docs/logging-contract.md): it writes a
;;; structured events.log the runner tails — [lifecycle] startup/shutdown, the
;;; bare launch line, the six [document] document-state events (the save sheet
;;; resolves on its own schedule, so save completion is not assertable without
;;; a log record), and the [preview] rendered hand-off event (render completion
;;; is entirely unobservable, §5.4). Under `launch-via 'open` LaunchServices
;;; discards the app's stdout, so the log file (not stdout) is the runner's
;;; read path; the stdout line is kept too (human-friendly when run unbundled).
;;;
;;; The logging is inlined here rather than split to a sibling events.ss for
;;; the same reason as the prior instrumented gerbil apps: the bundler's
;;; closure walk (deps.rs) follows only `:gerbil-bindings/…` references, and
;;; these defines use only Gambit primitives (open-output-file, getenv,
;;; create-directory, force-output), so they ride the statically-linked
;;; prelude with no new import.
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
        ;; except string-length: the k116 WebKit corpus flattens a `stringLength`
        ;; selector onto WKWebView (conformed-protocol member), so wkwebview.ss
        ;; re-exports a `string-length` GENERIC that shadows the Gambit builtin —
        ;; generic dispatch then fails on plain Scheme strings (the same shadow
        ;; class as the `values` coerce gotcha; this module calls the builtin
        ;; throughout the Markdown renderer, the string/path helpers, and the
        ;; event-log helpers). The app never sends stringLength to the web view,
        ;; so excluding it is loss-free.
        (except-in :gerbil-bindings/webkit/wkwebview string-length)
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

;; --- Structured event log (logging contract) -------------------------------
;; Single writer: every event is emitted on the main thread — startup, the
;; initial render, and the launch line before -run; the [document]/[preview]
;; events from the five action handlers, the text-change notification
;; observer, and the save sheet's completion handler (all delivered by AppKit
;; on the main thread; the ADR-0022 trampoline calls the Gerbil body directly
;; there); shutdown on the terminate path — so one port with a post-write
;; force-output suffices (no lock needed).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (NOTE_EDITOR_EVENTS_LOG)
;; propagates through LaunchServices.
(define ne-default-events-path "/tmp/note-editor/events.log")
(define ne-events-port #f)

;; NOTE_EDITOR_EVENTS_LOG if set and non-empty, else the fixed default.
(define (ne-resolve-events-path)
  (let ((env (getenv "NOTE_EDITOR_EVENTS_LOG" #f)))
    (if (and env (not (string=? env ""))) env ne-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (ne-path-parent p)
  (let loop ((i (- (string-length p) 1)))
    (cond
      ((< i 0) #f)
      ((char=? (string-ref p i) #\/) (substring p 0 i))
      (else (loop (- i 1))))))

;; Open + truncate the events.log: (create: 'maybe truncate: #t) creates it if
;; absent and truncates it if present. The parent dir is created if missing
;; (guarded against a race). Records are flushed per-line in ne-emit-line, so
;; a tail sees each promptly.
(define (ne-events-init!)
  (let* ((target (ne-resolve-events-path))
         (parent (ne-path-parent target)))
    (when (and parent (not (string=? parent "")) (not (file-exists? parent)))
      (with-exception-catcher (lambda (e) #f) (lambda () (create-directory parent))))
    (set! ne-events-port
      (open-output-file (list path: target truncate: #t create: 'maybe)))))

(define (ne-emit-line line)
  (when ne-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (with-exception-catcher
      (lambda (e) #f)
      (lambda ()
        (display line ne-events-port)
        (newline ne-events-port)
        (force-output ne-events-port)))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (ne-quote-string s)
  (let ((out (open-output-string)))
    (write-char #\" out)
    (let loop ((i 0))
      (when (< i (string-length s))
        (let ((c (string-ref s i)))
          (cond
            ((char=? c #\\) (display "\\\\" out))
            ((char=? c #\") (display "\\\"" out))
            ((char=? c #\newline) (display "\\n" out))
            (else (write-char c out))))
        (loop (+ i 1))))
    (write-char #\" out)
    (get-output-string out)))

;; Booleans emit as the bare symbols true/false — the contract defines the
;; bytes; the native #t/#f print form does not conform.
(define (ne-bool b) (if b "true" "false"))

(define (ne-emit-startup)
  (ne-emit-line "[lifecycle] startup"))
(define (ne-emit-launch-line)
  (ne-emit-line "Note Editor running. Close window or Ctrl+C to exit."))
(define (ne-emit-shutdown reason)
  (ne-emit-line (string-append "[lifecycle] shutdown reason=" (symbol->string reason))))

;; The six [document] events, one emitter (contract "Document events"): the
;; caller passes the event name plus the two payload values. On the state
;; events (new/opened/saved/dirty-changed) `path` is the POST-state current
;; path (#f when unset — emitted as ""); on the failure events (open-failed/
;; save-failed) it is the ATTEMPTED file's absolute path (the model is
;; unchanged by rule §8.5.6/7). `dirty` is the post-state flag in both cases.
;; Fixed key order path · dirty (multi-key regex matchers rely on adjacency).
(define (ne-emit-document event path dirty)
  (ne-emit-line (string-append "[document] " (symbol->string event)
                               " path=" (ne-quote-string (or path ""))
                               " dirty=" (ne-bool dirty))))

;; The one [preview] event (contract "Preview events"): emitted immediately
;; after every loadHTMLString: hand-off — it witnesses the hand-off, not the
;; pixels (render completion is unobservable, §5.4). `placeholder` = whether
;; the §7.1 placeholder body was rendered; `chars` = the Unicode scalar count
;; of the Markdown source the render consumed (0 for the empty document; a
;; Gambit string holds scalar values, so string-length counts them directly).
;; Fixed key order placeholder · chars.
(define (ne-emit-preview-rendered placeholder? chars)
  (ne-emit-line (string-append "[preview] rendered placeholder=" (ne-bool placeholder?)
                               " chars=" (number->string chars))))

(define (ne-close-events!)
  (when ne-events-port
    (with-exception-catcher (lambda (e) #f)
      (lambda ()
        (force-output ne-events-port)
        (close-output-port ne-events-port))))
  (set! ne-events-port #f))
;; --- End structured event log ----------------------------------------------

;; ============================================================
;; Application
;; ============================================================
(define-entry-point (main)
  ;; --- Definitions ---
  (def app (nsapplication-shared-application))

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. §3.10: no
  ;; unsaved-changes guard on the terminate path — the hook logs and lets
  ;; termination proceed. make-delegate pins the synthesized instance in
  ;; *delegate-roots* for the process (AppKit holds the delegate weakly);
  ;; this def keeps it lexically reachable too. The body is guarded because
  ;; an unhandled exception in an ObjC callback would crash the app with no
  ;; Scheme backtrace.
  (def app-delegate
    (make-delegate
      (list (list "applicationWillTerminate:"
                  (lambda (notification)
                    (with-exception-catcher (lambda (e) #f)
                      (lambda ()
                        (ne-emit-shutdown 'menu)
                        (ne-close-events!))))
                  (list 'object) 'void))))

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
    (let* ((placeholder? (string=? (trim-both markdown-text) ""))
           (body (if placeholder?
                   PREVIEW-PLACEHOLDER
                   (render-markdown markdown-text))))
      (wkwebview-load-html-string-base-url web-view
        (string->nsstring (string-append PREVIEW-TEMPLATE-HEAD body PREVIEW-TEMPLATE-FOOT))
        #f)
      ;; [preview] rendered — immediately after the loadHTMLString: hand-off
      ;; (contract "Preview events": the event witnesses the hand-off, not
      ;; the pixels). chars = scalar count of the Markdown source consumed.
      (ne-emit-preview-rendered placeholder? (string-length markdown-text))))
  (def (refresh-preview!) (render-preview! (current-editor-text)))

  ;; File operations
  (def (load-file! path)
    (with-catch
      (lambda (e)
        (set-status! (string-append "Open failed: " path))
        ;; [document] open-failed — the ATTEMPTED path (model unchanged by
        ;; rule §8.5.6), after the status line is set.
        (ne-emit-document 'open-failed path dirty?)
        #f)
      (lambda ()
        (let (text (read-file->string path))
          (nstext-set-string! text-view (string->nsstring text))
          (set! current-path path) (set! dirty? #f)
          (refresh-title!) (refresh-preview!)
          (set-status! (string-append "Opened " path))
          ;; [document] opened — post-state at the end of the §8.3 rule (the
          ;; mid-rule refresh-preview! already emitted its rendered line).
          (ne-emit-document 'opened current-path dirty?)
          #t))))

  (def (write-current-file! path)
    (with-catch
      (lambda (e)
        (set-status! (string-append "Save failed: " path))
        ;; [document] save-failed — the ATTEMPTED path, dirty flag unchanged
        ;; by rule (§8.5.7), after the status line is set.
        (ne-emit-document 'save-failed path dirty?)
        #f)
      (lambda ()
        (write-string->file (current-editor-text) path)
        (set! current-path path) (set! dirty? #f)
        (refresh-title!)
        (set-status! (string-append "Saved " path))
        ;; [document] saved — post-state at the end of the §8.4 write+state
        ;; rule. Reached from BOTH branches: the direct save (do-save! with a
        ;; current path) and the sheet branch (prompt-save!'s completion
        ;; handler calls here), so the sheet-branch emission is inside the
        ;; completion handler by construction (the contract's async re-entry
        ;; witness). No render accompanies a save (§7 excludes it).
        (ne-emit-document 'saved current-path dirty?)
        #t)))

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
      (set-status! "New document")
      ;; [document] new — post-state at the end of the §8.2 rule (always
      ;; path="" dirty=false; the mid-rule refresh emitted rendered
      ;; placeholder=true chars=0). The cancelled alert path never reaches
      ;; here (silent no-op).
      (ne-emit-document 'new "" #f)))

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
                (unless dirty?
                  (set! dirty? #t)
                  (refresh-title!)
                  ;; [document] dirty-changed — the §6.2 clean→dirty FLIP only
                  ;; (never per-keystroke), after the title refresh; path is the
                  ;; post-state current path. Emitting before refresh-preview!
                  ;; keeps the contract's first-keystroke order
                  ;; dirty-changed → rendered.
                  (ne-emit-document 'dirty-changed current-path #t))
                (refresh-preview!))
              (list 'object) 'void))))

  ;; --- Expressions ---
  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app app-delegate)
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

  ;; §3 step 8 launch diagnostic — dual emission (contract "Lifecycle
  ;; events"): the stdout line stays (human-friendly when run unbundled,
  ;; literally true to §3); the same BARE line goes to events.log, where the
  ;; runner can see it (LaunchServices discards stdout under `open`).
  (ne-emit-launch-line)
  (displayln "Note Editor running. Close window or Ctrl+C to exit.")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The editor builds its window/split-view in main's *defines* section (the
;; def initializers evaluate before main's first expression), so `startup`
;; cannot be main's first expression as in hello-window — it lands here
;; instead, before (main) is entered and thus before window/split-view
;; construction, well before the run loop (or the runner's `wait-ready`
;; readiness probe times out).
(ne-events-init!)
(ne-emit-startup)

;; Test-config compatibility (logging-contract.md): the editor reads no
;; runtime config, so it honours NOTE_EDITOR_TEST_CONFIG by reading the env
;; var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "NOTE_EDITOR_TEST_CONFIG" #f)

(main)
