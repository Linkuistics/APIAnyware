# 010-regenerate-build-bundle

**Kind:** work

## Goal
Regenerate the full chez pipeline against the final shape (self-contained
`APIAnywareChez`, post de-Common, post thread-safety) and produce buildable,
self-contained standalone `.app` bundles for **every** chez sample app — the
mechanical, CLI-verifiable half of node 040. (Visual VM-verification is the
sibling leaf `020`.)

## Context
- Framework libs under `generation/targets/chez/apianyware/<framework>/` are
  **gitignored** and currently absent on disk — only `runtime/` is tracked. They
  regenerate from the enriched IR via `emit-chez`. First action: confirm whether
  the enriched IR is present (memory `project_racket_enriched_ir_gitignored` —
  IR is large + gitignored); if absent, the regenerate step must run the upstream
  collect/analyse first. **Surface as a blocker if analysis must re-run** (LLM
  annotation is expensive — memory `project_llm_annotation_constraint`).
- The emitter did **not** change in this grove (design spec §6: dispatch /
  marshalling stay Scheme). So regeneration should be a clean re-emit, not an
  emitter cutover. What *did* change: the Swift dylib (020 de-Common, `aw_common_*`
  → `aw_chez_*`) and the runtime `.sls` (030 `__collect_safe` + guardian mutex).
- Build pipeline per app: `bundle-chez/src/standalone.rs::bundle_app`, driven by
  `cargo run --release --example bundle_app -p apianyware-macos-bundle-chez -- <script>`
  (knowledge/targets/chez.md "The build pipeline"). 7 apps: drawing-canvas,
  hello-window, mini-browser, note-editor, pdfkit-viewer, scenekit-viewer,
  ui-controls-gallery.
- `SDKROOT=macosx` workaround applies to collect/extract/digester steps.

## Done when
- `emit-chez` regenerates the framework `.sls` libs clean under `SDKROOT=macosx`.
- The self-contained `libAPIAnywareChez.dylib` builds (`swift build`); the runtime
  smoke suites (verify.ss, smoke-objc, smoke-types-cocoa, smoke-dispatch incl.
  the new background test) still pass.
- All 7 standalone `.app`s bundle successfully and each embeds the self-contained
  `libAPIAnywareChez.dylib` (no `APIAnywareCommon` residue; `otool -L` clean).
- CLI dev-run of each app reaches `[NSApp run]` (sanity only — **does not** satisfy
  the VM bar; that is leaf 020).

## Notes
- This leaf is the prerequisite artifact for 020: 020 uploads these `.app`s to the
  VM and drives them. Keep the build outputs in place for 020 to consume.
