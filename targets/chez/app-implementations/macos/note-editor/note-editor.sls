;; note-editor.sls — Note Editor sample app (chez target).
;;
;; Markdown editor with live HTML preview. Left pane is an NSTextView
;; (inside an NSScrollView); right pane is a WKWebView that re-renders the
;; Markdown as HTML on every NSTextDidChangeNotification. Mirrors
;; generation/targets/racket/apps/note-editor/note-editor.rkt.
;;
;; This is the first chez app to cross a **block bridge**: NSSavePanel's
;; -beginSheetModalForWindow:completionHandler: takes an ObjC block, and the
;; generated wrapper (post-130 emitter change) boxes the Scheme procedure we
;; pass through `make-objc-block` (runtime/dispatch.sls). The handler runs
;; asynchronously when the sheet dismisses — re-entering Scheme through the
;; `foreign-callable` trampoline whose body wraps in `with-autorelease-pool`
;; + guardian drain (ADR-0007), exactly like the WKNavigationDelegate
;; callbacks in mini-browser, but driven by a block rather than a delegate.
;;
;; Lifetime: the completion handler is an ASYNC API. ObjC copies the block
;; (begin-sheet retains the handler for the sheet's life), so on the final
;; Block_release the Swift dispose helper fires and releases the Swift-side
;; GC handle (verifiable via aw_chez_gc_count returning to baseline). The
;; chez-side foreign-callable code object stays `lock-object`'d — a bounded,
;; per-distinct-block retention identical to the racket target; we do NOT
;; call free-objc-block (that is for synchronous-only block APIs where ObjC
;; never copies the block). See runtime/dispatch.sls `make-objc-block`.
;;
;; No racket regexp / racket/file here: the Markdown renderer and file I/O
;; are hand-rolled against `(chezscheme)` primitives, mirroring how
;; mini-browser hand-rolled URL normalisation.
;;
;; Instrumented for the AppSpec scenario runner per the Note Editor
;; logging contract (apps/macos/note-editor/docs/logging-contract.md):
;; it writes a structured events.log the runner tails — [lifecycle]
;; startup/shutdown, the bare launch line, the six [document] state
;; transitions, and the one [preview] render event (the save sheet's
;; completion handler resolves on the sheet's schedule, so save completion
;; is not assertable without a log record; the 11-pt status label is the
;; app's only per-operation message surface; preview render completion is
;; entirely unobservable — §5.4). Under `launch-via 'open` LaunchServices
;; discards the app's stdout, so the log file (not stdout) is the runner's
;; read path; the stdout line is kept too (human-friendly when run
;; unbundled).
;;
;; The logging is inlined here rather than extracted to a sibling
;; `events.sls` for the same reason as the prior instrumented chez apps:
;; chez resolves `(import …)` by library-name→path against the
;; whole-program compile tree, so a sibling library would need an
;; `apps/`-prefixed name. These top-level defines use only (chezscheme)
;; names, so the standalone bundler resolves them with no new library on
;; the path.
;;
;; Run unbundled with:
;;   chez --libdirs targets/chez/bindings/macos \
;;        --script targets/chez/app-implementations/macos/note-editor/note-editor.sls
;; Bundled via `cargo run --example bundle_app -p apianyware-bundle-chez
;;              -- note-editor`.

(import (chezscheme)
        (apianyware appkit)
        (apianyware foundation)
        (apianyware webkit)
        (apianyware runtime cocoa)
        (apianyware runtime objc)
        (apianyware runtime types)
        (apianyware runtime dispatch))

;; --- Constants the collector has not extracted (parity with racket) ---
;; NSModalResponse / NSAlert return codes are not in
;; apianyware/appkit/enums.sls; carry them locally, matching the racket port
;; and pdfkit-viewer's NSModalResponseOK convention.
(define NSModalResponseOK     1)
(define NSModalResponseCancel 0)
(define NSAlertFirstButtonReturn  1000)
(define NSAlertSecondButtonReturn 1001)

;; --- Window geometry ---
(define WINDOW-W 900)
(define WINDOW-H 600)
(define TOOLBAR-H 32)
(define STATUS-H 22)
(define MARGIN 12)

;; ============================================================
;; String + path helpers (no racket/string, racket/path)
;; ============================================================

(define (trim-both s)
  (let* ([n (string-length s)]
         [start (let loop ([i 0])
                  (if (and (< i n) (char-whitespace? (string-ref s i)))
                      (loop (+ i 1))
                      i))]
         [end (let loop ([j n])
                (if (and (> j start) (char-whitespace? (string-ref s (- j 1))))
                    (loop (- j 1))
                    j))])
    (substring s start end)))

;; Last path component of an absolute POSIX path. "Untitled" stand-in is
;; the caller's job; here a trailing-slash-free basename suffices.
(define (basename path)
  (let loop ([i (- (string-length path) 1)])
    (cond
      [(< i 0) path]
      [(char=? (string-ref path i) #\/) (substring path (+ i 1) (string-length path))]
      [else (loop (- i 1))])))

;; ============================================================
;; Markdown → HTML (hand-rolled; mirrors the racket renderer)
;; ============================================================

(define (substr-at? s i sub)
  (let ([ls (string-length sub)] [n (string-length s)])
    (and (<= (+ i ls) n)
         (let loop ([j 0])
           (cond
             [(= j ls) #t]
             [(char=? (string-ref s (+ i j)) (string-ref sub j)) (loop (+ j 1))]
             [else #f])))))

(define (string-prefix? prefix s)
  (substr-at? s 0 prefix))

(define (all-whitespace-from? s start)
  (let ([n (string-length s)])
    (let loop ([i start])
      (cond
        [(= i n) #t]
        [(char-whitespace? (string-ref s i)) (loop (+ i 1))]
        [else #f]))))

(define (blank-line? s) (all-whitespace-from? s 0))

;; A line that opens (or, when its tail is all whitespace, closes) a fenced
;; code block: starts with ``` .
(define (fence-line? s) (string-prefix? "```" s))
(define (fence-close? s) (and (fence-line? s) (all-whitespace-from? s 3)))

;; ATX heading: 1-6 leading '#', then >=1 whitespace, then the text.
;; Returns (cons level text) or #f. 7+ '#'s is a paragraph (racket parity).
(define (heading-match s)
  (let ([n (string-length s)])
    (let count ([i 0])
      (cond
        [(and (< i n) (char=? (string-ref s i) #\#)) (count (+ i 1))]
        [(and (>= i 1) (<= i 6) (< i n) (char-whitespace? (string-ref s i)))
         (let skip ([j i])
           (if (and (< j n) (char-whitespace? (string-ref s j)))
               (skip (+ j 1))
               (cons i (substring s j n))))]
        [else #f]))))

;; Unordered-list item: a -/*/+ marker, then >=1 whitespace, then the text.
;; Returns the item text or #f.
(define (list-item-match s)
  (let ([n (string-length s)])
    (and (>= n 2)
         (memv (string-ref s 0) '(#\- #\* #\+))
         (char-whitespace? (string-ref s 1))
         (let skip ([j 1])
           (if (and (< j n) (char-whitespace? (string-ref s j)))
               (skip (+ j 1))
               (substring s j n))))))

(define (html-escape text)
  (let ([out (open-output-string)] [n (string-length text)])
    (let loop ([i 0])
      (if (= i n)
          (get-output-string out)
          (begin
            (case (string-ref text i)
              [(#\&) (display "&amp;" out)]
              [(#\<) (display "&lt;" out)]
              [(#\>) (display "&gt;" out)]
              [else (write-char (string-ref text i) out)])
            (loop (+ i 1)))))))

;; Replace every  open<content>close  where content is a maximal non-empty
;; run of chars not equal to `forbidden`, wrapping content via `wrap`.
;; Mirrors racket regexp-replace* of  open([^forbidden]+)close .
(define (replace-delimited s open close forbidden wrap)
  (let ([n (string-length s)]
        [lo (string-length open)]
        [lc (string-length close)]
        [out (open-output-string)])
    (let loop ([i 0])
      (cond
        [(>= i n) (get-output-string out)]
        [(substr-at? s i open)
         (let scan ([k (+ i lo)])
           (cond
             [(and (< k n) (not (char=? (string-ref s k) forbidden)))
              (scan (+ k 1))]
             [(and (> k (+ i lo)) (substr-at? s k close))
              (display (wrap (substring s (+ i lo) k)) out)
              (loop (+ k lc))]
             [else
              (write-char (string-ref s i) out)
              (loop (+ i 1))]))]
        [else
         (write-char (string-ref s i) out)
         (loop (+ i 1))]))))

(define (render-inline text)
  ;; Order matters: code spans first so their contents aren't further
  ;; transformed, then strong, then emphasis.
  (let* ([escaped (html-escape text)]
         [with-code
          (replace-delimited escaped "`" "`" #\`
            (lambda (c) (string-append "<code>" c "</code>")))]
         [with-strong
          (replace-delimited with-code "**" "**" #\*
            (lambda (c) (string-append "<strong>" c "</strong>")))]
         [with-em
          (replace-delimited with-strong "*" "*" #\*
            (lambda (c) (string-append "<em>" c "</em>")))])
    with-em))

;; Split on #\newline, keeping empty fields (racket string-split #:trim? #f).
(define (split-lines s)
  (let ([n (string-length s)])
    (let loop ([start 0] [i 0] [acc '()])
      (cond
        [(= i n) (reverse (cons (substring s start n) acc))]
        [(char=? (string-ref s i) #\newline)
         (loop (+ i 1) (+ i 1) (cons (substring s start i) acc))]
        [else (loop start (+ i 1) acc)]))))

(define (render-markdown source)
  (let ([out (open-output-string)])
    (let loop ([lines (split-lines source)] [in-fence? #f] [in-list? #f])
      (if (null? lines)
          (begin
            (when in-list? (display "</ul>\n" out))
            (when in-fence? (display "</code></pre>\n" out))
            (get-output-string out))
          (let ([line (car lines)] [rest (cdr lines)])
            (cond
              [in-fence?
               (if (fence-close? line)
                   (begin (display "</code></pre>\n" out)
                          (loop rest #f in-list?))
                   (begin (display (html-escape line) out)
                          (display "\n" out)
                          (loop rest #t in-list?)))]
              [(fence-line? line)
               (when in-list? (display "</ul>\n" out))
               (display "<pre><code>" out)
               (loop rest #t #f)]
              [(heading-match line)
               => (lambda (m)
                    (when in-list? (display "</ul>\n" out))
                    (let ([level (car m)])
                      (display "<h" out) (display level out) (display ">" out)
                      (display (render-inline (cdr m)) out)
                      (display "</h" out) (display level out) (display ">\n" out))
                    (loop rest #f #f))]
              [(list-item-match line)
               => (lambda (item-text)
                    (unless in-list? (display "<ul>\n" out))
                    (display "<li>" out)
                    (display (render-inline item-text) out)
                    (display "</li>\n" out)
                    (loop rest #f #t))]
              [(blank-line? line)
               (when in-list? (display "</ul>\n" out))
               (display "\n" out)
               (loop rest #f #f)]
              [else
               (when in-list? (display "</ul>\n" out))
               (display "<p>" out)
               (display (render-inline line) out)
               (display "</p>\n" out)
               (loop rest #f #f)]))))))

(define PREVIEW-TEMPLATE-HEAD
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
(define PREVIEW-TEMPLATE-FOOT "</body></html>")
(define PREVIEW-PLACEHOLDER
  "<p class=\"placeholder\">Start typing Markdown on the left…</p>")

;; ============================================================
;; File I/O (UTF-8, hand-rolled; no racket/file)
;; ============================================================

(define (read-file->string path)
  (let ([p (open-file-input-port path (file-options)
                                 (buffer-mode block)
                                 (make-transcoder (utf-8-codec)))])
    (let ([s (get-string-all p)])
      (close-port p)
      (if (eof-object? s) "" s))))

(define (write-string->file str path)
  (let ([p (open-file-output-port path (file-options no-fail)
                                  (buffer-mode block)
                                  (make-transcoder (utf-8-codec)))])
    (put-string p str)
    (close-port p)))

;; ============================================================
;; Structured event log (logging contract)
;; ============================================================
;; Single writer: every event is emitted on the main thread — startup, the
;; initial render, and the launch line before -run; the [document]/[preview]
;; events from the five action handlers, the text-change notification
;; observer, and the save sheet's completion handler (all delivered by
;; AppKit on the main thread); shutdown on the terminate path — so one port
;; with a post-write flush suffices (no lock).

;; Fixed default the descriptor's #:events-path mirrors, so the runner tails
;; the same file whether or not #:log-env (NOTE_EDITOR_EVENTS_LOG)
;; propagates through LaunchServices.
(define ne-default-events-path "/tmp/note-editor/events.log")
(define ne-events-port #f)

;; NOTE_EDITOR_EVENTS_LOG if set and non-empty, else the fixed default.
(define (ne-resolve-events-path)
  (let ([env (getenv "NOTE_EDITOR_EVENTS_LOG")])
    (if (and env (not (string=? env ""))) env ne-default-events-path)))

;; Directory component of `p` (everything before the last '/'), or #f.
(define (ne-path-parent p)
  (let loop ([i (- (string-length p) 1)])
    (cond
      [(< i 0) #f]
      [(char=? (string-ref p i) #\/) (substring p 0 i)]
      [else (loop (- i 1))])))

;; Open + truncate the events.log: (file-options no-fail) creates it if absent
;; and truncates it if present. Line-buffered so a tail sees each record
;; promptly. The parent dir is created if missing (guarded against a race).
(define (ne-events-init!)
  (let* ([target (ne-resolve-events-path)]
         [parent (ne-path-parent target)])
    (when (and parent (not (string=? parent "")) (not (file-directory? parent)))
      (guard (e [#t (void)]) (mkdir parent)))
    (set! ne-events-port
      (open-file-output-port target
        (file-options no-fail)
        (buffer-mode line)
        (make-transcoder (utf-8-codec))))))

(define (ne-emit-line line)
  (when ne-events-port
    ;; Swallow only I/O-level failures (out-of-disk, closed-port races on
    ;; shutdown). A genuine programmer error still surfaces during dev.
    (guard (e [#t (void)])
      (put-string ne-events-port line)
      (put-char ne-events-port #\newline)
      (flush-output-port ne-events-port))))

;; Contract "Line format": strings are double-quoted with \\ / \" / newline
;; escaped; numbers/booleans/symbols emit bare.
(define (ne-quote-string s)
  (let ([out (open-output-string)])
    (put-char out #\")
    (string-for-each
      (lambda (c)
        (case c
          [(#\\) (put-string out "\\\\")]
          [(#\") (put-string out "\\\"")]
          [(#\newline) (put-string out "\\n")]
          [else (put-char out c)]))
      s)
    (put-char out #\")
    (get-output-string out)))

;; Booleans emit as the bare symbols true/false — the contract defines the
;; bytes; Chez's native #t/#f print form does not conform.
(define (ne-bool b) (if b "true" "false"))

(define (ne-emit-startup)
  (ne-emit-line "[lifecycle] startup"))
(define (ne-emit-launch-line)
  (ne-emit-line "Note Editor running. Close window or Ctrl+C to exit."))
(define (ne-emit-shutdown reason)
  (ne-emit-line (format "[lifecycle] shutdown reason=~a" reason)))

;; The six [document] events, one emitter (contract "Document events"): the
;; caller passes the event name plus the two payload values. On the state
;; events (new/opened/saved/dirty-changed) `path` is the POST-state current
;; path (#f when unset — emitted as ""); on the failure events (open-failed/
;; save-failed) it is the ATTEMPTED file's absolute path (the model is
;; unchanged by rule §8.5.6/7). `dirty` is the post-state flag in both cases.
;; Fixed key order path · dirty (multi-key regex matchers rely on adjacency).
(define (ne-emit-document event path dirty)
  (ne-emit-line (format "[document] ~a path=~a dirty=~a"
                        event
                        (ne-quote-string (or path ""))
                        (ne-bool dirty))))

;; The one [preview] event (contract "Preview events"): emitted immediately
;; after every loadHTMLString: hand-off — it witnesses the hand-off, not the
;; pixels (render completion is unobservable, §5.4). `placeholder` = whether
;; the §7.1 placeholder body was rendered; `chars` = the Unicode scalar count
;; of the Markdown source the render consumed (0 for the empty document; a
;; chez string holds scalar values, so string-length counts them directly).
;; Fixed key order placeholder · chars.
(define (ne-emit-preview-rendered placeholder? chars)
  (ne-emit-line (format "[preview] rendered placeholder=~a chars=~a"
                        (ne-bool placeholder?)
                        chars)))

(define (ne-close-events!)
  (when ne-events-port
    (guard (e [#t (void)])
      (flush-output-port ne-events-port)
      (close-output-port ne-events-port)))
  (set! ne-events-port #f))

;; ============================================================
;; Application
;; ============================================================

(define-entry-point (main)
  ;; ----------------------------------------------------------
  ;; Definitions
  ;; ----------------------------------------------------------

  (define app (nsapplication-shared-application))

  ;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
  ;; The osascript graceful quit the runner uses (quit-impl! / the Command-Q
  ;; scenario) routes through applicationWillTerminate:. §3.10: no
  ;; unsaved-changes guard on the terminate path — the hook logs and lets
  ;; termination proceed. Cocoa holds the delegate weakly, so keep
  ;; `app-delegate` reachable — this define lives for the whole of `main`,
  ;; which spans the run loop. The callback body is guarded because an
  ;; unhandled exception in an ObjC callback crashes the app with no Scheme
  ;; backtrace.
  (define app-delegate
    (make-delegate
      `(("applicationWillTerminate:"
         ,(lambda (notification)
            (guard (e [#t (void)])
              (ne-emit-shutdown 'menu)
              (ne-close-events!)))
         (void*) void))))

  (define window
    (make-nswindow-init-with-content-rect-style-mask-backing-defer
      (make-nsrect 0 0 WINDOW-W WINDOW-H)
      (bitwise-ior NSWindowStyleMaskTitled
                   NSWindowStyleMaskClosable
                   NSWindowStyleMaskMiniaturizable
                   NSWindowStyleMaskResizable)
      NSBackingStoreBuffered
      #f))

  (define content-view (nswindow-content-view window))

  ;; --- Editor state ---
  ;; current-path is #f for Untitled, else the absolute path of the last
  ;; save. dirty? tracks unsaved edits.
  (define current-path #f)
  (define dirty? #f)

  ;; --- Toolbar controls ---
  (define new-button    (make-nsbutton-init-with-frame (make-nsrect 0 0 64 28)))
  (define open-button   (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
  (define save-button   (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
  (define undo-button   (make-nsbutton-init-with-frame (make-nsrect 0 0 72 28)))
  (define redo-button   (make-nsbutton-init-with-frame (make-nsrect 0 0 72 28)))
  (define status-label  (make-nstextfield-init-with-frame (make-nsrect 0 0 0 22)))

  (define toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
  (define toolbar-stack
    (make-nsstackview-init-with-frame
      (make-nsrect MARGIN toolbar-y (- WINDOW-W (* 2 MARGIN)) TOOLBAR-H)))

  ;; --- Split view: editor (left) + preview (right) ---
  (define split-y MARGIN)
  (define split-h (- toolbar-y split-y MARGIN))
  (define split-w (- WINDOW-W (* 2 MARGIN)))
  (define split-view
    (make-nssplitview-init-with-frame
      (make-nsrect MARGIN split-y split-w split-h)))

  (define editor-w (quotient split-w 2))
  (define preview-w (- split-w editor-w))

  (define text-view
    (make-nstextview-init-with-frame (make-nsrect 0 0 editor-w split-h)))
  (define editor-scroll
    (make-nsscrollview-init-with-frame (make-nsrect 0 0 editor-w split-h)))
  (define web-view
    (make-wkwebview-init-with-frame (make-nsrect 0 0 preview-w split-h)))

  ;; --- Status helper ---
  (define (set-status! text)
    (nstextfield-set-string-value! status-label text))

  ;; --- Title / dirty indicator ---
  (define (display-name)
    (if current-path (basename current-path) "Untitled"))

  (define (refresh-title!)
    (let ([name (display-name)])
      (nswindow-set-title! window
        (if dirty?
            (format #f "~a — edited — Note Editor" name)
            (format #f "~a — Note Editor" name)))
      (nswindow-set-document-edited! window dirty?)))

  ;; --- Editor text + preview ---
  (define (current-editor-text)
    (nsstring->string (nstextview-string text-view)))

  (define (render-preview! markdown-text)
    (let* ([placeholder? (string=? (trim-both markdown-text) "")]
           [body (if placeholder?
                     PREVIEW-PLACEHOLDER
                     (render-markdown markdown-text))])
      (wkwebview-load-html-string-base-url web-view
        (string-append PREVIEW-TEMPLATE-HEAD body PREVIEW-TEMPLATE-FOOT)
        #f)
      ;; [preview] rendered — immediately after the loadHTMLString: hand-off
      ;; (contract "Preview events": the event witnesses the hand-off, not
      ;; the pixels). chars = scalar count of the Markdown source consumed.
      (ne-emit-preview-rendered placeholder? (string-length markdown-text))))

  (define (refresh-preview!)
    (render-preview! (current-editor-text)))

  ;; --- File operations ---
  (define (load-file! path)
    (guard (e [#t (set-status! (format #f "Open failed: ~a" path))
               ;; [document] open-failed — the ATTEMPTED path (model
               ;; unchanged by rule §8.5.6), after the status line is set.
               (ne-emit-document 'open-failed path dirty?)
               #f])
      (let ([text (read-file->string path)])
        (nstextview-set-string! text-view text)
        (set! current-path path)
        (set! dirty? #f)
        (refresh-title!)
        (refresh-preview!)
        (set-status! (format #f "Opened ~a" path))
        ;; [document] opened — post-state at the end of the §8.3 rule (the
        ;; mid-rule refresh-preview! already emitted its rendered line).
        (ne-emit-document 'opened current-path dirty?)
        #t)))

  (define (write-current-file! path)
    (guard (e [#t (set-status! (format #f "Save failed: ~a" path))
               ;; [document] save-failed — the ATTEMPTED path, dirty flag
               ;; unchanged by rule (§8.5.7), after the status line is set.
               (ne-emit-document 'save-failed path dirty?)
               #f])
      (write-string->file (current-editor-text) path)
      (set! current-path path)
      (set! dirty? #f)
      (refresh-title!)
      (set-status! (format #f "Saved ~a" path))
      ;; [document] saved — post-state at the end of the §8.4 write+state
      ;; rule. Reached from BOTH branches: the direct save (do-save! with a
      ;; current path) and the sheet branch (prompt-save!'s completion
      ;; handler calls here), so the sheet-branch emission is inside the
      ;; completion handler by construction (the contract's async re-entry
      ;; witness). No render accompanies a save (§7 excludes it).
      (ne-emit-document 'saved current-path dirty?)
      #t))

  ;; --- Unsaved-changes confirmation ---
  (define (confirm-discard? message)
    (cond
      [(not dirty?) #t]
      [else
       (let ([alert (make-nsalert)])
         (nsalert-set-alert-style! alert NSAlertStyleWarning)
         (nsalert-set-message-text! alert message)
         (nsalert-set-informative-text! alert
           "Your changes will be lost if you continue.")
         (nsalert-add-button-with-title! alert "Discard")
         (nsalert-add-button-with-title! alert "Cancel")
         (= (nsalert-run-modal alert) NSAlertFirstButtonReturn))]))

  ;; --- Save via completion block ---
  ;; The completion handler is the block bridge: the generated
  ;; nssavepanel-begin-sheet-modal-for-window-completion-handler! boxes this
  ;; lambda via make-objc-block. `response` arrives as a chez integer (the
  ;; block's NSModalResponse arg, bridged through `integer-64`).
  (define (prompt-save!)
    (let ([panel (nssavepanel-save-panel)])
      (nssavepanel-set-can-create-directories! panel #t)
      (guard (e [#t (void)])
        (nssavepanel-set-name-field-string-value! panel
          (if current-path (display-name) "untitled.md")))
      (nssavepanel-begin-sheet-modal-for-window-completion-handler!
        panel
        window
        (lambda (response)
          (when (= response NSModalResponseOK)
            (let ([url (nssavepanel-url panel)])
              (unless (zero? (objc-object-ptr url))
                (let ([raw-path (nsstring->string (nsurl-path url))])
                  (unless (string=? raw-path "")
                    (write-current-file! raw-path))))))))))

  (define (do-save!)
    (if current-path
        (write-current-file! current-path)
        (prompt-save!)))

  ;; --- Open via run-modal ---
  ;; NSOpenPanel.runModal is synchronous; the completion-block variant is
  ;; already exercised by Save.
  (define markdown-extensions
    (list->nsarray (list "md" "markdown" "txt")))

  (define (do-open!)
    (when (confirm-discard? "Discard unsaved changes?")
      (let ([panel (nsopenpanel-open-panel)])
        (nsopenpanel-set-can-choose-files! panel #t)
        (nsopenpanel-set-can-choose-directories! panel #f)
        (nsopenpanel-set-allows-multiple-selection! panel #f)
        (nsopenpanel-set-allowed-file-types! panel markdown-extensions)
        (when (= (nsopenpanel-run-modal panel) NSModalResponseOK)
          (let ([url (nsopenpanel-url panel)])
            (unless (zero? (objc-object-ptr url))
              (load-file! (nsstring->string (nsurl-path url)))))))))

  (define (do-new!)
    (when (confirm-discard? "Discard unsaved changes and start a new note?")
      (nstextview-set-string! text-view "")
      (set! current-path #f)
      (set! dirty? #f)
      (refresh-title!)
      (refresh-preview!)
      (set-status! "New document")
      ;; [document] new — post-state at the end of the §8.2 rule (always
      ;; path="" dirty=false; the mid-rule refresh emitted rendered
      ;; placeholder=true chars=0). The cancelled alert path never reaches
      ;; here (silent no-op).
      (ne-emit-document 'new "" #f)))

  ;; --- Undo / Redo via NSTextView's undo manager ---
  (define (do-undo!)
    (let ([mgr (nstextview-undo-manager text-view)])
      (when (and (not (zero? (objc-object-ptr mgr)))
                 (nsundomanager-can-undo mgr))
        (nsundomanager-undo mgr))))

  (define (do-redo!)
    (let ([mgr (nstextview-undo-manager text-view)])
      (when (and (not (zero? (objc-object-ptr mgr)))
                 (nsundomanager-can-redo mgr))
        (nsundomanager-redo mgr))))

  ;; --- Toolbar target-action delegate (one record, five selectors) ---
  (define ui-target
    (make-delegate
      `(("newDoc:"  ,(lambda (_sender) (do-new!))  (void*) void)
        ("openDoc:" ,(lambda (_sender) (do-open!)) (void*) void)
        ("saveDoc:" ,(lambda (_sender) (do-save!)) (void*) void)
        ("undoDoc:" ,(lambda (_sender) (do-undo!)) (void*) void)
        ("redoDoc:" ,(lambda (_sender) (do-redo!)) (void*) void))))

  ;; --- Text-change observer ---
  ;; NSTextDidChangeNotification fires after every user edit. Cocoa holds
  ;; observers weakly, so `text-change-observer` must stay reachable for the
  ;; run loop's life — the closure here keeps it alive.
  (define text-change-observer
    (make-delegate
      `(("textDidChange:"
         ,(lambda (_note)
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
         (void*) void))))

  ;; ----------------------------------------------------------
  ;; Expressions
  ;; ----------------------------------------------------------

  (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
  (nsapplication-set-delegate! app (delegate-ptr app-delegate))
  (install-standard-app-menu! app "Note Editor")

  ;; Window
  (nswindow-center! window)
  (nswindow-set-min-size! window (make-nssize 520 360))

  ;; Toolbar controls
  (nsbutton-set-title! new-button "New")
  (nsbutton-set-bezel-style! new-button NSBezelStyleRounded)
  (nsbutton-set-title! open-button "Open…")
  (nsbutton-set-bezel-style! open-button NSBezelStyleRounded)
  (nsbutton-set-title! save-button "Save…")
  (nsbutton-set-bezel-style! save-button NSBezelStyleRounded)
  (nsbutton-set-title! undo-button "Undo")
  (nsbutton-set-bezel-style! undo-button NSBezelStyleRounded)
  (nsbutton-set-title! redo-button "Redo")
  (nsbutton-set-bezel-style! redo-button NSBezelStyleRounded)

  (nstextfield-set-string-value! status-label "Ready")
  (nstextfield-set-font! status-label (nsfont-system-font-of-size 11.0))
  (nstextfield-set-alignment! status-label NSTextAlignmentLeft)
  (nstextfield-set-editable! status-label #f)
  (nstextfield-set-selectable! status-label #f)
  (nstextfield-set-bezeled! status-label #f)
  (nstextfield-set-draws-background! status-label #f)

  (nsstackview-set-orientation! toolbar-stack NSUserInterfaceLayoutOrientationHorizontal)
  (nsstackview-set-alignment! toolbar-stack NSLayoutAttributeFirstBaseline)
  (nsstackview-set-spacing! toolbar-stack 8.0)
  (nsstackview-add-arranged-subview! toolbar-stack new-button)
  (nsstackview-add-arranged-subview! toolbar-stack open-button)
  (nsstackview-add-arranged-subview! toolbar-stack save-button)
  (nsstackview-add-arranged-subview! toolbar-stack undo-button)
  (nsstackview-add-arranged-subview! toolbar-stack redo-button)
  (nsstackview-add-arranged-subview! toolbar-stack status-label)
  (nsview-set-autoresizing-mask! toolbar-stack
    (bitwise-ior NSViewWidthSizable NSViewMinYMargin))
  (nsview-add-subview! content-view toolbar-stack)

  ;; Split view (vertical divider → side-by-side panes)
  (nssplitview-set-vertical! split-view #t)
  (nsview-set-autoresizing-mask! split-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
  (nsview-add-subview! content-view split-view)

  ;; Editor pane
  (nstextview-set-editable! text-view #t)
  (nstextview-set-rich-text! text-view #f)
  (nstextview-set-allows-undo! text-view #t)
  (nstextview-set-uses-find-bar! text-view #t)
  (nstextview-set-font! text-view (nsfont-user-fixed-pitch-font-of-size 13.0))
  (nstextview-set-horizontally-resizable! text-view #f)
  (nsview-set-autoresizing-mask! text-view
    (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

  (nsscrollview-set-has-vertical-scroller! editor-scroll #t)
  (nsscrollview-set-has-horizontal-scroller! editor-scroll #f)
  (nsscrollview-set-document-view! editor-scroll text-view)
  (nssplitview-add-subview! split-view editor-scroll)

  ;; Preview pane
  (nssplitview-add-subview! split-view web-view)
  (render-preview! "")

  ;; Text-change observer wiring (notification source = the text view)
  (nsnotificationcenter-add-observer-selector-name-object!
    (nsnotificationcenter-default-center)
    (delegate-ptr text-change-observer)
    "textDidChange:"
    NSTextDidChangeNotification
    text-view)

  ;; Toolbar target-action wiring
  (nsbutton-set-target! new-button  (delegate-ptr ui-target))
  (nsbutton-set-action! new-button  "newDoc:")
  (nsbutton-set-target! open-button (delegate-ptr ui-target))
  (nsbutton-set-action! open-button "openDoc:")
  (nsbutton-set-target! save-button (delegate-ptr ui-target))
  (nsbutton-set-action! save-button "saveDoc:")
  (nsbutton-set-target! undo-button (delegate-ptr ui-target))
  (nsbutton-set-action! undo-button "undoDoc:")
  (nsbutton-set-target! redo-button (delegate-ptr ui-target))
  (nsbutton-set-action! redo-button "redoDoc:")

  ;; Show window and run
  (refresh-title!)
  (nswindow-make-key-and-order-front window #f)
  (nsapplication-activate-ignoring-other-apps app #t)

  ;; §3 step 8 launch diagnostic — dual emission (contract "Lifecycle
  ;; events"): the stdout line stays (human-friendly when run unbundled,
  ;; literally true to §3); the same BARE line goes to events.log, where the
  ;; runner can see it (LaunchServices discards stdout under `open`).
  (ne-emit-launch-line)
  (display "Note Editor running. Close window or Ctrl+C to exit.\n")
  (nsapplication-run app))

;; --- Structured event log: open + [lifecycle] startup BEFORE (main) --------
;; The editor builds its window/split-view in `main`'s defines section (R6RS
;; body: all defines precede every expression), so `startup` cannot be main's
;; first expression — it lands here instead, before (main) is entered and thus
;; before window/split-view construction, well before the run loop (or the
;; runner's `wait-ready` readiness probe times out).
(ne-events-init!)
(ne-emit-startup)

;; Test-config compatibility (logging-contract.md): the editor reads no
;; runtime config, so it honours NOTE_EDITOR_TEST_CONFIG by reading the env
;; var and treating absent/empty (and a missing file) as "no config" — a
;; deliberate no-op.
(getenv "NOTE_EDITOR_TEST_CONFIG")

(main)
