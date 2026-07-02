#lang racket/base
;; note-editor.rkt — Note Editor sample app (OO style)
;;
;; Markdown editor with live HTML preview. Left pane is an NSTextView
;; (inside an NSScrollView); right pane is a WKWebView that re-renders
;; the Markdown as HTML on every NSTextDidChangeNotification. Exercises:
;;   - NSSplitView for side-by-side layout
;;   - NSTextView with built-in undo (allowsUndo: YES)
;;   - NSNotificationCenter observer on NSTextDidChangeNotification
;;   - NSSavePanel with begin-sheet-modal-for-window:completionHandler:
;;     (the completion-block pattern — Racket procedure bridged to an
;;     ObjC block)
;;   - NSOpenPanel run-modal
;;   - NSAlert for unsaved-changes confirmation
;;   - NSWindow setDocumentEdited: for title-bar dirty indicator
;;   - WKWebView loadHTMLString:baseURL: (HTML-as-string, not URL nav)
;;   - Cross-framework imports (AppKit + Foundation + WebKit)
;;
;; Run via bundle-racket (see README). Never run the .rkt directly
;; from the command line — menu bar app name requires a proper bundle.

(require racket/file
         racket/format
         racket/path
         racket/string
         "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../generated/appkit/nsview.rkt"
         "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nstextfield.rkt"
         "../../generated/appkit/nstextview.rkt"
         "../../generated/appkit/nsscrollview.rkt"
         "../../generated/appkit/nssplitview.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/appkit/nsfont.rkt"
         "../../generated/appkit/nsopenpanel.rkt"
         "../../generated/appkit/nssavepanel.rkt"
         "../../generated/appkit/nsalert.rkt"
         (only-in "../../generated/appkit/constants.rkt"
                  NSTextDidChangeNotification)
         "../../generated/foundation/nsurl.rkt"
         "../../generated/foundation/nsundomanager.rkt"
         "../../generated/foundation/nsnotificationcenter.rkt"
         "../../generated/webkit/wkwebview.rkt"
         "../../runtime/objc-base.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/delegate.rkt"
         "../../runtime/app-menu.rkt"
         "events.rkt")

;; --- Constants not yet extracted by the collector ---
;; NSWindowStyleMask
(define NSWindowStyleMaskTitled         1)
(define NSWindowStyleMaskClosable       2)
(define NSWindowStyleMaskMiniaturizable 4)
(define NSWindowStyleMaskResizable      8)
;; NSBackingStoreType
(define NSBackingStoreBuffered 2)
;; NSTextAlignment
(define NSTextAlignmentLeft 0)
;; NSViewAutoresizingMask
(define NSViewWidthSizable  2)
(define NSViewHeightSizable 16)
(define NSViewMinYMargin    8)
(define NSViewMaxYMargin   32)
;; NSBezelStyle
(define NSBezelStyleRounded 1)
;; NSUserInterfaceLayoutOrientation
(define NSUserInterfaceLayoutOrientationHorizontal 0)
;; NSLayoutAttribute
(define NSLayoutAttributeFirstBaseline 12)
;; NSModalResponse
(define NSModalResponseOK     1)
(define NSAlertFirstButtonReturn 1000)
(define NSAlertSecondButtonReturn 1001)
;; NSAlertStyle
(define NSAlertStyleWarning 1)

;; --- Structured event log (logging contract) ---
;; Open + truncate the events.log the runner tails, then record [lifecycle]
;; startup BEFORE window/split-view construction / the AppKit run loop (or
;; `wait-ready` times out).
(events-init!)
(emit-startup)

;; Test-config compatibility (logging-contract.md "Test-config compatibility"):
;; the editor reads no runtime config, so it honours NOTE_EDITOR_TEST_CONFIG
;; by reading the env var and treating an absent/empty value (and a missing
;; file) as "no config" — a deliberate no-op.
(void (getenv "NOTE_EDITOR_TEST_CONFIG"))

