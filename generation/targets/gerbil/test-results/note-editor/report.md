# Note Editor — Gerbil Test Report

**Date:** 2026-06-09
**Status:** PARTIAL PASS — built; core capstone features VM-verified on the final
fixed build; two checks (New-clear post-fix, Save completion-block sheet) blocked
by a TestAnyware VM-agent infrastructure failure. **Leaf 070 held LIVE** pending a
clean VM-verify of the two remaining items (operator decision, 2026-06-09).

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

### Blocked (VM-agent infrastructure failure)

After ~8 VM clones this session, TestAnyware's in-VM agent stopped registering on
fresh clones ("Agent not reachable at 192.168.64.x:8648"); the first six VMs were
fine, and a cooldown + clean restart did not recover it — a host-side degradation,
not an app/build problem. The two remaining checks could not be visually completed
on the fixed build:

- [ ] **New → Discard → clears without crash** — the `string->nsstring` fix
      target. The crash WAS reproduced on the pre-fix build (the error named exactly
      `nstext-set-string!` with a `""` string), and the fix wraps both call sites,
      so confidence is high; visual confirmation pending a working VM.
- [ ] **Save completion-block sheet** (`make-objc-block` → NSSavePanel
      `beginSheetModalForWindow:completionHandler:`) — the block bridge is built and
      smoke-tested at leaf 050/020; the in-app save path is unverified live.

**Done-bar status:** the firm VM-verify bar ([[feedback-vm-verify-every-app]]) is
met for the core (live preview, Undo, NSAlert) but NOT for New-clear / Save. Leaf
070 stays LIVE until those two are VM-verified on a working agent.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].
