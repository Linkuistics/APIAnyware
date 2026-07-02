# instrument-builds-k106 — brief

**Kind:** node (decomposed 2026-07-03 — one instrument+build child per impl, the
k97 split; children materialized lazily, grow the next as each retires)

## Children

1. `racket-instrument-build-k107` ✅ — the reference pattern (events.rkt + wiring +
   self-contained build.sh + descriptor; pdfkit k98 template). Did the SceneKit
   corpus step (collect + deps-together `--only Foundation,AppKit,SceneKit`) the
   siblings inherit. App-level shape the siblings mirror: `make-geometry+title`
   arms geometry and the event's `shape` from one cond (event ≡ applied state);
   one emit-time `current-color-rgb255` device-RGB ×255 fold; §7.4 nil checks
   tightened to objc-null on both raw panel colour and conversion result.
   **Sibling handoff (the k99 twin, sharpened):** SceneKit adds ZERO trampolines
   but GROWS the generated typed dispatch (new ABI shapes — three-float
   `rotateByX:y:z:duration:` et al.), so each sibling still needs its own
   `apianyware-generate --target <t>` + adapter relink (`swift build --product
   APIAnyware<T>`) **before** bundling — a trampoline-count-unchanged log line
   does not mean the dylib is current (k107 caught the stale-dylib class
   host-side via an `nm -gU` bundled-vs-fresh symbol diff); build.sh prereqs key
   on the target's scenekit binding artifact but check the dylib by existence
   only.
2. `chez-instrument-build-k108` ✅ — the k99 pattern (emitter inline in the `.sls`,
   `sv-` prefixed; startup + test-config no-op top-level before `(main)`), the k107
   app-level shape carried over intact (`make-geometry+title` values-pair,
   `current-color-rgb255` emit-time fold — chez already zero-ptr-checked both §7.4
   boundaries). Ran its own `apianyware-generate --target chez` (85 SceneKit files;
   trampolines stay 170) + `APIAnywareChez` relink before bundling; `nm -gU`
   bundled-vs-fresh identical (410 exports — the chez standalone bundle carries the
   dylib at `Contents/Resources/lib/`). Emitter 22/22 in isolation;
   `SceneKitViewer-chez.app` 5.2 MB, id `com.linkuistics.scenekit-viewer-chez`.
3. `gerbil-instrument-build-k109` ✅ — the k100 pattern (emitter inlined in the
   `.ss`, `sv-` prefixed, Gambit primitives only; startup + test-config no-op
   top-level before `(main)`), the k107 app-level shape carried as a **cons
   pair** (`make-geometry+title` → `(geom . title)` — not `values`, dodging the
   generics shadow; `wrap`→#f truthiness IS the §7.4 nil check). Ran its own
   `apianyware-generate --target gerbil` (86 SceneKit files; trampolines stay
   170, `Trampolines.swift` regenerated **byte-identical/git-clean → the
   existing dylib is current by construction** — the gerbil dylib is strictly
   trampoline-only, SceneKit's dispatch growth lives in the gxc-compiled
   c-lambdas, so no `nm` diff needed where git proves source identity — the
   bundled copy was nm-verified identical anyway, 376 exports). Emitter
   21/21 in isolation under gxi. `SceneKitViewer-gerbil.app` 54 MB, id
   `com.linkuistics.scenekit-viewer-gerbil`. No gcc-15 shim needed (host has a
   durable `/opt/homebrew/bin/gcc-15 → gcc-16` symlink).
4. `sbcl-instrument-build-k110` — the k101 pattern; owns the two k104 seeds
   (bundle id + `CFBundleInfoDictionaryVersion`; §7.4 stores-raw →
   keep-previous). Closes the node.

## Goal

Instrument all four scenekit-viewer impls
(`targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/scenekit-viewer/`) to the
k105 conformance contracts and build each to a `.app` — the hello-window k68–k71 /
ui-controls-gallery k88 / pdfkit-viewer k97 stage. Decomposed as a node (one
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
