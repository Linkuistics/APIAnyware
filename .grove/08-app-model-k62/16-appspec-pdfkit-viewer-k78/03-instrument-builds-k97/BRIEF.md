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
3. `gerbil-instrument-build-k100` — gallery k91 pattern; gcc-15 shim if the binding
   rebuilds; never a bare `values` in generated bindings.
4. *(planned)* sbcl — gallery k92 pattern (`events.lisp` exists as template; dump.lisp
   build).

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
