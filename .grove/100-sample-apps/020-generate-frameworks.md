# 020-generate-frameworks

**Kind:** work

## Goal

Generate the gerbil bindings for the four frameworks the remaining sample apps
need but that 070/010 never emitted: **CoreGraphics** (drawing-canvas),
**PDFKit** (pdfkit-viewer), **SceneKit** (scenekit-viewer), **WebKit**
(mini-browser, note-editor). Prerequisite for leaves 030–070.

## Context

Discovered porting ui-controls-gallery (010): 070/010 only emitted AppKit +
Foundation (the only enriched IR present locally); `lib/` has exactly those two
frameworks + runtime + generics. ui-controls-gallery is pure AppKit so it sailed
through; every later app needs a framework with **no gerbil bindings yet**.

Pipeline state at discovery:
- `collection/ir/collected/`: 2 (AppKit, Foundation only).
- `analysis/ir/enriched/`: 2 (AppKit, Foundation).
- `analysis/ir/llm-annotations/`: 152 committed, **including PDFKit, SceneKit,
  WebKit, _WebKit_SwiftUI** — the expensive LLM step is already done for those.
  No CoreGraphics annotation (C API; confirm whether the gerbil emitter needs
  one or emits it mechanically like the runtime's hand-written CG geometry).

Approach (chosen with user 2026-06-08): **generate all four upfront** in one
pipeline pass (regenerate-pipeline-aggressively), not per-app. Follow 070/010's
recipe + `docs/adding-a-language-target.md`:
1. `SDKROOT=macosx` (memory workaround). Collect the 4 frameworks into
   `collection/ir/collected/` (`apianyware-macos-collect`; SDK-gated).
2. `apianyware-macos-analyze -- all` (resolve → annotate[merges committed LLM
   annotations] → enrich) → enriched IR for all 6 frameworks.
3. `generate --target gerbil` → emits `lib/{coregraphics,pdfkit,scenekit,webkit}/`
   + refreshes the shared generics. Spot-check key classes (CGContext, PDFView,
   SCNView, WKWebView) look sane.
4. Confirm the runtime + a representative new module compile under the bottle
   toolchain (don't rebuild all apps here — that's the per-app leaves).

## Done when

- `lib/coregraphics/`, `lib/pdfkit/`, `lib/scenekit/`, `lib/webkit/` populated
  with `.ss` modules; generics facade refreshed; emission golden suite (060) still
  green (or goldens updated intentionally).
- A spot-compile of one new module per framework succeeds under the bottle gxc.
- bundle-gerbil's framework-link casing table (compile.rs `framework_link_name`)
  covers the new dirs (pdfkit→PDFKit, scenekit→SceneKit, webkit→WebKit,
  coregraphics→CoreGraphics already present) — add any missing.

## Notes

If CoreGraphics (or any framework) turns out to need fresh LLM annotation, that is
the economically-constrained per-framework subagent step (memory
[[project_llm_annotation_constraint]]) — surface before running it. Threading
(080 model) matters for WebKit apps (060/070), not for generation itself.
