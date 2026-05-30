# 070-drawing-canvas

**Kind:** work

## Goal
Build `drawing-canvas` as an open-world standalone `.app` and VM-verify it in a
no-Chez VM. **Last leaf of the portfolio node** — its retirement empties `050`.

## Context
- **Dynamic NSView subclass** via `make-dynamic-subclass` (spec §7). The most
  demanding runtime axis: a *new ObjC class registered at runtime* with
  Scheme-implemented method IMPs (`drawRect:`, mouse events). The IMPs are
  `foreign-callable` trampolines `eval`'d into existence — so this app is the
  hardest test of the embedded-`scheme`-boot compiler in the standalone binary.
  If runtime class creation survives whole-program optimisation here, the
  open-world self-containment claim is fully proven across the ladder.

## Done when
- `drawing-canvas.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: the canvas draws on mouse drag
  (`drawRect:` + event IMPs fire from the dynamically-registered subclass), visual
  bar met.
- Any dynamic-subclass-under-whole-program quirk noted in
  `knowledge/targets/chez.md`.

## Notes
- This is the capstone for the embedded-compiler claim: `make-dynamic-subclass`
  needs `eval` at runtime, which is exactly what the open-world full-`scheme` boot
  exists to provide. A failure here that worked source-exec would mean the embedded
  boot's `eval`/`interaction-environment` differs from the system REPL's.
- On retirement, the parent-chain walk reaches `060-chez-self-contained-runtime`:
  only `060-standalone-toolchain-docs` remains live there, so the node does **not**
  yet empty.
