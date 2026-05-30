# 030-scenekit-viewer

**Kind:** work

## Goal
Build `scenekit-viewer` as an open-world standalone `.app` and VM-verify it in a
no-Chez VM.

## Context
- Single delegate + **SceneKit framework reach** (spec §7). New axis vs `020`:
  pulls in a framework facade (`(apianyware scenekit)`) not exercised by the
  controls gallery, so its import closure / whole-program link surfaces any
  SceneKit-specific dylib-load or symbol issue under the standalone build.
- SceneKit renders via Metal — confirm the standalone binary's dylib-search
  prelude (spike F3) resolves the rendering stack in the VM, not just on the host.

## Done when
- `scenekit-viewer.app` builds via `bundle_app` (open-world standalone).
- TestAnyware run in a no-Chez VM is green: the 3D scene renders (not a blank
  view), delegate fires, visual bar met.
- Any SceneKit-specific standalone quirk noted in `knowledge/targets/chez.md`.

## Notes
- A blank/black SceneKit view in the VM usually means a missing GPU/Metal dylib in
  the standalone closure, not a Scheme-side bug — check the prelude search paths
  first.
