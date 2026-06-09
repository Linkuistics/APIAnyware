# 070-note-editor

**Kind:** work

## Status: HELD LIVE (2026-06-09) — built + core VM-verified; 2 checks blocked

The capstone Markdown editor with live HTML preview is **ported and built**
(`apps/note-editor/note-editor.ss`, `com.linkuistics.NoteEditor`). Two defects
were found + fixed and are committed:
- `runtime/objc.ss`: `make-delegate` now pins its instance in `*delegate-roots*`
  (weak-delegate GC-lifetime fix — hardens all apps).
- app: `do-new!`/`load-file!` wrap strings with `string->nsstring`.

**VM-verified on the fixed build** (no-Gerbil VM): live Markdown preview TRACKS
edits continuously; Undo clears + preview→placeholder; New raises the NSAlert
discard dialog; styled placeholder renders; dirty/title tracking.

## Remaining to retire this leaf

A TestAnyware VM-agent infrastructure failure (agent stopped registering on fresh
clones after ~8 this session) blocked the last two checks. When a working VM agent
is available, VM-verify on the existing built `.app`:

1. **New → Discard → editor clears with NO crash** (the `string->nsstring` fix;
   crash was reproduced pre-fix, fix is exactly targeted — high confidence).
2. **Save… opens the completion-block sheet** (`make-objc-block` → NSSavePanel
   `beginSheetModalForWindow:completionHandler:`); Cancel it. Optionally type +
   Save to a path and confirm the file writes (the block handler runs on sheet
   dismiss).

Update `test-results/note-editor/report.md` + `knowledge/matrix/note-editor/gerbil.md`
from PARTIAL to PASS, then `grove-llm leaf-retire` this leaf (completing node 100).
