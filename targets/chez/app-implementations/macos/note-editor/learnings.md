# note-editor x chez

**2026-05-29 (source-exec port):**
- 🟡 Block bridge (Save completion handler via `make-objc-block`) fires async +
  writes file; live Markdown preview; undo/redo; gc-count 0→5→0 balance. Required
  the leaf-130 emitter change (bridgeable block params). Source-exec/precompile
  bundle (121 MB). See `targets/chez/bindings/macos/reports/note-editor/report.md`.

**2026-07-03 (instrument+build, `chez-instrument-build-k126`):**
- 🟢 Instrumented to the k123 logging contract as the k125 racket mirror via the
  mini-browser k117 house style (inline `ne-` emitter, startup + test-config
  no-op top-level before `(main)`, terminate-hook app delegate). No deviation
  from the reference pattern: the sheet-branch `saved` lands inside the
  completion handler by construction (the shared `write-current-file!`), the
  flip-arm `dirty-changed` precedes the re-render, failure events carry the
  attempted path after the status set. No corpus step: `Trampolines.swift`
  git-clean + adapter dylib newer (175 `@_cdecl` entries incl. WebKit — the
  k117 relink stands). `NoteEditor-chez.app` 5.7M,
  `com.linkuistics.note-editor-chez`. CLI smoke green: exact launch sequence
  `startup` → `rendered placeholder=true chars=0` → bare launch line;
  AppleScript quit → `shutdown reason=menu`; no stray events. The
  `[document]` events are not host-reachable (UI interaction) — witnessed by
  code audit against the contract checklist; live-run exercises them.

**2026-05-30 (standalone, leaf `060/050/060`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.5 MB, kernel baked in) in a **no-Chez VM**. **Block bridge** fires: Save
  completion handler (Scheme lambda → ObjC block) writes the file to
  `~/Documents` (verified on disk). **TCC-grant continuity confirmed** (node
  done-bar): signed standalone wrote to a TCC-protected location cleanly. Live
  Markdown preview + New/discard logic work. RSS ~145 MB. See the report's
  standalone section.
