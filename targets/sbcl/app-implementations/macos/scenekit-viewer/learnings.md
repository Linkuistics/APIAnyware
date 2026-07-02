# scenekit-viewer — learnings (sbcl target, 060 ladder, the 4th app)

The first **GUI ladder app with a custom Lisp target-action delegate** (`scene-controller`,
a real `define-objc-subclass` of `NSObject` whose `geometryChanged:` / `openColor:` /
`colorChanged:` selectors are forwarded — bounced to main — into CLOS `defmethod`s), and
the first to **dump+revive a synthesized subclass**. SceneKit was not in any target's local
IR, so this leaf ran the pipeline for it (resolve→annotate→enrich + `--target sbcl`). It
surfaced two real runtime gaps (both fixed) plus a set of VM-driving lessons.

## Bug FIXED here: a +0 colour does not survive a geometry swap (ObjC ownership)

**Symptom:** recolour the geometry via `NSColorPanel`, then swap geometry from the popup —
the new shape rendered **white**, losing the chosen colour.

**Root cause:** `firstMaterial.diffuse.contents` is kept alive *only* by the material that
retains it. `color-using-color-space_` returns a **+0 autoreleased** `NSColor`, so the Lisp
slot merely *borrowed* it. SceneKit allocates a **fresh `firstMaterial` for every geometry**,
so `geometryChanged:`'s `setGeometry:` deallocates the old material — dropping the colour's
last owner, the autorelease pool already drained — *before* `apply-color-to-node` recolours
the new material. The slot then held a dangling `id`; the re-apply read freed memory → white.

**Fix:** make Lisp an **owner**, not a borrower. `own-color` retains the colour to +1
(`%objc-retain`) and re-wraps with `aw-wrap … t`, which arms the main-thread release
finalizer (ADR-0036) that balances the +1 when the slot's wrapper is GC'd. The colour's
lifetime is now decoupled from any material's. Applied at all three storage sites (the
initial `current-color` + the `colorChanged:` setf). This is the same +0→+1 promotion
`aw-make-nsstring` does for its `stringWithUTF8String:` transient. **VM-verified:** pink
persists across Sphere→Torus→Sphere swaps (was white).

> Pattern for later GUI apps: any +0 accessor result you **store** (vs. immediately pass
> on) must be `own-color`-style owned, or it dies with whatever currently retains it.

## Runtime gap FIXED (`lib/runtime/subclass.lisp`): re-register the dispatcher at revive

First app to dump+revive a synthesized subclass, so it surfaced this. The startup reset
hook cleared the stale synth-class tables but left `*dispatcher-registered*` set — yet the
forwarding-dispatcher SAP handed to the dylib is a foreign pointer into **this image's**
alien-callable trampolines, meaningless after a dump (exactly the block-dispatcher case in
`threading.lisp`). Without re-registration the **first forwarded selector** on a
re-synthesized subclass in a revived image bounced into a null dispatcher. The hook now
clears the flag and re-registers (when the dylib is loaded — a pure-ObjC app is a no-op).
Moved the hook below `aw-init-subclass-dispatcher` so it can see the dispatcher machinery.
Runtime integration smoke suite green with the change.

## Patterns confirmed

