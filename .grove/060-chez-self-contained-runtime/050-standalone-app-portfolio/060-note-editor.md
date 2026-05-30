# 060-note-editor

**Kind:** work

## Goal
Build `note-editor` as an open-world standalone `.app` and VM-verify it in a
no-Chez VM.

## Context
- **Block bridge** — a completion handler passed from a Scheme proc into ObjC as a
  block (spec §7). New axis vs `050`: the block ABI path (not just delegate
  selectors), which the [[CONTEXT.md]] notes is built the same `eval`-synthesised
  `foreign-callable` way. Largest app in the portfolio (521 LOC racket) → largest
  import closure, most likely place for fresh wrapper collisions.
- Likely TCC-gated (document access / file save) — **this is the candidate app for
  the TCC-grant-continuity check the node brief requires** (spike F5 deferred it to
  a real TCC-using app). Confirm the standalone binary's `com.linkuistics.*`
  bundle-id + persistent local signing identity still earns the grant in the VM.

## Done when
- `note-editor.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: text entry, edit, the block-driven
  completion path (e.g. save) works end to end, visual bar met.
- **TCC-grant continuity confirmed** on this app (satisfies the node-level
  done-bar), or, if note-editor turns out not to be TCC-gated, a sibling app is
  designated and verified instead — note which in `knowledge/targets/chez.md`.
- Any block-bridge-under-whole-program quirk noted in `knowledge/targets/chez.md`.

## Notes
- If the block never fires, suspect the block trampoline's `eval` synthesis under
  the embedded boot before the app's completion-handler wiring.
