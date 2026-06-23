# note-editor (sbcl target — the 060 ladder's 7th app, the capstone)

A Markdown editor with a live HTML preview. The left pane is an `NSTextView` (in an
`NSScrollView`) where you type Markdown; the right pane is a `WKWebView` that
re-renders the text as HTML on every `NSTextDidChangeNotification`. An `NSSplitView`
(vertical divider) holds the two. A toolbar carries **New / Open… / Save… / Undo /
Redo** + a status line. The sbcl analogue of racket/chez/gerbil's `note-editor`.

## What it proves

The **first sbcl app to cross a BLOCK BRIDGE.** `NSSavePanel`'s
`beginSheetModalForWindow:completionHandler:` takes an ObjC block; the emitter wraps
the handler arg in `(aw-block handler)` (token-less — `threading.lisp`), so app code
just hands it a raw Lisp closure. The dylib builds a native block capturing an integer
id; when the save sheet dismisses, the block body **bounces to main** (ADR-0035 — a
no-op pass-through here, the completion fires on main) and re-enters Lisp through the
ONE `aw-block-dispatcher`, handing the closure the `NSModalResponse` as a raw SAP
(read with `sb-sys:sap-int`). The block analogue of mini-browser's
WKNavigationDelegate callbacks.

Also exercised, all on ONE `note-controller` (`define-objc-subclass` of `NSObject`)
carrying SIX selectors in two roles (like mini-browser's eight):
- five toolbar **target-actions** (`newDoc:`/`openDoc:`/`saveDoc:`/`undoDoc:`/`redoDoc:`);
- one **`NSTextDidChangeNotification` observer** (`textDidChange:`) — re-render + mark dirty.

Plus `NSUndoManager` (undo/redo via the text view's manager on `NSResponder`),
`NSAlert` unsaved-changes confirmation, `NSOpenPanel` (runModal), window dirty-state
(`setDocumentEdited:` → close-box dot + title), and a hand-rolled Markdown→HTML
renderer + Lisp-native UTF-8 file I/O.

## Contract surface (ADR-0033)

- **Typed inits (§3.3):** `NSWindow initWithContentRect:…`, `NSTextView`/`NSScrollView`
  `initWithFrame:`, `WKWebView initWithFrame:configuration:`, `NSMutableArray
  initWithCapacity:` — all via `make-instance` + initarg keywords.
- **Per-selector generics (§3.2):** the whole `ns:` method surface.
- **`@"…"` NSString reader (§3.2)** for literals; `(nsstr text)` for dynamic strings.
- **Subclass macros (§3.4/§3.5):** `define-objc-subclass` + `define-objc-method`.
- **Block arg:** `begin-sheet-modal-for-window_completion-handler_` takes a raw closure
  (the emitter applies `aw-block`).

Editor STATE (`current-path`, `dirty`) lives in controller SLOTS, mutated via
`slot-value` (the sbcl idiom for gerbil's closure variables); the pure UI helpers read
those slots with `slot-value`, not per-class accessors (they compile before the inner
`define-objc-subclass` runs — the mini-browser pattern).

## Build & run

```sh
# Dev pre-flight (host construction smoke, no run loop):
SDKROOT=macosx AW_NOTE_SMOKE=1 sbcl --non-interactive --disable-debugger \
  --load apps/note-editor/run.lisp

# Build the standalone .app (pre-flight → dump → revive smoke):
apps/note-editor/build.sh
# → apps/note-editor/build/NoteEditor.app  (save-lisp-and-die :executable t, ~90 MB)
```

The dylib (`libAPIAnywareSbcl`) is loaded for BOTH the `aw_sbcl_subclass_*` bounce shim
(the controller) AND the `aw_sbcl_make_block` block factory (the save handler). The
block dispatcher has no lazy self-init, so the dev path calls
`aw-init-block-dispatcher` explicitly after `aw-load-native-dylib`; the dumped image
gets it via the `*init-hooks*` startup re-resolution pass.

Framework loads: Foundation `:load-residual nil`, AppKit `:load-residual t` (for the
`NSTextDidChangeNotification` constant), WebKit `:load-residual nil`.

## VM provisioning (TestAnyware)

The standalone exe embeds the SBCL core; the VM needs `/tmp/libAPIAnywareSbcl.dylib`
(the recorded dylib path) + the zstd core-compression dylib at
`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib`. **No network** (the preview is local
`loadHTMLString`). See `test-results/note-editor/report.md`.
