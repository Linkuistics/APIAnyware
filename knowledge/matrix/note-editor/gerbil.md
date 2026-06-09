# note-editor x gerbil

**2026-06-09 → 2026-06-10 (standalone, grove leaf `100/070` — ✅ PASS, leaf retired):**
- ✅ Built and **fully VM-verified** on the final fixed build in a no-Gerbil VM. The
  core features were verified 2026-06-09; the two held-over checks (New-clear
  post-fix, Save completion-block sheet) were VM-verified 2026-06-10 after rebuilding
  the missing macOS golden image (`create-golden`). Both PASS. node 100 complete.
  See `generation/targets/gerbil/test-results/note-editor/report.md`.
- **New → Discard:** dirty doc cleared with **no crash** (the `string->nsstring`
  fix); preview→placeholder, status "New document", title reset. **Save…:** real
  NSSavePanel sheet slid down; saved to `~/Documents/gerbil-verify-note.md` (file
  written, title/status updated, dirty cleared) — the `make-objc-block` completion
  handler ran on sheet dismiss (Gambit re-entered from AppKit's runloop end-to-end).
- The capstone: NSTextView+NSScrollView editor + WKWebView preview in an NSSplitView,
  live Markdown→HTML on NSTextDidChangeNotification; NSUndoManager; NSAlert; NSOpenPanel;
  and the first **`make-objc-block` block bridge** (NSSavePanel completion handler).
- **VM-verified (fixed build):** live preview TRACKS edits continuously (H1 + appended
  paragraph both rendered); Undo clears + preview→placeholder; New raises a proper
  NSAlert discard dialog; styled placeholder renders; dirty/title tracking works.
- **Two defects found + fixed:**
  1. **Weak-delegate GC-lifetime (runtime `objc.ss`)** — the most important fix of
     the whole sample-app run. AppKit/NSNotificationCenter hold delegates weakly
     (ADR-0019); under note-editor's per-keystroke HTML-rebuild allocation, Gambit GC
     reaped the `make-delegate` wrappers, their release-wills fired, the ObjC delegates
     deallocated, and ALL callbacks died (preview froze, buttons dead). Fix:
     `make-delegate` pins its instance in a process-global `*delegate-roots*` (the
     `subclass.ss` strong-table discipline). **Hardens every gerbil app**, not just
     this one — the prior apps were fragile, just not allocation-heavy enough to trip it.
  2. **Unwrapped string to `nstext-set-string!` (app)** — `do-new!`/`load-file!` passed
     raw Scheme strings where an NSString pointer is needed; wrap with `string->nsstring`.
     Latent until fix #1 let the callbacks actually run.
- Idiom: editing methods on the NSText superclass (`nstext-string`/`-set-string!`/
  `-set-font!`/`-set-horizontally-resizable!`); `undoManager` on NSResponder; the
  completion block via `(make-objc-block proc (list 'int64) 'void)` (NSModalResponse →
  ptr->int); `with-catch` for guards; Gambit `call-with-input/output-file` for file I/O
  (`read-line port #f` → whole file). [[project_gerbil_grove]]
