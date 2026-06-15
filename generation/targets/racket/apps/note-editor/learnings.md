# note-editor x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (New/Open/Save/Undo/Redo + status) + split-view editor/preview render.
- 🟢 Text entry into the NSTextView editor works; the right pane live-renders
  Markdown (H1 heading, **bold**, *italic*, line breaks). Title bar tracks the
  edited/dirty state ("Untitled — edited — Note Editor").
- TestAnyware VM (macOS 26.3).
