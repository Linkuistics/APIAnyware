# scenekit-viewer x chez

**2026-07-03 (AppSpec instrument + build, leaf k108):**
- 🟢 Instrumented to the k105 logging contract
  (`apps/macos/scenekit-viewer/docs/logging-contract.md`): emitter inlined in
  the `.sls` (the k90/k99 rationale — a sibling `events.sls` would need an
  `apps/`-prefixed library name under the whole-program compile tree; only
  `(chezscheme)` names used), `sv-` prefixed, with the two `[scene]`
  state-transition events + the lifecycle triad + the contract's string
  quoting. Startup + test-config no-op are top-level expressions before
  `(main)` (R6RS body semantics, the k90/k99 placement); new
  `applicationWillTerminate:` delegate → `reason=menu`; launch line
  dual-emitted.
- **App-level shape from the racket sibling (k107):** `make-geometry+title`
  arms the applied geometry and the event's `shape` from one cond (event ≡
  applied state, the k98 single-source shape); one emit-time
  `current-color-rgb255` folds the stored colour to device-RGB ×255
  round-to-nearest via `colorUsingColorSpace:` (§7.4-stored colours are
  already device-RGB — only the initial `systemRedColor` converts at emit);
  `colorChanged:` keeps the existing zero-ptr checks on both the raw panel
  colour and the conversion result (§7.4 keep-previous silent no-ops), and
  `color-changed` emits on the success path only, post store+apply.
- **SceneKit bindings had to be regenerated first** (the k107 collection
  landed after the last chez generate): `apianyware-generate --target chez`
  (66 SceneKit classes, 85 files; trampolines stay 170 entries — SceneKit's
  Swift-native surface is almost entirely `deferred_nonbridged_struct_param`)
  + `swift build --product APIAnywareChez` relink, in that order, BEFORE
  bundling ([[swift_build_product_vs_target]]; the k107 stale-dylib class).
  `nm -gU` bundled-vs-fresh diff: symbol sets identical (410 exports).
  build.sh's prereq check keys on `apianyware/scenekit.sls` (the k99 rule).
  Goldens unmoved.
- 🟢 Emitter verified in isolation against the contract matchers (block
  extracted verbatim, `chez --script`, 22 assertions — startup-first ordering,
  bare launch line, contract example lines for both `[scene]` events, quoting
  edges, shutdown reasons, truncate-on-startup, post-close no-op,
  fixed-default path, the ×255 fold arithmetic). Built standalone via new
  `build.sh` (k99 recipe + shared-identity re-sign): `SceneKitViewer-chez.app`
  (5.2 MB), `CFBundleIdentifier=com.linkuistics.scenekit-viewer-chez`,
  bundle carries the fresh dylib at `Contents/Resources/lib/`. Descriptor
  `scenekit-viewer-impl.rkt` authored. Live launch + scene interaction is the
  Tier-2 live-run leaf's bar (VM).

**2026-05-29 (source-exec port):**
- 🟡 3D render + delegate trio (`geometryChanged:`, `openColor:`, `colorChanged:`)
  fire in the TestAnyware VM. Source-exec/precompile bundle (108 MB). See
  `targets/chez/bindings/macos/reports/scenekit-viewer/report.md`.

**2026-05-30 (standalone, leaf `060/050/030`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  5.0 MB, kernel baked in). **SceneKit/Metal renders in a no-Chez VM** — the
  dylib-search prelude resolves the GPU stack at runtime. All three selectors
  fire (cube→sphere swap, color panel opens, red→gray recolor). RSS flat ~126 MB.
  See the "Standalone re-verification" section of the report.
