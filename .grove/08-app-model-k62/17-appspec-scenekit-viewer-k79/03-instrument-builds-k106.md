# instrument-builds-k106

**Kind:** work

## Goal

Instrument all four scenekit-viewer impls
(`targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/scenekit-viewer/`) to the
k105 conformance contracts and build each to a `.app` — the hello-window k68–k71 /
ui-controls-gallery k88 / pdfkit-viewer k97 stage. **Likely a node** (one
instrument+build child per impl — the k97 split); `leaf-decompose` on entry, first
child (racket, the reference pattern) this session.

## Context

- The contracts to implement verbatim:
  `apps/macos/scenekit-viewer/docs/{logging-contract,observable-state}.md`. Per-impl
  checklist at the end of the logging contract. Events: `[lifecycle] startup`, the bare
  launch line beginning `SceneKit Viewer`, `[scene] geometry-changed shape="…" r=… g=…
  b=…` (picker handler, post swap + colour re-apply — the folded rgb is the stored
  colour as device-RGB ×255 round-to-nearest integers, converted at emit time),
  `[scene] color-changed r=… g=… b=…` (§7.4 success path only; silent no-ops emit
  nothing), `[lifecycle] shutdown reason=<r>` — all post-state (k77 rule).
- **Emission points already exist in every impl:** the `geometryChanged:` handler (emit
  after `setGeometry:` + §7.2 re-apply) and the `colorChanged:` handler success path
  (emit after store + apply; the racket/sbcl stderr guard lines stay stderr). The
  `applicationWillTerminate:` hook is the instrumentation's addition, as in all three
  prior apps.
- **Alignments seeded from k104/k105** (fold into the owning impl's child):
  - sbcl `build.sh`: bundle id must become `com.linkuistics.scenekit-viewer-sbcl`
    (today unsuffixed) and Info.plist lacks the kind-required
    `CFBundleInfoDictionaryVersion`.
  - sbcl §7.4 conversion-failure divergence: align stores-raw → keep-previous (the
    contract's stored-colour-is-always-device-RGB invariant).
- Reference emitters: `targets/<t>/app-implementations/macos/{hello-window,
  ui-controls-gallery,pdfkit-viewer}/events.*` (racket `events.rkt` + counterparts;
  pdfkit k98's `emit-launch-line` naming).
- **Expect the k98 corpus twin:** the local corpus is partial (Foundation+AppKit) —
  SceneKit likely needs `SDKROOT=macosx apianyware-collect --only SceneKit` once, then
  resolve **deps together** (`apianyware-analyze --only Foundation,AppKit,SceneKit`),
  then per-target `apianyware-generate --target <t>` + adapter dylib relink
  (`swift build --product APIAnyware<T>`, never `--target`). Goldens must not move.

## Done when

All four impls emit the contract events (CLI smoke of the event stream where
observable) and build to `.app` bundles with the right `CFBundleIdentifier`. Live-VM
verification is **not** this leaf's bar — it belongs to the live-run stage
([[vm_verify_every_app]] is closed by the node's final child).

## Notes

Instrumentation must not change visible behaviour (no new UI, no error dialogs — spec
§12). Consumers never count `[scene]` events (continuous panel; unconditional swap
handler) — the contract's matchers assume content-match only.
