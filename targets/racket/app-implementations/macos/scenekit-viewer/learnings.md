# scenekit-viewer x racket

**2026-07-03 (racket-instrument-build-k107) — AppSpec logging-contract instrumentation + self-contained build:**
- Instrumented to `apps/macos/scenekit-viewer/docs/logging-contract.md` (k105):
  `events.rkt` (pdfkit k98 template) + wiring — `[lifecycle] startup` before
  window/scene construction, dual-emitted bare launch line, `[scene]
  geometry-changed shape="…" r=… g=… b=…` post swap + §7.2 re-apply, `[scene]
  color-changed r=… g=… b=…` on the panel handler's success path post
  store+apply, `applicationWillTerminate:` delegate → `shutdown reason=menu`.
- rgb folding: one `current-color-rgb255` converts the stored colour to
  device-RGB at emit time (×255 round-to-nearest) — §7.4-stored colours are
  already device-RGB, so only the initial `systemRedColor` actually converts;
  `make-geometry+title` arms geometry and the event's `shape` from one cond so
  event and applied state cannot diverge (the k98 single-source shape).
- The `colorChanged:` handler's nil checks tightened to `objc-null?` (raw panel
  colour + conversion result) — the §7.4 keep-previous silent no-op now holds
  against an objc-nil crossing too, not just #f.
- **SceneKit corpus (the k98 PDFKit twin):** SceneKit was absent from the local
  partial corpus — collected (`SDKROOT=macosx apianyware-collect --only SceneKit`,
  66 classes) + deps-together resolve (`apianyware-analyze --only
  Foundation,AppKit,SceneKit`) + `apianyware-generate --target racket`.
  SceneKit adds ZERO Swift-native trampolines (stays 170 entries — its
  Swift-native surface is almost entirely `deferred_nonbridged_struct_param`,
  the SCNVector3/SCNMatrix4 set) **but it DOES grow the generated typed
  dispatch** (new method ABI shapes, e.g. the three-float
  `rotateByX:y:z:duration:` → new `aw_racket_msg_fff_*` entries): the adapter
  relink (`swift build --product APIAnywareRacket`) is REQUIRED, not hygiene —
  a trampoline-count-unchanged log line does not mean the dylib is current.
  Goldens unmoved.
- **Order matters: generate → relink → bundle.** The first build.sh run bundled
  a pre-relink dylib whose exported-symbol set lacked the new dispatch entries
  the freshly-staged scenekit `.rkt` bindings call (caught by `nm -gU` diff of
  bundled vs fresh dylib — the k39/k40/k41 stale-dylib "symbol not found" class,
  before it could bite in the VM). build.sh's dylib prereq checks existence
  only; when the corpus grows, relink BEFORE bundling.
- `build.sh` (pdfkit k98 mirror): production bundler → rename →
  `com.linkuistics.scenekit-viewer-racket` → re-sign → self-containment gate;
  prereq keys on `generated/scenekit/scnview.rkt` (the k99 rule). Descriptor
  `scenekit-viewer-impl.rkt` authored. Live launch is the Tier-2 live-run bar.
- Host-side `raco make` on the impl source cannot work (the `../../generated/`
  requires resolve only inside the bundler's staged tree) — the bundle step's
  `raco exe` is the compile gate, events.rkt verified in isolation.

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (shape popup / Color…) + SCNView render a lit, continuously-rotating
  3D cube (Metal-backed SceneKit: SCNScene, geometry, material, lighting).
- 🟢 Switching the shape popup (Cube → Torus) rebuilds the scene geometry live.
- TestAnyware VM (macOS 26.3).
