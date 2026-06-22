# scenekit-viewer-k30

**Kind:** work

## Goal

The fourth ladder app (guide Step 7): a **SceneKit Viewer** — a lit, continuously-spinning
3D geometry the user swaps via an NSPopUpButton (cube / sphere / torus / cylinder) and
recolours via NSColorPanel — built against the CL-family interface contract (ADR-0033) and
**TestAnyware VM-verified**. The sbcl analogue of racket/chez/gerbil's scenekit-viewer.

Distinctive: this is the **first GUI ladder app with a custom Lisp target-action delegate**
(`geometryChanged:` / `openColor:` / `colorChanged:`) — a real `define-objc-subclass` of
NSObject whose forwarded selectors bounce to main and dispatch into CLOS `defmethod`s — so
it exercises the §3.4/§3.5 subclass runtime end-to-end in a *loaded, dumped* app, and is the
first to dump+revive a synthesized subclass.

## Context

Needs the emitter (040) + runtime (050) working, **plus SceneKit generated** — SceneKit was
not in the local IR for any target, so this leaf ran the pipeline for it
(resolve→annotate→enrich, then `--target sbcl` generation; the LLM annotation
`SceneKit.llm.json` already existed). Like swift-native-probe the app LOADS
`libAPIAnywareSbcl` — but for the subclass bounce shim (`aw_sbcl_subclass_*`), not the
trampoline residual (every SceneKit/AppKit call is plain ObjC → frameworks load
`:load-residual nil`). VM provisioning: the dylib at `/tmp/libAPIAnywareSbcl.dylib` + libzstd.

## Done when

- scenekit-viewer built + VM-verified (3D render, geometry swap, **colour persists across
  swap**, colour panel recolour, Cmd-Q); `learnings.md` + `test-results/scenekit-viewer/
  report.md` (+ screenshots) recorded.

## Status — DONE (2026-06-23): built + VM-verified; colour-persistence bug FIXED

Built + **TestAnyware VM-verified** (golden macos-tahoe). The colour-persistence bug is
fixed and re-verified live. Artifacts written. (Generated SceneKit tree on disk, gitignored;
the dylib + `SceneKitViewer.app` built.)

**Verified live in the VM:**
- Red chamfered SCNBox renders, lit (default lighting), spinning (SCNAction
  repeatActionForever + rotateByX:y:z:duration:). Scene graph scene→node→geometry→material.
- Popup swaps geometry (Cube→Sphere→Torus→Sphere) — `geometryChanged:` delegate works.
- "Colour…" opens + wires NSColorPanel (`openColor:`); picking a colour recolours the
  material live (`colorChanged:`, red→magenta) — device-RGB conversion works.
- **FIXED — colour persists across a geometry swap.** Magenta survives Sphere→Torus→Sphere
  (was WHITE). Fix = `own-color`: retain the +0 device-RGB `NSColor` to +1 (`%objc-retain`)
  and re-wrap `aw-wrap … t` (arms the main-thread release finalizer, ADR-0036), so the stored
  colour outlives `setGeometry:`'s release of the old material. Applied at all 3 storage
  sites (initial `current-color` + the `colorChanged:` setf).
- Cmd-Q terminates cleanly (TERMINATED-OK). Dump+revive of the synthesized subclass green.

**RUNTIME FIX — `lib/runtime/subclass.lisp`:** the subclass forwarding-dispatcher startup
hook now resets `*dispatcher-registered*` and re-registers with the reopened dylib at revive
(mirrors threading.lisp's block-dispatcher hook). Without it, the first forwarded selector in
a revived image hits a null dispatcher. First app to dump+revive a synthesized subclass, so
it surfaced the gap. Runtime integration smoke suite green with this change.

**Artifacts:** `apps/scenekit-viewer/{scenekit-viewer.lisp,run.lisp,dump.lisp,build.sh,
README.md,learnings.md}` + `test-results/scenekit-viewer/report.md` + 3 screenshots
(initial / recoloured / persist). `swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift`
regenerated incl. SceneKit (tracked).

## Notes

- Written against the CL-family contract (ADR-0033) for portability. Per-app artifacts:
  `apps/scenekit-viewer/{source,run,dump,build.sh,README,learnings}` +
  `test-results/scenekit-viewer/report.md`.
