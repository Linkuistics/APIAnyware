# 090-sample-apps

**Kind:** work

## Goal

Port the remaining 6 sample apps to the gerbil target (hello-window landed in 070),
each **VM-verified via TestAnyware** — visually perfect, not just compile+window.

## Context

The 7-app ladder (same as chez `generation/targets/chez/apps/`): hello-window
(070), ui-controls-gallery, drawing-canvas, note-editor, mini-browser,
pdfkit-viewer, scenekit-viewer. This leaf will be **decomposed into a node** with
one child leaf per app (lazy decomposition — `grove-llm leaf-decompose` + per-app
`leaf-add` when this is picked). Per the firm project rule: every sample-app port
carries a dedicated TestAnyware/VM-verify done-bar — **CLI smoke never satisfies
it** — and apps must be visually perfect (double-click, edit, empty state all
matter), not merely compile+open.

## Done when

- All 6 remaining apps emitted, bundled (`bundle-gerbil`), and **VM-verified**.
- Each exercises real framework coverage idiomatically (procedural core for hot
  paths, `:std/generic` veneer at ergonomic sites).
- Any app taking background callbacks respects the 080 threading model.

## Notes

Decompose into per-app leaves (each likely: port + dedicated VM-verify) when
worked. Bundle IDs `com.linkuistics.*`. mini-browser/pdfkit/scenekit may surface
threading needs (080).