- **`SCNAction` lives on the node, not the geometry.** `runAction:` with
  `repeatActionForever:(rotateByX:y:z:duration:)` spins continuously and **survives geometry
  swaps** (`setGeometry:` replaces `node.geometry`, never touching the node's actions).
- **Geometry/action class factories** dispatch via the `(eql (find-class 'ns:…))`
  specializer (contract §3.2): `(ns:box-with-width_height_length_chamfer-radius_ (find-class
  'ns:scn-box) …)`, `(ns:repeat-action-forever_ (find-class 'ns:scn-action) …)`.
- **Build-time vs runtime target/action both forward correctly.** The popup is wired at
  build time (`set-target_`/`set-action_`); the shared `NSColorPanel` is wired at runtime by
  `openColor:` (`setTarget:`/`setAction:`/`setContinuous:`). Both reach the synthesized
  delegate through the same main-bounced forwarding path.
- **Delegate defined inside a function** (`ensure-scene-controller`, called from `-main`) so
  it re-synthesizes in the revived image — the ObjC class pair lives in libobjc, not the Lisp
  heap, so it does not survive `save-lisp-and-die`. `defclass`/`defmethod` re-eval is idempotent.
- **`:load-residual nil`** for every framework: each SceneKit/AppKit call is plain ObjC. The
  dylib is loaded **only** for the `aw_sbcl_subclass_*` bounce shim, not trampoline residual.

## VM-driving lessons (TestAnyware, captured for later GUI apps)

- **AX/click space ≠ screenshot space.** `agent snapshot --json` `positionX/Y` are
  screen-absolute in the **`input click` coordinate space**; the PNG from `screenshot` is
  rendered at ~**0.75×** that space. Click at AX coords, not pixels read off the screenshot —
  mixing them lands clicks on window chrome (a stray title-bar hit even toggled full-screen).
- **Click-through on a non-key window.** A click on a button in a window that is not key just
  *activates* the window; the button fires on the **second** click. Bit the `Colour…` button
  every time the `Colors` panel had stolen key (e.g. after picking a colour).
- **Continuous `NSColorPanel` action wants a drag.** A single `input click` in the colour
  wheel updates the swatch but may not fire the continuous action; `input drag` reliably does.
- **Menu item positions come from the AX tree**, not arithmetic on the popup — a pop-up
  button (not pull-down) re-aligns the menu to the *current* selection, so item Y shifts with
  state. Snapshot the open menu and click the item's reported center.
- macos-tahoe golden gotchas (per [[reference-testanyware-cli]]): disable
  `EnableStandardClickToShowDesktop`; wipe `Saved Application State` for a clean
  windowed launch (the system restores the shared `Colors` panel + any full-screen Space).

## AppSpec instrumentation (sbcl-instrument-build-k110)

Instrumented to the k105 logging contract and rebuilt with the production bundler —
the last of the four scenekit-viewer instrument+build children (k107/k108/k109 the
racket/chez/gerbil precedents). Emitter verified 22/22 in isolation (`sbcl --script`
loads `events.lisp` alone — pure CL — and drives every emitter against the contract
matchers: exact lines, prefix rule, quoting escapes, truncate-on-init, nil-port no-op,
env fallback).

- **§7.4 aligned stores-raw → keep-previous (the k104 seed).** The old `colorChanged:`
  stored `(or rgb raw)` — on a failed device-RGB conversion it stored the *unconverted*
  panel colour. Now conversion failure (and a nil panel colour) is a silent no-op: no
  store, no apply, no event, so the **stored colour is always device-RGB** and the
  emit-time fold is exact. The stderr guard stays stderr (never events.log). aw-wrap's
  NULL→nil mapping means a bare `when` IS the objc-null check on both boundaries.
- **The k107 app shape carried as CL multiple values.** `make-geometry+title` returns
  `(values geom title)` from one `case` (event ≡ applied state by construction); at the
  one call site that only needs the geometry, CL's discard-extra-values semantics make
  it a drop-in (`(ns:node-with-geometry_ … (make-geometry+title 0))`) — no let-values
  dance (racket) and no generics shadow to dodge (gerbil's cons-pair workaround).
- **The fold reads the controller slot, not module state.** Unlike racket (module-level
  `current-color`), the sbcl stored colour lives in the `scene-controller` slot, so
  `current-color-rgb255` takes the colour as an argument; callers pass
  `(slot-value self 'current-color)`. The +0 conversion result inside the fold is read
  immediately (components → integers) within the callback's autorelease scope — no
  ownership dance needed; only the *stored* colour needs `own-color` (+1).
- **Bundler-pattern rebuild (k101).** Retired this app's original 060-era hand-rolled
  wrap (`/tmp/libAPIAnywareSbcl.dylib` staging, unsuffixed bundle id, hand-written
  Info.plist): build.sh now drives `apianyware-bundle-sbcl` + the post-mv PlistBuddy
  id + re-sign dance → `build/SceneKitViewer-sbcl.app`
  (`com.linkuistics.scenekit-viewer-sbcl`), libzstd + libAPIAnywareSbcl vendored, the
  bundle travels alone. The kind-required `CFBundleInfoDictionaryVersion` (the other
  k104 seed) was added to the **bundler's** `write_info_plist` (`"6.0"`, matching the
  racket bundler) rather than patched per-app — every sbcl bundle gets it on rebuild.
- **Dylib currency by the k109 argument, sbcl-flavoured:** `apianyware-generate
  --target sbcl` after the k107 corpus step left bindings + `Trampolines.swift`
  byte-identical (git-clean; trampolines stay 170 — SceneKit adds zero residual
  entries), and the mandated `swift build --product APIAnywareSbcl` relink was a 0.4s
  incremental no-op — both layers agree the committed dylib is current.
- Revive smoke green through the stub: dump+revive + subclass re-synthesis +
  dispatcher re-registration + vendored-dylib reopen, now with the instrumentation
  loaded (`events.lisp` precedes `scenekit-viewer.lisp` in run.lisp/dump.lisp; the
  emitters no-op on the nil port in both smokes — `events-init!` is gated on the real
  run).