;; --- Shutdown wiring (signal / error paths) ---
;; The logging contract requires a [lifecycle] shutdown line on terminate.
;; The menu/Cmd-Q path goes through applicationWillTerminate: (delegate below);
;; SIGTERM/SIGINT reach Racket as exn:break → reason=signal, and any other
;; uncaught exception → reason=error.
(uncaught-exception-handler
 (lambda (exn)
   (with-handlers ([exn:fail? (lambda (_) (void))])
     (if (exn:break? exn)
         (emit-shutdown 'signal)
         (emit-shutdown 'error))
     (close-events!))
   (exit (if (exn:break? exn) 130 1))))

;; --- Application setup ---
(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0) ; Regular
(install-standard-app-menu! app "Note Editor")

;; --- App delegate (terminate hook → [lifecycle] shutdown reason=menu) ---
;; Cocoa holds delegates weakly, so keep a module-scope reference. The body is
;; wrapped in with-handlers because an unhandled exception in an ObjC callback
;; crashes the app with no Racket stack trace. §3.10: no unsaved-changes guard
;; on the terminate path — the hook logs and lets termination proceed.
(define app-delegate
  (make-delegate
   "applicationWillTerminate:"
   (lambda (notification)
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationWillTerminate delegate error: ~a\n"
                                 (exn-message e)))])
       (emit-shutdown 'menu)
       (close-events!)))))
(void (nsapplication-set-delegate! app app-delegate))

;; --- Window ---
(define WINDOW-W 900)
(define WINDOW-H 600)
(define TOOLBAR-H 32)
(define STATUS-H 22)
(define MARGIN 12)

