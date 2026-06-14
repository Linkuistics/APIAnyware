# Note Editor

**Complexity:** 6/7
**Key features exercised:** NSSplitView, NSTextView, WKWebView loadHTMLString,
NSNotificationCenter observer, NSSavePanel completion block, NSOpenPanel,
NSAlert unsaved-changes confirmation, NSUndoManager (via NSTextView), window
dirty-state tracking.

## Purpose

Markdown editor with live HTML preview. The left pane is a plain `NSTextView`
where the user types Markdown; the right pane is a `WKWebView` that renders the
text as HTML each time the editor fires `NSTextDidChangeNotification`.
Demonstrates cross-framework integration (AppKit + WebKit + Foundation), the
async completion-block idiom on `NSSavePanel`, notification observer lifetime
management, and window dirty-state tracking via `setDocumentEdited:`.

## Window Layout

- **Window:**
  - Title: "Untitled — Note Editor" (or "<filename> — edited" once modified)
  - Size: 900 x 600 points
  - Position: centered on screen
  - Style: titled, closable, miniaturizable, resizable
  - Minimum size: 520 x 360

- **Toolbar** (top, horizontal NSStackView):
  - **New** — clears editor, title resets to Untitled
  - **Open…** — `NSOpenPanel` for `.md` / `.markdown` / `.txt` files
  - **Save…** — `NSSavePanel` first time, direct write thereafter
  - **Undo** / **Redo** — buttons plus Cmd-Z / Cmd-Shift-Z
  - Status label on the right (file path + saved/edited indicator)

- **Split view** (fills remaining space, vertical divider):
  - Left: `NSScrollView` containing `NSTextView`, default system font 13pt,
    line wrapping enabled, `allowsUndo: YES`
  - Right: `WKWebView` with an inline HTML template. The template includes a
    small JavaScript function that receives the raw Markdown via
    `loadHTMLString` and renders it with a stripped-down Markdown-to-HTML
    conversion (headings, emphasis, code spans, fenced blocks, lists, links).

## Behavior

1. Launch with an empty editor, preview shows "Start typing…" placeholder.
2. Typing in the editor fires `NSTextDidChangeNotification`; the observer
   re-renders the preview by calling `loadHTMLString` with the fresh text
   interpolated into the HTML template, and sets `setDocumentEdited: YES`.
3. **Open…** — `NSOpenPanel` filtered to `.md`/`.markdown`/`.txt`; the
   selected file is read via Racket's `file->string` and its content replaces
   the editor text. Title updates, dirty flag clears.
4. **Save…** — first save goes through `NSSavePanel` using
   `begin-sheet-modal-for-window-completion-handler:` so we exercise the
   completion-block pattern. Subsequent saves to the same file write directly.
5. **New** — if the document is edited, an `NSAlert` confirms discard; clearing
   the editor resets the path and dirty flag.
6. **Undo / Redo** — forwarded to `NSTextView`'s built-in undo manager.
7. Closing the window quits the app (standard NSApplicationDelegate hook).

## API Surface

| API | Usage |
|-----|-------|
| `NSSplitView` | Side-by-side editor + preview |
| `NSTextView` | Markdown editor |
| `NSScrollView` | Scrollable container for NSTextView |
| `NSTextView.allowsUndo` | Built-in undo support |
| `NSTextView.undoManager` | Exposed for button-driven undo/redo |
| `WKWebView.loadHTMLString:baseURL:` | Preview rendering |
| `NSNotificationCenter` | Observe `NSTextDidChangeNotification` |
| `NSSavePanel.beginSheetModalForWindow:completionHandler:` | Async save |
| `NSOpenPanel.runModal` | Synchronous open |
| `NSAlert.runModal` | Unsaved-changes confirmation |
| `NSWindow.setDocumentEdited:` | Dirty-state indicator in title bar |
| Racket `file->string` / `display-to-file` | File I/O (Racket-native) |

## Patterns Exercised

- **NSNotificationCenter observer** — `addObserver:selector:name:object:` on
  `NSTextDidChangeNotification`, observer stored in module-level variable so
  Cocoa's weak observer retention does not drop it.
- **Completion-block bridge** — `make-objc-block` via the generated
  `nssavepanel-begin-sheet-modal-for-window-completion-handler!` with a Racket
  procedure that receives the modal response code.
- **`WKWebView.loadHTMLString`** — HTML-as-string rendering instead of URL
  navigation. Tests base-URL parameter handling.
- **Dirty-state tracking** — `setDocumentEdited:` drives the close-box dot and
  our status label; observer-driven update on every keystroke.
- **Cross-framework import** — AppKit + Foundation + WebKit in a single app
  (previously only Mini Browser did this).

## Success Criteria

- Split view visible on launch with empty editor and placeholder preview.
- Typing `# Hello` updates the preview to show an `<h1>` rendering of "Hello".
- `setDocumentEdited:` reflects in the close-box indicator (filled dot).
- Save… opens `NSSavePanel`, writes the file, clears the dirty indicator,
  and updates the window title to the saved path.
- Re-opening the saved file loads the same content.
- Undo button reverts typing; Redo restores it.
- "New" with unsaved changes triggers an `NSAlert` confirmation dialog.
