# 100-sample-apps — brief

**Kind:** work

## Goal

Port the remaining 6 sample apps to the gerbil target (hello-window landed in 070),
each **VM-verified via TestAnyware** — visually perfect, not just compile+window.

## Context

The 7-app ladder (same as chez `generation/targets/chez/apps/`): hello-window
(070, done), ui-controls-gallery, drawing-canvas, note-editor, mini-browser,
pdfkit-viewer, scenekit-viewer. Per the firm project rule: every sample-app port
carries a dedicated TestAnyware/VM-verify done-bar — **CLI smoke never satisfies
it** — and apps must be visually perfect (double-click, edit, empty state all
matter), not merely compile+open.

## Decomposition & build order

Decomposed into one leaf per app (010–060). Order encodes risk — simplest first,
WebKit pair (heaviest threading lean) last:

- **010 ui-controls-gallery** — pure AppKit; many controls + target-action
  callbacks (→ blocks). Re-establishes the per-app build/bundle recipe post-070.
- **020 drawing-canvas** — CoreGraphics; custom NSView subclass with `drawRect:`
  override. Hardest test of 050 subclass synthesis.
- **030 pdfkit-viewer** — PDFKit; NSOpenPanel file load.
- **040 scenekit-viewer** — SceneKit; 3D scene, programmatic geometry.
- **050 mini-browser** — WebKit; WKWebView + navigation delegate (080 threading).
- **060 note-editor** — capstone (~603 lines chez); AppKit + WebKit preview.

Each leaf = port (.ss + build.sh, mirroring chez one control at a time) + bundle
(`bundle-gerbil`) + VM-verify. Decompose a leaf further only if an app proves too
big for one session. Use the **bottle** toolchain throughout (070 finding).

## Done when

- All 6 remaining apps emitted, bundled (`bundle-gerbil`), and **VM-verified**.
- Each exercises real framework coverage idiomatically (procedural core for hot
  paths, `:std/generic` veneer at ergonomic sites).
- Any app taking background callbacks respects the 080 threading model.

## Notes

Decompose into per-app leaves (each likely: port + dedicated VM-verify) when
worked. Bundle IDs `com.linkuistics.*`. mini-browser/pdfkit/scenekit may surface
threading needs (080).
