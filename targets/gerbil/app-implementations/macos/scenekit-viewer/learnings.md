# scenekit-viewer x gerbil

**2026-07-03 (AppSpec instrument + build, leaf k109):**
- 🟢 Instrumented to the k105 logging contract
  (`apps/macos/scenekit-viewer/docs/logging-contract.md`): emitter inlined in
  the `.ss` (the k91/k100 rationale — the bundler's closure walk follows only
  `:gerbil-bindings/…` references, and the emitter uses only Gambit
  primitives, so it rides the statically-linked prelude), with the two
  `[scene]` state-transition events (`geometry-changed` / `color-changed`) +
  the contract's string quoting. `[lifecycle] startup` + `sv-events-init!` are
  top-level expressions *before* `(main)` (the viewer builds its window/scene
  in main's defines section), and the launch line is dual-emitted before
  `nsapplication-run`. New `applicationWillTerminate:` delegate →
  `reason=menu`.
- **App-level shape mirrors the racket/chez siblings (k107/k108), with two
  gerbil twists**: `make-geometry+title` single-sources the applied geometry
  and the event's `shape` from one cond — but returns a **cons pair**
  `(geom . title)`, not chez's `(values …)` (a bare `values` in gerbil app
  code risks the wholesale-generics shadow, and the pair is the gerbil
  pdfkit `refresh-ui!` precedent); and the §7.4 keep-previous boundaries need
  no explicit pointer checks — `wrap`→#f makes the pre-existing
  `(when raw …)`/`(when rgb …)` truthiness *be* the nil guards (chez checks
  `(zero? (objc-object-ptr …))`). `current-color-rgb255` folds the stored
  colour to device-RGB ×255 integers at emit time; only the initial
  `systemRedColor` actually converts (consumers never assume its values).
- **The k107 sibling handoff resolved cheaper than expected for gerbil**: ran
  `apianyware-generate --target gerbil` (86 SceneKit files, 66 classes;
  trampoline set stays 170 — SceneKit adds zero gerbil trampolines) and the
  regenerated `Generated/Trampolines.swift` came back **byte-identical
  (git-clean)** — so the existing `libAPIAnywareGerbil.dylib` is current *by
  construction* (built from provably identical source), no relink or `nm -gU`
  diff needed. The k107 stale-dylib class is racket-shaped: racket's native
  lib carries the generated typed dispatch, which grows with SceneKit's new
  ABI shapes; gerbil's dylib is strictly trampoline-only and the dispatch
  growth lands in the gxc-compiled `define-c-lambda`s instead. `git status`
  on the generated Swift is the cheap currency oracle where it's clean.
- 🟢 Emitter verified in isolation against the contract matchers (block
  extracted verbatim from the `.ss` via the section markers, driven under
  plain gxi: 21 assertions — startup-first ordering, launch-line
  `SceneKit Viewer` prefix + bare/unbracketed, both `[scene]` matcher lines
  exact for all four catalogue titles, quoting edges `\\`/`\"`/newline, env +
  fixed-default path resolution with parent-dir creation,
  truncate-on-startup, emit-after-close no-op). Built standalone via new
  `build.sh` (k100 recipe): `SceneKitViewer-gerbil.app` (54 MB; generics 33
  shards 99.1s + facade 10.4s + closure 28 modules 77.9s + exe link 224.6s on
  the cold regenerated cache),
  `CFBundleIdentifier=com.linkuistics.scenekit-viewer-gerbil`,
  `codesign --verify --strict` OK; SceneKit framework-linked,
  `libAPIAnywareGerbil.dylib` vendored into `Contents/Frameworks/` beside the
  openssl pair — `nm -gU` bundled-vs-fresh identical (376 exports).
  Descriptor `scenekit-viewer-impl.rkt` authored. No gcc-15 shim needed — the
  host carries a durable `/opt/homebrew/bin/gcc-15 → gcc-16` symlink. Live
  launch is the Tier-2 live-run leaf's bar (VM).

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
- **Protocol-flattening gap (found here; CLOSED by grove leaf 120, 2026-06-10):**
  the emitter originally emitted a class's OWN members but not protocol-declared
  ones — `runAction:` (SCNActionable) and `setAutoenablesDefaultLighting:`
  (SCNSceneRenderer) were unreachable, and the app carried an app-local
  `begin-ffi` raw-`objc_msgSend` shim. The emitter now flattens conformed-protocol
  members onto each bound class (own protocols only — the manifest hierarchy
  carries ancestor conformances; `ProtocolRegistry` resolves cross-framework
  protocol inheritance); the shim is removed and the app calls
  `scnnode-run-action` / `scnview-set-autoenables-default-lighting!` directly.
  [[project_gerbil_grove]]
- Idiom: popup/button target wired via inherited `nscontrol-set-target!`/`-action!`;
  `make-delegate` instance passed straight to setters; SceneKit geometry factories
  are class methods (`scnbox-box-with-…` etc.); `wrap`→#f makes nil checks plain
  truthiness. All four geometry classes + SCNAction are emitted (earlier doubt was a
  too-narrow grep).
