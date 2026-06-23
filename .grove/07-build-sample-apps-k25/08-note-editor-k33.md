# note-editor-k33

**Kind:** work

## Goal

The 060 ladder's 7th app (spec complexity 6/7): a **Note Editor** — a Markdown
editor with a live HTML preview. Left pane an `NSTextView` (in an `NSScrollView`),
right pane a `WKWebView` re-rendering the Markdown→HTML on every
`NSTextDidChangeNotification`; an `NSSplitView` holds the two. Toolbar:
New / Open… / Save… / Undo / Redo + a status line. Proves the **completion-block
bridge** (`NSSavePanel beginSheetModalForWindow:completionHandler:` → `aw-block`)
on sbcl — the block analogue of mini-browser's delegate callbacks. Written against
the CL-family contract; VM-verified.

## Context

Needs the emitter (040) + runtime (050). All classes are already generated
(AppKit + Foundation + WebKit). The new surface vs. the prior six apps is the
**ObjC block** (`aw-block`): the emitter wraps the savepanel handler arg, so app
code passes a raw Lisp closure that re-enters through the one block dispatcher,
bounced to main (ADR-0035). Also exercises `NSUndoManager` (undo/redo via the
NSTextView's manager on NSResponder), `NSAlert` unsaved-changes confirmation,
`NSOpenPanel` (runModal), an `NSTextDidChangeNotification` observer, window
dirty-state (`setDocumentEdited:`), and hand-rolled Markdown→HTML + Lisp-native
file I/O. One `note-controller` (`define-objc-subclass` of NSObject) carries six
selectors — five toolbar target-actions + the text-change observer — like
mini-browser's eight. AppKit loads `:load-residual t` for the
`NSTextDidChangeNotification` constant (proven by swift-native-probe); the dylib is
loaded for the subclass bounce shim AND the block factory. The block dispatcher has
no lazy self-init, so the dev pre-flight calls `aw-init-block-dispatcher` explicitly.

## Done when

- App built + **TestAnyware VM-verified**, with `learnings.md` +
  `test-results/note-editor/report.md`.

## Notes

**DONE 2026-06-23.** ✅ Built + VM-verified. The capstone — widest feature surface of
any sbcl sample, and the FIRST to cross a **block bridge**.

- One `note-controller` (`define-objc-subclass` of NSObject) carries SIX selectors in
  two roles: five toolbar target-actions (`newDoc:`/`openDoc:`/`saveDoc:`/`undoDoc:`/
  `redoDoc:`) + one `NSTextDidChangeNotification` observer (`textDidChange:`). All six
  kebab generic names are fresh — no collision with an emitted 0-arg method (the
  `reload:`/`reload` class mini-browser fixed).
- **Block bridge VM-verified live:** Save… → `NSSavePanel
  beginSheetModalForWindow:completionHandler:` (the emitter wraps the handler in
  `(aw-block …)`) → the closure bounced to main, read `NSModalResponseOK` from the SAP
  (`sb-sys:sap-int`), and wrote `~/Documents/sbcl-note-verify.md` (112 B, byte-exact
  editor content). First sbcl completion block.
- **Zero runtime + zero emitter changes** — every binding was already generated; the 050
  block + subclass machinery worked as designed. Widest "it just composed" of the ladder.
- **The gerbil weak-delegate GC bug cannot recur:** `*subclass-instances*` is a STRONG
  table, so the per-keystroke Markdown-rebuild allocation storm never reaps the
  controller. Live preview tracked continuous typing with no callback death.
- VM-verified: live preview (H1, H2, bold/italic/code, lists, fenced blocks);
  `setDocumentEdited:` dirty/title; Undo/Redo (NSUndoManager via NSResponder); New →
  NSAlert discard; Open → NSOpenPanel file round-trip; Cmd-Q clean.
- Two dispatcher-init asymmetries handled: `aw-block` has no lazy init (dev path calls
  `aw-init-block-dispatcher` explicitly; dumped image gets it via the startup hook); a
  host block-liveness gate fails before the VM trip. The `@` reader macro is greedy —
  the dynamic-string helper is `nsstr`, not `@str`.
- Frameworks: Foundation `:load-residual nil`, AppKit `:load-residual t` (for
  `NSTextDidChangeNotification`), WebKit `:load-residual nil`. No network (local
  `loadHTMLString` preview).
- Artifacts: `apps/note-editor/{note-editor.lisp,run.lisp,dump.lisp,build.sh,README.md,
  learnings.md}` + `test-results/note-editor/report.md` + 5 screenshots.
