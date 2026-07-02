# scenekit-viewer (sbcl target)

The 060 ladder's **fourth app**: a SceneKit Viewer — a lit, continuously-spinning 3D
geometry the user swaps via an `NSPopUpButton` (cube / sphere / torus / cylinder) and
recolours via `NSColorPanel`. `SCNView.allowsCameraControl` gives orbit-on-drag +
scroll-to-zoom for free. Written against the CL-family interface contract (ADR-0033 / the
contract spec) — names only the `ns:` surface, `make-instance` typed inits (§3.3), the
per-selector generics (§3.2, incl. the SceneKit class factories via `(eql (find-class
'ns:…))`), and the subclass macros `define-objc-subclass` / `define-objc-method` (§3.4/§3.5).

**Distinctive:** the first GUI ladder app with a **custom Lisp target-action delegate**.
`scene-controller` is a real `define-objc-subclass` of `NSObject`; its `geometryChanged:` /
`openColor:` / `colorChanged:` selectors are **forwarded — bounced to main, GC-safe — into
CLOS `defmethod`s**, exercising the §3.4/§3.5 subclass runtime end-to-end in a *loaded,
dumped* app. It is also the first app to **dump+revive a synthesized subclass** (the ObjC
class pair lives in libobjc, not the Lisp heap, so it re-synthesizes from `-main` in the
revived image, and the runtime re-registers the forwarding dispatcher with the reopened
dylib at revive).

Every SceneKit/AppKit call is plain ObjC (`:load-residual nil`); the app loads
`libAPIAnywareSbcl` **only** for the `aw_sbcl_subclass_*` bounce shim — like
swift-native-probe loads it, but for the subclass machinery rather than trampoline residual.

## AppSpec instrumentation (sbcl-instrument-build-k110)

Instrumented to the logging contract
(`apps/macos/scenekit-viewer/docs/logging-contract.md`): `events.lisp` (pure CL, the
`sv-events` package, loaded first by run.lisp/dump.lisp) writes the structured
`/tmp/scenekit-viewer/events.log` (`SCENEKIT_VIEWER_EVENTS_LOG` overrides) the AppSpec
runner tails — `[lifecycle] startup`/`shutdown`, the bare launch line, and the two
`[scene]` events (`geometry-changed shape="…" r=… g=… b=…` / `color-changed r=… g=… b=…`),
each post-state: one `case` arms both the applied geometry and the event's `shape`
(`make-geometry+title`), and the folded r/g/b are the stored colour as device-RGB ×255
converted at emit time (`current-color-rgb255`). §7.4 was aligned stores-raw →
**keep-previous** here (the stored colour is always device-RGB; conversion failure is a
silent no-op). The `scene-controller` gains the `applicationWillTerminate:` delegate
hook (fourth forwarded selector). Impl descriptor: `scenekit-viewer-impl.rkt`.

## Build

```sh
targets/sbcl/app-implementations/macos/scenekit-viewer/build.sh
```

Produces `build/SceneKitViewer-sbcl.app` (`CFBundleIdentifier
com.linkuistics.scenekit-viewer-sbcl`) via the production bundler
(`apianyware-bundle-sbcl`, ADR-0041): the app's `dump.lisp`
(`save-lisp-and-die :executable t`) behind the Swift stub, with **libzstd** and
**libAPIAnywareSbcl** vendored into `Contents/Frameworks/` — the bundle travels alone
(no `/tmp` staging; the k110 rebuild retired this app's original 060-era staged wrap).
build.sh regenerates the sbcl bindings if SceneKit is absent from the local tree (keyed
on `generated/scenekit/scnview.lisp`) and relinks the dylib in lockstep, then runs the
host construction **pre-flight** + a **revive smoke** through the stub (subclass
re-synthesis + dispatcher re-registration + vendored-dylib reopen).

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Upload the bundle (it travels alone), `xattr -dr com.apple.quarantine`, `open -n`. The
key behaviour to verify is **colour persistence across a geometry swap** (the recoloured
material survives `setGeometry:` — and the `[scene] geometry-changed` event carries the
folded colour, so it is also a single-line log assertion). Tier-2 live-run belongs to
the appspec-scenekit-viewer live-run leaf. See `test-results/scenekit-viewer/report.md`
for the original 060 VM report.
