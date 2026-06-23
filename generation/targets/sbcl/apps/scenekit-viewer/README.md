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

## Build

```sh
# prerequisites: generated bindings fresh (incl. SceneKit) + the dylib built
SDKROOT=macosx cargo run -p apianyware-macos-generate -- --target sbcl
SDKROOT=macosx swift build --package-path swift --product APIAnywareSbcl
# then:
generation/targets/sbcl/apps/scenekit-viewer/build.sh
```

Produces `build/SceneKitViewer.app` (a standalone `save-lisp-and-die :executable t` dump).
`build.sh` stages the dylib at `/tmp/libAPIAnywareSbcl.dylib` (the revive auto-reopen path,
ADR-0038 §5), runs the host construction **pre-flight** + a **revive smoke** (the dump+revive
**with** the dylib + subclass re-synthesis + dispatcher re-registration) before the bundle.

## VM-verify (never run GUI apps from the CLI — use TestAnyware)

Provision the VM with `/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` (SBCL core-compression
dep) and `/tmp/libAPIAnywareSbcl.dylib` (the subclass bounce shim) — no SBCL install needed
(the image is embedded). Upload the bundle, `xattr -dr com.apple.quarantine`, `open -n`. The
key behaviour to verify is **colour persistence across a geometry swap** (the recoloured
material survives `setGeometry:`). See `test-results/scenekit-viewer/report.md`.
