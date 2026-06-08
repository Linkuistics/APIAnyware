# scenekit-viewer x gerbil

**2026-06-09 (standalone, grove leaf `100/050`):**
- 🟢 Ported and VM-verified as a self-contained `.app` (dylib-clean, SceneKit-linked,
  static Gambit runtime). In a **no-Gerbil VM**: a lit, spinning 3D geometry renders;
  the popup swaps Cube↔Sphere↔Torus↔Cylinder (colour preserved across swaps); the
  Color panel recolours the material live (red→cyan). First gerbil app to render 3D
  content, animate via SCNAction, and drive NSColorPanel from a SceneKit material.
  See `generation/targets/gerbil/test-results/scenekit-viewer/report.md`.
- **Emitter bug fixed (sixth toolchain defect of the sample-app run): `NSError**`
  in the ADR-0006 error-out crossing.** SCNScene's `sceneWithURL:options:error:` is
  the first imported NSError-out-param method; the emitter spelled the cell
  `NSError**` in the msgSend cast, but ADR-0021 includes no Foundation header so
  `NSError` is undeclared (`gxc -O`: `unknown type name 'NSError'`). Fix in
  `emit_class.rs::msgsend_body`: spell it `id*` (= `void *` via `<objc/*>`,
  ABI-identical, always in scope). Goldens re-blessed; bindings regenerated.
- **Protocol-flattening gap (filed to inbox for a follow-up leaf):** the emitter
  emits a class's OWN members but not protocol-declared ones. `runAction:`
  (SCNActionable) and `setAutoenablesDefaultLighting:` (SCNSceneRenderer) are
  unreachable via generated bindings, so the app uses an app-local `begin-ffi`
  raw-`objc_msgSend` shim (the `runtime/cocoa.ss` menu escape hatch). [[project_gerbil_grove]]
- Idiom: popup/button target wired via inherited `nscontrol-set-target!`/`-action!`;
  `make-delegate` instance passed straight to setters; SceneKit geometry factories
  are class methods (`scnbox-box-with-…` etc.); `wrap`→#f makes nil checks plain
  truthiness. All four geometry classes + SCNAction are emitted (earlier doubt was a
  too-narrow grep).
