# note-editor x gerbil

**2026-07-03 (AppSpec instrumentation, `gerbil-instrument-build-k127` — ✅ CLI smoke green):**
- Instrumented to the k123 logging contract via the gerbil house style (the
  mini-browser k118 twin): inline `ne-` emitter (Gambit primitives only — rides the
  statically-linked prelude, no new import), `applicationWillTerminate:` terminate-hook
  app delegate, `startup` + `NOTE_EDITOR_TEST_CONFIG` no-op at top level before
  `(main)` (the def-initializers-evaluate-first rule lands `startup` before
  window/split-view construction). The k125/k126 emission-point pattern held 1:1:
  single 6-event `ne-emit-document` (fixed key order `path`·`dirty`, `(or path "")`),
  `ne-emit-preview-rendered` with `placeholder?` hoisted in `render-preview!`
  (event + body choice share it; `chars` = `string-length` of the Markdown consumed —
  Gambit strings hold scalar values); `dirty-changed` inside the flip arm after the
  title refresh, before the re-render; `opened`/`saved` at rule end (the shared
  `write-current-file!` puts the sheet-branch `saved` inside the `make-objc-block`
  completion handler by construction); failure events after the status set with the
  attempted path; `new` with literal `""`/`#f`.
- **The `string-length` generics-shadow gotcha landed as predicted:** the k116 WebKit
  corpus flattens `stringLength` onto WKWebView, so the regenerated `wkwebview.ss` now
  exports a `string-length` generic (verified in the binding's export list) that would
  shadow the Gambit builtin this module calls throughout (renderer, helpers, emitter).
  `(except-in :gerbil-bindings/webkit/wkwebview string-length)` — loss-free, the app
  never sends stringLength. The pre-instrumentation source (VM-verified 2026-06-10,
  before k116) imported wkwebview bare and would no longer run correctly unfixed.
- **No corpus step** (third impl in a row): adapter tree git-clean, `Trampolines.swift`
  175 `@_cdecl` entries incl. WebKit, dylib newer than the source → the k115 relink
  stands, nothing regenerated. gcc-15 resolves on PATH (Homebrew symlink → gcc-16), so
  the ADR-0021 bottle gotcha never fired.
- Build via the new self-contained `build.sh` (mini-browser k118 recipe: bundle default
  id → rename → PlistBuddy set `com.linkuistics.note-editor-gerbil` → re-sign):
  `NoteEditor-gerbil.app` 64M, codesign strict OK. Timings warm: generics 37 shards
  126s, closure 30 modules (-O) 103s, exe link 269s.
- CLI smoke green: exact launch sequence `[lifecycle] startup` → `[preview] rendered
  placeholder=true chars=0` → bare launch line; AppleScript quit → `[lifecycle]
  shutdown reason=menu`, clean exit, no stray events. The `[document]` events are not
  host-reachable (typing/panels/alert need UI) — witnessed by code audit against the
  contract checklist; live-run exercises them.

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
