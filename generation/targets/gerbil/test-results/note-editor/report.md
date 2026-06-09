# Note Editor — Gerbil Test Report

**Date:** 2026-06-09 (core); 2026-06-10 (remaining two checks)
**Status:** PASS — built; **all** capstone features VM-verified on the final fixed
build. The two checks held over on 2026-06-09 (New-clear post-fix, Save
completion-block sheet) were VM-verified on 2026-06-10 after rebuilding the missing
macOS golden image; both PASS. Leaf 070 retired (node 100 complete).

The widest feature surface of any gerbil sample and the first to cross a
**block bridge** (`make-objc-block` for NSSavePanel's completion handler). Markdown
editor with live HTML preview: NSTextView+NSScrollView editor (left), WKWebView
preview (right) in an NSSplitView, re-rendering on every NSTextDidChangeNotification;
NSUndoManager undo/redo; NSAlert confirmations; NSOpenPanel.

## Build

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- note-editor`.
Output: `…/apps/note-editor/build/Note Editor.app`, bundle id
`com.linkuistics.NoteEditor`, codesigned, dylib-clean (WebKit + system frameworks +
vendored openssl; static Gambit runtime). Built clean after the two fixes below.

### Two defects found + fixed

1. **Weak-delegate GC-lifetime (runtime, `objc.ss`).** AppKit / NSNotificationCenter
   hold delegates WEAKLY (ADR-0019); the only strong ref was the Gerbil `wrap`per,
   kept reachable across the `nsapplication-run` FFI boundary. note-editor rebuilds
   its HTML preview on every keystroke, so it allocates enough to trigger Gambit GC
   mid-run — which reaped the delegate wrappers, fired their release-wills,
   deallocated the ObjC delegates, and silently killed ALL callbacks (the live
   preview froze; toolbar buttons went dead). The lighter prior apps never allocated
   hard enough to hit this. **Fix:** `make-delegate` now pins its instance in a
   process-global root (`*delegate-roots*`), the strong-table discipline
   `subclass.ss` already uses for synthesized instances. Hardens every app.
2. **Unwrapped string to `nstext-set-string!` (app).** `do-new!` and `load-file!`
   passed a raw Scheme string to the NSText setter, which wants an NSString pointer
   (`"Can't convert to C pointer"`). Latent until fix #1 let `do-new!` actually run.
   **Fix:** wrap with `string->nsstring`.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26. Verified on the **final
fixed build** (delegate-pin + string-wrap):

- [x] Window "Untitled — Note Editor" with toolbar (New/Open…/Save…/Undo/Redo +
      "Ready" status), NSSplitView vertical divider, empty NSTextView editor (left,
      fixed-pitch), and a WKWebView (right) **rendering the styled placeholder**
      "Start typing Markdown on the left…". Standard app menu reads "Note Editor".
- [x] **Live Markdown→HTML preview TRACKS edits continuously** (the signature
      feature, restored by the delegate-pin fix): typing `# Hello…` rendered a real
      H1, and appending a second paragraph updated the preview to include it —
      confirmed across multiple successive edits. The title flips to
      "Untitled — edited — Note Editor" on first edit (dirty tracking +
      `setDocumentEdited:`).
- [x] **Undo** (toolbar `undoDoc:` → `nsresponder-undo-manager` → NSUndoManager):
      clicking Undo cleared the editor and the preview reverted to the placeholder —
      proving toolbar callbacks fire (also restored by the delegate-pin fix) and the
      preview tracks the undo.
- [x] **NSAlert discard confirmation**: clicking New raised a proper alert
      ("Discard unsaved changes and start a new note?" / "Your changes will be lost
      if you continue." / Discard + Cancel) — `make-nsalert` +
      message/informative/`add-button-with-title!` + `run-modal`.

### The two held-over checks — VM-verified 2026-06-10 (both PASS)

On 2026-06-09 these were blocked: after ~8 VM clones the in-VM agent stopped
registering on fresh clones. The deeper cause surfaced on 2026-06-10 — the macOS
golden image was gone entirely (not a transient agent failure). Rebuilding it
(`testanyware vm create-golden --platform macos`, 5-boot provisioning, both TCC
grants verified) restored a clean VM, on which both checks PASS on the same fixed
build:

- [x] **New → Discard → clears without crash** — the `string->nsstring` fix target.
      With a dirty document (`# Draft Note…`, title "Untitled — edited"), clicking
      New raised the NSAlert; clicking **Discard** cleared the editor, reverted the
      preview to the styled placeholder, set the status line to "New document", and
      reset the title to "Untitled — Note Editor" — **no crash** (process stayed
      ALIVE; app log clean). Pre-fix this crashed on `nstext-set-string!` with a
      `""` string. (`note-editor-new-discard.png`)
- [x] **Save completion-block sheet** (`make-objc-block` → NSSavePanel
      `beginSheetModalForWindow:completionHandler:`) — clicking **Save…** slid down
      a real NSSavePanel sheet (Save As / Tags / Where: Documents / Cancel + Save).
      Naming the file `gerbil-verify-note.md` and clicking **Save** wrote
      `/Users/admin/Documents/gerbil-verify-note.md` (contents `# Saved Note`), set
      the status line to "Saved /Users/admin/Documents/gerbil-verify-note.md", and
      retitled the window to "gerbil-verify-note.md — Note Editor" (dirty cleared).
      **The completion block ran on sheet dismiss** — Gambit re-entered from AppKit's
      runloop through the block IMP trampoline, received the NSModalResponse + chosen
      URL, and ran the Gerbil file-write. End-to-end block bridge confirmed in-app.
      (`note-editor-save-sheet.png`, `note-editor-saved.png`)

**Done-bar status:** the firm VM-verify bar ([[feedback-vm-verify-every-app]]) is
**met in full** — live preview, Undo, NSAlert, New-clear, and Save all visually
verified on the fixed build.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].
