# 130-port-note-editor

**Kind:** work

## Goal
Port `note-editor` to chez. First app with a **block bridge** (a
Scheme procedure passed to ObjC as a completion handler). Validates
`runtime/dispatch.sls`'s `make-objc-block` under real load.

## Context
- `generation/targets/racket/apps/note-editor/note-editor.rkt`.
- `runtime/dispatch.sls`'s block machinery (leaf 040).
- `runtime/objc.sls` — `define-entry-point` wraps the block invoke.

## Done when
- `note-editor.sls` exists, bundles, launches, edits a note, saves it
  (the save uses the completion-block pattern). Reload restores.
  TestAnyware run green.
- A rapid-save loop (type → save → save → save) shows no growth.
- Markdown rendering matches the racket version pixel-equivalently.

## Notes
- Confirm the block is freed correctly when the completion fires. The
  spec calls out `free-objc-block` for synchronous-only APIs; the
  completion handler is async — auto-disposed on Block_release.
  Document the observed pattern.
