# 050-standalone-app-portfolio — brief

## Goal
Bring the **whole 7-app chez portfolio** to self-contained parity: each sample
app builds as an open-world standalone `.app` and is verified launching + behaving
in a VM with **no Chez installed**. This is the parity bar the grove-root brief
demands ("all 7 sample apps building and passing TestAnyware").

## Decomposition decision (2026-05-30, at pick)
Decomposed into **one leaf per app (7 leaves)**, ordered by the §7 runtime-feature
ladder — *not* the §7 trio-grouping (apps 2–4 under one leaf). Rationale:

- The §7 trio-grouping was a **porting-phase** decision: apps 2–4 share the same
  delegate runtime piece, so one leaf covered them. The **standalone phase** has a
  different failure axis — the top-level-program wrapper is **per-app** (each
  import closure has its own collision set, spec §3), and each app is an
  independent ~160 s / ~1.6 GB whole-program compile plus a full TestAnyware VM
  cycle. The shared-runtime-piece argument no longer binds them.
- [[feedback-vm-verify-every-app]] requires a **dedicated** VM-verify leaf per app;
  folding three apps' verification into one leaf would violate that.
- The 050 task explicitly deferred this call to pick-time ("decide then").

Ladder order preserved so a regression localises to the most-recently-added
runtime feature:

| Leaf | App | New runtime piece (vs predecessor) |
|------|-----|-------------------------------------|
| `010` | `hello-window` | baseline — re-verify spike/`030` app as a production bundle |
| `020` | `ui-controls-gallery` | sync delegate (NSTextField actions, NSButton target) |
| `030` | `scenekit-viewer` | single delegate, SceneKit reach |
| `040` | `pdfkit-viewer` | multi-delegate |
| `050` | `mini-browser` | async multi-callback delegate (WKNavigationDelegate) |
| `060` | `note-editor` | block bridge (completion handler from a Scheme proc) |
| `070` | `drawing-canvas` | dynamic NSView subclass via `make-dynamic-subclass` |

## Context
- Runs after `030`/`040` (standalone is the only path). The spike + `030` proved
  the pipeline on `hello-window` via `bundle_app` (`bundle-chez/standalone.rs`);
  these leaves cover the other six and re-verify hello-window as a production
  bundle.
- The 7 apps and their runtime-feature ladder: `docs/specs/2026-05-27-chez-target-design.md`
  §7. The standalone pipeline + gotchas (F-findings): the spike report
  `docs/research/2026-05-29-chez-standalone-spike.md` and
  `docs/specs/2026-05-29-chez-standalone-distribution-design.md`.
- The top-level-program wrapper (spec §3) is **per-app**: each app's import
  closure has its own collision set. Watch for collisions beyond hello-window's 4.
- VM-verify discipline: [[feedback-use-testanyware]], [[feedback-vm-verify-every-app]],
  [[reference-testanyware-cli]]. The bar is a no-Chez VM. Apps must be visually
  perfect, not just compile+window ([[feedback-sample-apps-perfect]]).

## Done when (node-level aggregate)
- All 7 per-app leaves retired: each app builds as an open-world standalone `.app`
  via `bundle_app` and passes its TestAnyware VM verification in a no-Chez VM.
- Any per-app whole-program surprise (new import collisions, an app relying on a
  retired source-exec helper, an FFI/`lock-object`/guardian quirk under
  whole-program optimisation) is fixed and noted in `knowledge/targets/chez.md`.
- TCC-grant continuity confirmed on at least one TCC-gated app (spike F5 left this
  to a real TCC-using app).

## Notes
- A regression localises to the most-recently-added runtime feature (the §7
  ladder is ordered for exactly this) — work the leaves in prefix order.
- Per-app leaf bodies carry only what is *specific* to that app; the shared
  build/verify recipe lives here and in the spec, not repeated seven times.
