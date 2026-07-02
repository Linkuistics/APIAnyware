# instrument-builds-k97 — brief

**Kind:** node (decomposed 2026-07-02 — one instrument+build child per impl, the
k88 split; children materialized lazily, grow the next as each retires)

## Children

1. `racket-instrument-build-k98` ✅ — the reference pattern (events.rkt + wiring +
   self-contained build.sh + descriptor; gallery k89 template). App-level shape the
   siblings mirror: `refresh-ui!` returns the applied state so the `[document]`
   events ≡ the §7.2 label by construction; launch line renamed `emit-launch-line`
   (this app has a real `opened` event).
2. `chez-instrument-build-k99` ✅ — gallery k90 pattern (emitter inline in the `.sls`;
   startup at top level before `(main)`; refresh-ui! returns applied state, the k98
   shape). Sibling handoff: the chez bindings needed regeneration + a
   `swift build --product APIAnywareChez` relink before bundling (the local binding
   tree predated the k98 PDFKit collection) — gerbil/sbcl should expect the twin;
   build.sh prereq now keys on the target's pdfkit binding artifact, not appkit.
3. `gerbil-instrument-build-k100` ✅ — gallery k91 pattern (emitter inline in the
   `.ss`; startup top-level before `(main)`; refresh-ui! returns applied state, the
   k98 shape). The k99 twin held: bindings regenerated (`--target gerbil`, PDFKit
   trampolines → 170 entries) + `swift build --product APIAnywareGerbil` relink;
   build.sh prereq keys on `pdfkit/pdfview.ss`. No gcc-15 shim needed (real gcc-15
   on PATH); no bare-`values` issue surfaced in the regenerated bindings.
4. `sbcl-instrument-build-k101` ✅ — gallery k92 pattern (separate `events.lisp`,
   `pv-events`, verified in isolation under `sbcl --script`; launch emitter named
   `emit-launch-line`, the k98 rename). The k99/k100 twin held (local tree had no
   PDFKit; regen + `--product APIAnywareSbcl` relink; prereq keys on
   `generated/pdfkit/pdfview.lisp`) — with one refinement: PDFKit adds ZERO
   Swift-native residual (pure ObjC; Trampolines.swift stays 170 entries — the
   relink is lockstep hygiene, not growth). Hand-rolled /tmp-staged wrap retired
   for the production bundler (ADR-0041). Last child: node complete — outcomes
   promoted to the k78 brief ("instrument-builds outcomes"); the k78
   forward-gen-suite stage grown as `forward-gen-suite-k102`.

## Goal

Instrument all four pdfkit-viewer impls
(`targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/pdfkit-viewer/`) to the
k96 conformance contracts and build each to a `.app` — the hello-window k68–k71 /
ui-controls-gallery k88 stage.

## Context

- The contracts to implement verbatim:
  `apps/macos/pdfkit-viewer/docs/{logging-contract,observable-state}.md`. Per-impl
  checklist at the end of the logging contract. Events: `[lifecycle] startup`, the
  bare launch line beginning `PDFKit Viewer`, `[document] opened file="…" pages=N`
  (open success path only), `[document] page-changed page=n pages=N` (notification
  observer), `[lifecycle] shutdown reason=<r>` — all post-state (k77 rule).
- **Emission points already exist in every impl** (k96 verified racket): the
  `openDocument:` action handler (emit `opened` after store + `setDocument:` +
  refresh), the `pageChanged:` notification observer (emit `page-changed` after the
  refresh applies label + flags), and the §7.2 refresh rule. The
  `applicationWillTerminate:` hook is the instrumentation's addition, exactly as the
  hello-window/ui-controls-gallery instrument stages did in all four impls.
- Reference emitters: `targets/<t>/app-implementations/macos/{hello-window,
  ui-controls-gallery}/events.*` (the per-impl worked templates — racket
  `events.rkt`, and the chez/gerbil/sbcl counterparts).
- `file` = the opened URL's **last path component** (panel canonicalizes `/tmp` →
  `/private/tmp`); `page` is 1-based ≡ the label's *n*.
- Build notes: `swift build --product` not `--target` where a dylib relink is
  involved; gerbil needs the gcc-15 shim (`/tmp/aw-gcc15-shim`); bundle ids
  `com.linkuistics.pdfkit-viewer-<impl>`.
- **PDFKit corpus (k98 finding):** PDFKit was absent from the local partial corpus
  (Foundation+AppKit only) — k98 collected it (`SDKROOT=macosx apianyware-collect
  --only PDFKit`) and resolved deps-together (`apianyware-analyze --only
  Foundation,AppKit,PDFKit`); `extracted.json`/`resolved.json` are now local, goldens
  unmoved. The chez/gerbil/sbcl children still need their **own** target's
  `apianyware-generate --target <t>` + adapter dylib relink (`swift build --product
  APIAnyware<T>`) — the trampoline set grows with the third family — but **not**
  re-collection/re-resolution.

## Done when

All four impls emit the contract events (CLI smoke of the event stream where
observable) and build to `.app` bundles with the right `CFBundleIdentifier`. Live-VM
verification is **not** this leaf's bar — it belongs to the live-run stage
([[vm_verify_every_app]] is closed by the node's final child).

## Notes

Instrumentation must not change visible behaviour (no new UI, no error dialogs —
spec §12). Silent no-ops (cancel / nil URL / failed `initWithURL:`) emit nothing.
