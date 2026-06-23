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