(define window
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
   (make-nsrect 0 0 WINDOW-W WINDOW-H)
   (bitwise-ior NSWindowStyleMaskTitled
                NSWindowStyleMaskClosable
                NSWindowStyleMaskMiniaturizable
                NSWindowStyleMaskResizable)
   NSBackingStoreBuffered
   #f))
(nswindow-center! window)
(nswindow-set-min-size! window (make-nssize 520 360))
(define content-view (nswindow-content-view window))

;; --- Editor state ---
;; current-path is #f for Untitled, otherwise the absolute path of the
;; last save. dirty? tracks unsaved edits.
(define current-path #f)
(define dirty? #f)

;; Event-payload path normalization (logging contract "Document events"):
;; the `path` key is a string — the current/attempted absolute path, or the
;; empty string when unset. current-path is a string in practice (both panels
;; yield `(->string (nsurl-path url))`); handle a path object defensively.
(define (path-string p)
  (cond [(not p) ""]
        [(path? p) (path->string p)]
        [else p]))

(define (display-name-for-path path)
  (cond [(not path) "Untitled"]
        [else (path->string (file-name-from-path path))]))

(define (refresh-title!)
  (define name (display-name-for-path current-path))
  (nswindow-set-title! window
    (if dirty?
        (format "~a — edited — Note Editor" name)
        (format "~a — Note Editor" name)))
  (nswindow-set-document-edited! window dirty?))

;; --- Toolbar controls ---
(define new-button (make-nsbutton-init-with-frame (make-nsrect 0 0 64 28)))
(nsbutton-set-title! new-button "New")
(nsbutton-set-bezel-style! new-button NSBezelStyleRounded)

(define open-button (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
(nsbutton-set-title! open-button "Open…")
(nsbutton-set-bezel-style! open-button NSBezelStyleRounded)

(define save-button (make-nsbutton-init-with-frame (make-nsrect 0 0 80 28)))
(nsbutton-set-title! save-button "Save…")
(nsbutton-set-bezel-style! save-button NSBezelStyleRounded)

(define undo-button (make-nsbutton-init-with-frame (make-nsrect 0 0 72 28)))
(nsbutton-set-title! undo-button "Undo")
(nsbutton-set-bezel-style! undo-button NSBezelStyleRounded)

(define redo-button (make-nsbutton-init-with-frame (make-nsrect 0 0 72 28)))
(nsbutton-set-title! redo-button "Redo")
(nsbutton-set-bezel-style! redo-button NSBezelStyleRounded)

(define status-label
  (make-nstextfield-init-with-frame (make-nsrect 0 0 0 22)))
(nstextfield-set-string-value! status-label "Ready")
(nstextfield-set-font! status-label (nsfont-system-font-of-size 11.0))
(nstextfield-set-alignment! status-label NSTextAlignmentLeft)
(nstextfield-set-editable! status-label #f)
(nstextfield-set-selectable! status-label #f)
(nstextfield-set-bezeled! status-label #f)
(nstextfield-set-draws-background! status-label #f)

(define toolbar-y (- WINDOW-H MARGIN TOOLBAR-H))
(define toolbar-stack
  (make-nsstackview-init-with-frame
   (make-nsrect MARGIN toolbar-y (- WINDOW-W (* 2 MARGIN)) TOOLBAR-H)))
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

(define (set-status! text)
  (nstextfield-set-string-value! status-label text))

;; --- Split view: editor (left) + preview (right) ---
(define split-y MARGIN)
(define split-h (- toolbar-y split-y MARGIN))
(define split-w (- WINDOW-W (* 2 MARGIN)))

(define split-view
  (make-nssplitview-init-with-frame
   (make-nsrect MARGIN split-y split-w split-h)))
;; setVertical: YES means the divider is vertical, i.e. the two panes
;; sit side-by-side horizontally. Counter-intuitive naming but that is
;; Apple's convention.
(nssplitview-set-vertical! split-view #t)
(nsview-set-autoresizing-mask! split-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))
(nsview-add-subview! content-view split-view)

;; --- Editor pane ---
(define editor-w (quotient split-w 2))

(define text-view
  (make-nstextview-init-with-frame (make-nsrect 0 0 editor-w split-h)))
(nstextview-set-editable! text-view #t)
(nstextview-set-rich-text! text-view #f)
(nstextview-set-allows-undo! text-view #t)
(nstextview-set-uses-find-bar! text-view #t)
(nstextview-set-font! text-view (nsfont-user-fixed-pitch-font-of-size 13.0))
(nstextview-set-horizontally-resizable! text-view #f)
(nsview-set-autoresizing-mask! text-view
  (bitwise-ior NSViewWidthSizable NSViewHeightSizable))

(define editor-scroll
  (make-nsscrollview-init-with-frame (make-nsrect 0 0 editor-w split-h)))
(nsscrollview-set-has-vertical-scroller! editor-scroll #t)
(nsscrollview-set-has-horizontal-scroller! editor-scroll #f)
(nsscrollview-set-document-view! editor-scroll text-view)
(nssplitview-add-subview! split-view editor-scroll)

;; --- Preview pane ---
(define preview-w (- split-w editor-w))
(define web-view
  (make-wkwebview-init-with-frame
   (make-nsrect 0 0 preview-w split-h)))
(nssplitview-add-subview! split-view web-view)

;; --- Markdown → HTML preview ---
;; A small Racket-side Markdown renderer keeps the app self-contained
;; (no bundled JS library). Supports ATX headings, fenced code blocks,
;; inline code, emphasis, strong, and unordered lists — enough to make
;; live preview visibly different from plain text. Full CommonMark is
;; out of scope for a sample app.

(define (html-escape text)
  (regexp-replaces text
    '([#px"&" "\\&amp;"]
      [#px"<" "\\&lt;"]
      [#px">" "\\&gt;"])))

(define (render-inline text)
  ;; Order matters: code spans first so their contents aren't further
  ;; transformed, then emphasis markers.
  (define escaped (html-escape text))
  (define with-code
    (regexp-replace* #px"`([^`]+)`" escaped "<code>\\1</code>"))
  (define with-strong
    (regexp-replace* #px"\\*\\*([^*]+)\\*\\*" with-code "<strong>\\1</strong>"))
  (define with-em
    (regexp-replace* #px"\\*([^*]+)\\*" with-strong "<em>\\1</em>"))
  with-em)

(define (render-markdown source)
  ;; Line-oriented walker with a tiny state machine for code fences and
  ;; unordered-list grouping. Emits a single HTML string (no trailing
  ;; newline sensitivity).
  (define lines (string-split source "\n" #:trim? #f))
  (define output (open-output-string))
  (define in-fence? #f)
  (define in-list?  #f)
  (define (close-list!)
    (when in-list?
      (displayln "</ul>" output)
      (set! in-list? #f)))
  (for ([line (in-list lines)])
    (cond
      [in-fence?
       (cond [(regexp-match? #px"^```\\s*$" line)
              (displayln "</code></pre>" output)
              (set! in-fence? #f)]
             [else
              (displayln (html-escape line) output)])]
      [(regexp-match? #px"^```" line)
       (close-list!)
       (display "<pre><code>" output)
       (set! in-fence? #t)]
      [(regexp-match #px"^(#{1,6})\\s+(.*)$" line)
       => (lambda (m)
            (close-list!)
            (define level (string-length (cadr m)))
            (fprintf output "<h~a>~a</h~a>\n" level (render-inline (caddr m)) level))]
      [(regexp-match #px"^[-*+]\\s+(.*)$" line)
       => (lambda (m)
            (unless in-list?
              (displayln "<ul>" output)
              (set! in-list? #t))
            (fprintf output "<li>~a</li>\n" (render-inline (cadr m))))]
      [(regexp-match? #px"^\\s*$" line)
       (close-list!)
       (displayln "" output)]
      [else
       (close-list!)
       (fprintf output "<p>~a</p>\n" (render-inline line))]))
  (close-list!)
  (when in-fence?
    (displayln "</code></pre>" output))
  (get-output-string output))

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

(define (render-preview! markdown-text)
  (define placeholder? (string=? (string-trim markdown-text) ""))
  (define body
    (if placeholder?
        PREVIEW-PLACEHOLDER
        (render-markdown markdown-text)))
  (define html
    (string-append PREVIEW-TEMPLATE-HEAD body PREVIEW-TEMPLATE-FOOT))
  (wkwebview-load-html-string-base-url web-view html #f)
  ;; [preview] rendered — immediately after the loadHTMLString: hand-off
  ;; (contract "Preview events": the event witnesses the hand-off, not the
  ;; pixels). chars = Unicode scalar count of the Markdown source consumed
  ;; (racket string-length counts scalar values).
  (emit-preview-rendered placeholder? (string-length markdown-text)))

(define (current-editor-text)
  (->string (nstextview-string text-view)))

(define (refresh-preview!)
  (render-preview! (current-editor-text)))

(render-preview! "")

;; --- Text-change observer ---
;; NSTextDidChangeNotification fires after every user edit. We register
;; on the text view's notification source only. Keeping the delegate in
;; a module-level variable is required — Cocoa holds observers weakly;
;; a GC'd observer silently stops firing (memory.md).
(define text-change-observer
  (make-delegate
   #:return-types (hash "textDidChange:" 'void)
   #:param-types  (hash "textDidChange:" '(object))
   "textDidChange:"
   (lambda (_note)
     (unless dirty?
       (set! dirty? #t)
       (refresh-title!)
       ;; [document] dirty-changed — the §6.2 clean→dirty FLIP only (never
       ;; per-keystroke), after the title refresh; path is the post-state
       ;; current path. Emitting before refresh-preview! keeps the contract's
       ;; first-keystroke order dirty-changed → rendered.
       (emit-document 'dirty-changed (path-string current-path) #t))
     (refresh-preview!))))

(nsnotificationcenter-add-observer-selector-name-object!
  (nsnotificationcenter-default-center)
  text-change-observer
  "textDidChange:"
  (borrow-objc-object NSTextDidChangeNotification)
  text-view)

;; --- File I/O ---
;; Racket-native file I/O keeps the app out of the NSError ** out-param
;; pattern (which isn't surfaced in the generated bindings for NSString
;; anyway — those methods are filtered). The NSSavePanel / NSOpenPanel
;; bits are what's being exercised here; the bytes-on-disk handling is
;; incidental and well-served by Racket primitives.

(define (load-file! path)
  (with-handlers ([exn:fail? (lambda (e)
                               (set-status! (format "Open failed: ~a" (exn-message e)))
                               ;; [document] open-failed — the ATTEMPTED path
                               ;; (model unchanged by rule §8.5.6), after the
                               ;; status line is set.
                               (emit-document 'open-failed (path-string path) dirty?)
                               #f)])
    (define text (file->string path))
    (nstextview-set-string! text-view text)
    (set! current-path path)
    (set! dirty? #f)
    (refresh-title!)
    (refresh-preview!)
    (set-status! (format "Opened ~a" path))
    ;; [document] opened — post-state at the end of the §8.3 rule (the
    ;; mid-rule refresh-preview! already emitted its rendered line).
    (emit-document 'opened (path-string current-path) dirty?)
    #t))

(define (write-current-file! path)
  (with-handlers ([exn:fail? (lambda (e)
                               (set-status! (format "Save failed: ~a" (exn-message e)))
                               ;; [document] save-failed — the ATTEMPTED path,
                               ;; dirty flag unchanged by rule (§8.5.7), after
                               ;; the status line is set.
                               (emit-document 'save-failed (path-string path) dirty?)
                               #f)])
    (display-to-file (current-editor-text) path #:exists 'replace)
    (set! current-path path)
    (set! dirty? #f)
    (refresh-title!)
    (set-status! (format "Saved ~a" path))
    ;; [document] saved — post-state at the end of the §8.4 write+state rule.
    ;; Reached from BOTH branches: the direct save (do-save! with a current
    ;; path) and the sheet branch (prompt-save!'s completion handler calls
    ;; here), so the sheet-branch emission is inside the completion handler
    ;; by construction (the contract's async re-entry witness). No render
    ;; accompanies a save (§7 excludes it).
    (emit-document 'saved (path-string current-path) dirty?)
    #t))

;; --- Unsaved-changes confirmation ---
(define (confirm-discard? message)
  (cond
    [(not dirty?) #t]
    [else
     (define alert (make-nsalert))
     (nsalert-set-alert-style! alert NSAlertStyleWarning)
     (nsalert-set-message-text! alert message)
     (nsalert-set-informative-text! alert
       "Your changes will be lost if you continue.")
     (nsalert-add-button-with-title! alert "Discard")
     (nsalert-add-button-with-title! alert "Cancel")
     (= (nsalert-run-modal alert) NSAlertFirstButtonReturn)]))

;; --- Save via completion block ---
;; nssavepanel-begin-sheet-modal-for-window-completion-handler! bridges
;; the Racket procedure to an ObjC block with signature (Int64 -> Void).
;; The response code maps to NSModalResponseOK (1) / NSModalResponseCancel (0)
;; etc. The panel is kept alive by the class-wrapper's make-objc-block
;; return for the duration of the modal, so no explicit root is required.
(define (prompt-save!)
  (define panel (nssavepanel-save-panel))
  (nssavepanel-set-can-create-directories! panel #t)
  (nssavepanel-set-nameFieldStringValue-or-default
    panel
    (cond [current-path (display-name-for-path current-path)]
          [else "untitled.md"]))
  (nssavepanel-begin-sheet-modal-for-window-completion-handler!
   panel
   window
   (lambda (response)
     (when (= response NSModalResponseOK)
       (define url (nssavepanel-url panel))
       (when (and url (not (objc-null? url)))
         (define raw-path (->string (nsurl-path url)))
         (unless (string=? raw-path "")
           (write-current-file! raw-path)))))))

;; NSSavePanel's nameFieldStringValue setter may not round-trip cleanly
;; via a string contract on every SDK; wrap defensively.
(define (nssavepanel-set-nameFieldStringValue-or-default panel fallback-name)
  (with-handlers ([exn:fail? (lambda (_) (void))])
    (nssavepanel-set-name-field-string-value! panel fallback-name)))

(define (do-save!)
  (cond [current-path (write-current-file! current-path)]
        [else (prompt-save!)]))

;; --- Open via run-modal ---
;; NSOpenPanel.runModal is synchronous; the completion-block variant is
;; already covered by Save. Filter by file extension array.
(define markdown-extensions
  (list->nsarray
   (list (string->nsstring "md")
         (string->nsstring "markdown")
         (string->nsstring "txt"))))

(define (do-open!)
  (when (confirm-discard? "Discard unsaved changes?")
    (define panel (nsopenpanel-open-panel))
    (nsopenpanel-set-can-choose-files! panel #t)
    (nsopenpanel-set-can-choose-directories! panel #f)
    (nsopenpanel-set-allows-multiple-selection! panel #f)
    (nsopenpanel-set-allowed-file-types! panel markdown-extensions)
    (define response (nsopenpanel-run-modal panel))
    (when (= response NSModalResponseOK)
      (define url (nsopenpanel-url panel))
      (when (and url (not (objc-null? url)))
        (load-file! (->string (nsurl-path url)))))))

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
    (emit-document 'new "" #f)))

;; --- Undo / Redo via NSTextView's undo manager ---
(define (text-view-undo-manager)
  (nstextview-undo-manager text-view))

;; NSUndoManager is wrapped via foundation/nsundomanager.rkt. The undo
;; manager returned by NSTextView is already a live +0 autoreleased
;; object that flows through the class-wrapper param contracts.
(define (do-undo!)
  (define mgr (text-view-undo-manager))
  (when (and mgr (not (objc-null? mgr))
             (nsundomanager-can-undo mgr))
    (nsundomanager-undo mgr)))

(define (do-redo!)
  (define mgr (text-view-undo-manager))
  (when (and mgr (not (objc-null? mgr))
             (nsundomanager-can-redo mgr))
    (nsundomanager-redo mgr)))

;; --- Button targets ---
(define new-target
  (make-delegate
   #:return-types (hash "newDoc:" 'void)
   "newDoc:"
   (lambda (_sender) (do-new!))))
(nsbutton-set-target! new-button new-target)
(nsbutton-set-action! new-button "newDoc:")

(define open-target
  (make-delegate
   #:return-types (hash "openDoc:" 'void)
   "openDoc:"
   (lambda (_sender) (do-open!))))
(nsbutton-set-target! open-button open-target)
(nsbutton-set-action! open-button "openDoc:")

(define save-target
  (make-delegate
   #:return-types (hash "saveDoc:" 'void)
   "saveDoc:"
   (lambda (_sender) (do-save!))))
(nsbutton-set-target! save-button save-target)
(nsbutton-set-action! save-button "saveDoc:")

(define undo-target
  (make-delegate
   #:return-types (hash "undoDoc:" 'void)
   "undoDoc:"
   (lambda (_sender) (do-undo!))))
(nsbutton-set-target! undo-button undo-target)
(nsbutton-set-action! undo-button "undoDoc:")

(define redo-target
  (make-delegate
   #:return-types (hash "redoDoc:" 'void)
   "redoDoc:"
   (lambda (_sender) (do-redo!))))
(nsbutton-set-target! redo-button redo-target)
(nsbutton-set-action! redo-button "redoDoc:")

;; --- Show window and run ---
(refresh-title!)
(nswindow-make-key-and-order-front window #f)
(nsapplication-activate-ignoring-other-apps app #t)

;; §3 step 8 launch diagnostic — dual emission (contract "Lifecycle events"):
;; the stdout line stays (human-friendly when run unbundled, literally true to
;; §3); the same BARE line goes to events.log, where the runner can see it.
(displayln "Note Editor running. Close window or Ctrl+C to exit.")
(emit-launch-line)
(nsapplication-run app)
