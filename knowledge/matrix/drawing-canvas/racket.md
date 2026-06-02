# drawing-canvas x racket

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (Color… / brush-width slider / Clear) + empty canvas render correctly.
- 🟢 Live freehand drawing works: three mouse-drag strokes produced three smooth
  black lines — exercises `mouseDragged` event handling, the drawing path, and
  canvas redraw through generated AppKit/CoreGraphics bindings + native dispatch.
- TestAnyware VM (macOS 26.3).
