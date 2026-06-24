# note-editor x chez

**2026-05-29 (source-exec port):**
- 🟡 Block bridge (Save completion handler via `make-objc-block`) fires async +
  writes file; live Markdown preview; undo/redo; gc-count 0→5→0 balance. Required
  the leaf-130 emitter change (bridgeable block params). Source-exec/precompile
  bundle (121 MB). See `targets/chez/bindings/macos/reports/note-editor/report.md`.

**2026-05-30 (standalone, leaf `060/050/060`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.5 MB, kernel baked in) in a **no-Chez VM**. **Block bridge** fires: Save
  completion handler (Scheme lambda → ObjC block) writes the file to
  `~/Documents` (verified on disk). **TCC-grant continuity confirmed** (node
  done-bar): signed standalone wrote to a TCC-protected location cleanly. Live
  Markdown preview + New/discard logic work. RSS ~145 MB. See the report's
  standalone section.
