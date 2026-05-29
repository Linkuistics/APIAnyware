# 050-standalone-app-portfolio

**Kind:** work

## Goal
Bring the **whole 7-app chez portfolio** to self-contained parity: each sample
app builds as an open-world standalone `.app` and is verified launching + behaving
in a VM with **no Chez installed**. This is the parity bar the grove-root brief
demands ("all 7 sample apps building and passing TestAnyware").

## Context
- Runs after `030`/`040` (standalone is the only path). The spike + `030` proved
  the pipeline on `hello-window`; this leaf covers the other six and re-verifies
  hello-window as a production bundle.
- The 7 apps and their runtime-feature ladder: `docs/specs/2026-05-27-chez-target-design.md`
  §7 — `hello-window`, `ui-controls-gallery`, `scenekit-viewer`, `pdfkit-viewer`,
  `mini-browser`, `note-editor`, `drawing-canvas`.
- The top-level-program wrapper (spec §3) is **per-app**: each app's import
  closure has its own collision set. Watch for collisions beyond hello-window's 4.
- VM-verify discipline: [[feedback-use-testanyware]], [[feedback-vm-verify-every-app]],
  [[reference-testanyware-cli]]. The bar is a no-Chez VM. Apps must be visually
  perfect, not just compile+window ([[feedback-sample-apps-perfect]]).

## Done when
- All 7 apps build as open-world standalone `.app`s via `bundle_app`.
- Each app passes its TestAnyware VM verification in a no-Chez VM; a leaf/app does
  not retire until its run is green.
- Any per-app whole-program surprise (new import collisions, an app relying on a
  retired source-exec helper, an FFI/`lock-object`/guardian quirk under
  whole-program optimisation) is fixed and noted in `knowledge/targets/chez.md`.
- TCC-grant continuity confirmed on at least one TCC-gated app (spike F5 left this
  to a real TCC-using app).

## Notes
- **Decompose when picked** (don't pre-grow now): likely a per-app leaf each, per
  [[feedback-vm-verify-every-app]] ("every sample-app port carries a dedicated
  VM-verify leaf"). The grouping from §7 (delegate trio under one leaf) may or may
  not still fit once standalone-specific issues appear — decide then.
- A regression localises to the most-recently-added runtime feature (the §7
  ladder is ordered for exactly this).
</content>
