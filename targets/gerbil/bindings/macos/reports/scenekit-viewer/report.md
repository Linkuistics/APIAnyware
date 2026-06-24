# SceneKit Viewer — Gerbil Test Report

**Date:** 2026-06-09
**Status:** PASS — fifth gerbil sample app. First to render **3D content**
(SceneKit), use SCNAction animation, and drive the shared NSColorPanel from a
SceneKit material. Surfaced + fixed a sixth toolchain/emitter defect (the
`NSError**` error-out crossing) and worked around the protocol-flattening gap.

Done-bar for grove leaf `100-sample-apps/050-scenekit-viewer`: the self-contained
`.app` renders a lit, spinning 3D geometry the user can swap (cube/sphere/torus/
cylinder) and recolor — VM-verified in a **no-Gerbil VM**
([[feedback-vm-verify-every-app]]).

## Build

`cargo run --example bundle_app -p apianyware-bundle-gerbil -- scenekit-viewer`.
Output: `…/apps/scenekit-viewer/build/SceneKit Viewer.app`, bundle id
`com.linkuistics.SceneKitViewer`, codesigned, dylib-clean (SceneKit + system
frameworks + vendored openssl; static Gambit runtime). Build ~11 min cold.

### Emitter bug fixed: `NSError**` in the error-out crossing (ADR-0006)

scnscene.ss's `sceneWithURL:options:error:` is the **first imported class method
with an NSError out-param**, so it was the first to compile the `-e` crossing. The
emitter spelled the cell `NSError**` in the `objc_msgSend` cast — but ADR-0021
includes no Foundation header, so `NSError` is an undeclared type (`gxc -O` hard
error `unknown type name 'NSError'`). **Fix** (`emit_class.rs::msgsend_body`): spell
the out-param `id*` — `id` is libobjc's `void *`, declared by the `<objc/*>`
headers every module includes, so `id*` is ABI-identical to `NSError**` and always
in scope. Goldens re-blessed (testkit/tkmanager, foundation/nsurl), bindings
regenerated.

### Protocol-flattening gap worked around (captured for a follow-up leaf)

The gerbil emitter emits a class's OWN members but not those declared in protocols
it conforms to. Two members this app needs live on protocols:
`runAction:` (SCNActionable, on SCNNode) and `setAutoenablesDefaultLighting:`
(SCNSceneRenderer, on SCNView). The app reaches them through a tiny app-local
`begin-ffi` raw-`objc_msgSend` shim (the same escape hatch `runtime/cocoa.ss` uses
for the menu). The general fix (flatten protocol members onto conforming classes)
is filed to the grove inbox for a dedicated emitter leaf.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26. App tarball
(md5-verified) uploaded, dequarantined, `open -n`. No runtime errors.

Results (`scenekit-viewer-cube.png`, `scenekit-viewer-sphere.png`,
`scenekit-viewer-recolored.png`):

- [x] Window "SceneKit Viewer" with the geometry popup (Cube/Sphere/Torus/
      Cylinder) + Color… toolbar over an SCNView on a dark-gray background.
      Standard app menu reads "SceneKit Viewer".
- [x] **3D geometry renders LIT**: the red chamfered cube shows clear directional
      shading (lighter front, darker sides) — proving the
      `setAutoenablesDefaultLighting:` shim installed SceneKit's default lights
      (not a flat/black unlit render). Material colour red via
      `apply-current-color!` → `scnmaterialproperty-set-contents!`.
- [x] **Geometry spins**: two screenshots ~2 s apart show the cube at different
      rotation angles — the `runAction:` shim installed
      `repeatActionForever(rotateByX:y:z:duration:)` and it animates.
- [x] **Geometry swap**: selecting "Sphere" in the popup ran `geometryChanged:`
      (`nspopupbutton-index-of-selected-item` → `scnnode-set-geometry!`); a lit
      red sphere replaced the cube, and the colour persisted across the swap
      (`apply-current-color!` re-applies to the new geometry's fresh material).
- [x] **Recolour via Color panel**: Color… ran `openColor:` (shared NSColorPanel,
      target/action/continuous); picking cyan in the colour wheel fired
      `colorChanged:` (device-RGB normalise → `set-contents!`); the sphere turned
      cyan live.
- [x] Camera control configured (`allowsCameraControl` — orbit-on-drag/zoom is a
      SceneKit built-in over the live SCNView).

The 3-selector `make-delegate` (geometryChanged:/openColor:/colorChanged:), the
SCNAction spin, SceneKit rendering/lighting, and the material-colour path all work
under whole-program `-O` in a no-Gerbil VM.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].

## Re-verified 2026-06-10 — shim removed (grove leaf 120)

**Status: PASS.** The emitter now flattens conformed-protocol instance
methods/properties onto each bound class (leaf 120), so the app-local
raw-`objc_msgSend` shim documented above is **gone**: the app calls the
generated `scnnode-run-action` (SCNActionable) and
`scnview-set-autoenables-default-lighting!` (SCNSceneRenderer) directly.
Bindings regenerated (+~5.1k protocol-flattened methods across the 6
frameworks; generics 26 → 37 shards); app rebuilt on the bottle toolchain
(generics 149.7 s parallel + closure 82.6 s + link 256.0 s ≈ 8.3 min cold)
and re-verified in the no-Gerbil VM (golden `testanyware-golden-macos-tahoe`,
md5-verified upload, `open -n`, empty stderr log):

- [x] Lit red cube renders with directional shading — proves the **generated**
      `setAutoenablesDefaultLighting:` installs SceneKit's default lights.
- [x] Cube spins (two shots ~2 s apart at clearly different angles) — proves
      the **generated** `runAction:` drives the repeat-forever rotate action.
- [x] Popup swap to Sphere (`geometryChanged:`) — lit red sphere, colour
      persisted across the swap.
- [x] Color… → NSColorPanel → pick cyan on the wheel (`colorChanged:`) — the
      sphere recoloured live; panel closed cleanly.

Screenshots refreshed in place (`scenekit-viewer-cube.png` mid-spin,
`scenekit-viewer-sphere.png`, `scenekit-viewer-recolored.png` cyan).
