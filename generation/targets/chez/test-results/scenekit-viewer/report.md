# SceneKit Viewer — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass

## Build & launch

- Dev-host bundle build: `cargo run --release --example bundle_app -p
  apianyware-macos-bundle-chez -- scenekit-viewer` — **156.7 s**.
- Bundle size: **108 MB** (carries chez-precompiled SceneKit `.so` set).
- In-VM cold launch: window visible **~1 s** after `open -n` (within
  the leaf's 1-3 s precompile-on band). First chez sample that pulls
  the full SceneKit framework set; no first-run penalty over the
  AppKit-only `ui-controls-gallery`.

## Steps Completed
- [x] Window appears: title "SceneKit Viewer", 640×512 content, centred
      (screenshot-001-launch.png).
- [x] Toolbar renders: `[Cube ▾]` popup + `[Color…]` button on a
      horizontal NSStackView pinned to the top with proper autoresize.
- [x] SCNView fills the rest of the window with dark-gray background.
- [x] **Initial geometry — rotating red cube.** Initial geometry index 0
      yields a chamfered NSBox, materialised with `current-color` =
      `nscolor-system-red-color`. Two screenshots taken 2 s apart show
      the cube rotating continuously (front face → corner view) — the
      `scnaction-repeat-action-forever`-wrapped `rotate-by-x-y-z` action
      running on `geometry-node` (screenshot-001-launch.png →
      screenshot-002-rotation.png).
- [x] **`geometryChanged:` delegate selector** — clicking the popup,
      then "Sphere" swaps `geometry-node`'s geometry to
      `scnsphere-sphere-with-radius`. Popup AX value updates to "Sphere".
      The sphere preserves the previous red color, confirming the
      Scheme-side `current-color` state and `apply-current-color!` walk
      through `scnnode-geometry → first-material → diffuse`
      (screenshot-003-sphere.png).
- [x] **`openColor:` delegate selector** — clicking `Color…` opens
      `NSColorPanel` (`agent windows` reports a `(floating) Colors` panel
      alongside the main window). The color panel is wired with this
      delegate as its `target` + `colorChanged:` action and continuous=YES
      (screenshot-004-color-panel.png).
- [x] **`colorChanged:` delegate selector** — clicking into the color
      wheel changes the sphere's diffuse material to the picked color in
      real time. Verified red → blue: the sphere updates with the live
      color, and the color panel's color-well swatch echoes the new
      color. The `nscolor-color-using-color-space` to device-RGB
      conversion runs cleanly with no exception — covers any color-space
      that NSColorPanel might emit (screenshot-005-color-changed.png).
- [x] **SCNView camera-control mouse interaction** — dragging inside the
      view orbits the camera (`allowsCameraControl` working). Lighting
      gradient on the sphere shifts confirming camera-position change
      (screenshot-006-camera-orbit.png).
- [x] `nscolor-dark-gray-color` background renders.
- [x] `autoenablesDefaultLighting` produces visible shading without an
      explicit SCNLight node.
- [x] Cmd+Q exits cleanly.

## Activity Monitor — RSS stability (over 25 s of idle, 5 samples)

In-VM `ps aux` for the chez process:

```
t=5s:  577.016 MB
t=10s: 577.016 MB
t=15s: 577.016 MB
t=20s: 577.016 MB
t=25s: 577.016 MB
```

Zero drift across 5 samples. No unbounded growth despite the continuous
rotation action and the open color panel emitting `colorChanged:`
callbacks (when the picker was previously dragged). Higher baseline
than ui-controls-gallery (525 MB) — the SceneKit framework set
(`apianyware/scenekit/*.so`) adds about 50 MB of resident pages.

## Issues Found

None. The chez delegate trio (`geometryChanged:`, `openColor:`,
`colorChanged:`) in one `make-delegate` record fires correctly across
target-action (popup, button) and NSColorPanel target-action — three
distinct invocation paths share one record without leaking. SceneKit
emission gaps from the design-spec ladder (rung 3) didn't surface:
SCNBox / SCNSphere / SCNScene / SCNNode / SCNAction / SCNMaterial /
SCNMaterialProperty all bind cleanly.

## Notes

- The geometry popup `add-item-with-title!` followed by no explicit
  `selectItemAtIndex:` means initial popup display reads as the first
  added item ("Cube") — that matches the initial geometry-index 0 the
  app starts with. Parity move with racket.
- Menu-bar app name reads "chez" — same stub-launcher concern as the
  other ports, out of this node's scope.
- `agent press --role combo-box --window …` did not resolve the popup;
  pixel click on the popup body + child menu-item pixel worked. A
  `--window` filter combined with `--role` may need a fix in
  TestAnyware's agent query path — captured here as an observation, not
  triaged as a bug.
