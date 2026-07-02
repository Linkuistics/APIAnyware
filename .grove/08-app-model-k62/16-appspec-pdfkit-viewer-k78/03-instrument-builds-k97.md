# instrument-builds-k97

**Kind:** work

## Goal

Instrument all four pdfkit-viewer impls
(`targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/pdfkit-viewer/`) to the
k96 conformance contracts and build each to a `.app` — the hello-window k68–k71 /
ui-controls-gallery k88 stage. **Likely a node** (one child per impl, as k88 was) —
decompose on entry if the four impls don't fit one session.

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

## Done when

All four impls emit the contract events (CLI smoke of the event stream where
observable) and build to `.app` bundles with the right `CFBundleIdentifier`. Live-VM
verification is **not** this leaf's bar — it belongs to the live-run stage
([[vm_verify_every_app]] is closed by the node's final child).

## Notes

Instrumentation must not change visible behaviour (no new UI, no error dialogs —
spec §12). Silent no-ops (cancel / nil URL / failed `initWithURL:`) emit nothing.
