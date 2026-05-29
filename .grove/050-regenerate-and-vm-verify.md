# 050-regenerate-and-vm-verify

**Kind:** work / verify

## Goal
Regenerate the full pipeline on Racket 9.2 + ffi2, then visually verify every
sample app in a macOS VM via TestAnyware. This is the grove's done-bar.

## Context
- Sample apps: `generation/targets/racket/apps/` — drawing-canvas, hello-window,
  mini-browser, note-editor, pdfkit-viewer, scenekit-viewer, ui-controls-gallery.
- Standing rules (memory): never run GUI apps from the CLI — verify in a macOS VM
  via TestAnyware (the unified driver); CLI smoke never satisfies the done-bar;
  sample apps must be *visually perfect* (double-click, edit, empty state all
  matter), so budget polish time, not just compile+window.
- Regenerate aggressively: rerun collect → analyse → generate end-to-end; do not
  trust checkpoint artifacts from earlier leaves.

## Done when
- The full pipeline regenerates clean on 9.2+ffi2 with a green build.
- Each sample app launches and is VM-verified visually via TestAnyware — not just
  "a window appeared", but the app's real interactions look correct.
- Knowledge files (`knowledge/targets/racket.md`, `knowledge/matrix/*/racket.md`)
  reflect the 9.2+ffi2 reality.

## Notes
- If a sample app reveals an FFI gap, that's a regression against 040 — route it
  back as a follow-up leaf under the migration node rather than patching ad hoc.
