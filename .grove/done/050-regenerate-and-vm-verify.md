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

## Carryover from node 040 (promoted on retirement; all 040 leaves done)
- **Foundation/AppKit subset goldens are stale.** 040's cutover changed the
  emitter's dispatch output, but `tests/golden-foundation/` and
  `tests/golden-appkit/` could not be regenerated without local enriched IR
  (their suites *skip* without it). Only the synthetic TestKit golden was
  regenerated. The full-pipeline regen here must `UPDATE_GOLDEN=1` these two once
  IR exists — and is where real generated bindings first execute through the
  native dispatch path (runtime smoke / VM-verify).
- **Build order inverted (ADR-0013): `generate → swift build`.** `generate` now
  writes `swift/Sources/APIAnywareRacket/Generated/Dispatch.swift` (gitignored);
  `swift build` compiles it into the dylib. Run generate *before* swift build.
- **Verify the `lib/libAPIAnywareRacket.dylib` symlink resolves into THIS
  worktree.** 040 flagged a latent bug (symlink pointing at the main repo's
  `.build`, which lacks the worktree's generated `aw_racket_msg_*` entries). As
  of 060 the tracked symlink is the *relative* path
  `../../../../swift/.build/arm64-apple-macosx/debug/libAPIAnywareRacket.dylib`,
  which resolves inside the worktree — confirm it still does after regen, since
  050 is where generated bindings first load here.
- **060 made the dylib mandatory.** The runtime now errors clearly if the dylib
  is absent/stale (no `swift-available?` fallback) — so a regen that forgets the
  `generate → swift build` order will fail loudly at runtime-load, not silently
  degrade. `test-generated-smoke` needs the regenerated `generated/` dir to pass.

## Notes
- If a sample app reveals an FFI gap, that's a regression against 040 — route it
  back as a follow-up leaf under the migration node rather than patching ad hoc.
