# gerbil-instrument-build-k100

**Kind:** work

## Goal

Instrument the **gerbil** pdfkit-viewer impl to the k96 contracts and build it as a
launchable `.app`: the inline emitter (gallery k91 pattern), wiring (startup before
the run loop; dual-emitted launch line; `opened` in the `openDocument:` success path
post-refresh; `page-changed` in `pageChanged:` post-refresh;
`applicationWillTerminate:` delegate → `shutdown reason=menu`), `build.sh`, and the
`#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/pdfkit-viewer/docs/{logging-contract,observable-state}.md`
  (k96). Env/paths: `PDFKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/pdfkit-viewer/{events.log,test-config.scm}`.
- Templates: `targets/gerbil/app-implementations/macos/ui-controls-gallery/` (k91) —
  emitter block, delegate wiring, `build.sh`, descriptor. App-level shape settled by
  the racket/chez siblings (k98/k99): **`refresh-ui!` returns the applied state**
  (`#f` empty / `(page . total)` loaded) so both `[document]` events mirror the §7.2
  label by construction; `opened` fires only on the open success path (basename from
  the URL, nil-guarded); silent no-ops emit nothing.
- **PDFKit corpus is local** (k98 — node brief): no re-collection; run
  `apianyware-generate --target gerbil` + rebuild the gerbil binding/adapter as its
  build requires. The chez sibling (k99) found the regenerated bindings + a
  `swift build --product APIAnyware<T>` relink were needed before bundling — expect
  the gerbil twin (gcc-15 shim `/tmp/aw-gcc15-shim` if gxc recompiles,
  [[gerbil_gcc15_drift]]).
- Never a bare `values` identity token in generated gerbil bindings
  ([[gerbil_values_coerce_shadow]]).
- Names: `PDFKitViewer-gerbil.app` / `com.linkuistics.pdfkit-viewer-gerbil`.

## Done when

Emitter verified in isolation against the contract matchers (k91 precedent); the
impl builds via `build.sh` into `build/PDFKitViewer-gerbil.app` with
`CFBundleIdentifier = com.linkuistics.pdfkit-viewer-gerbil`; descriptor authored;
`learnings.md` updated; committed. Live launch is the Tier-2 live-run leaf's bar
([[use_testanyware]]).

## Notes

Instrumentation must not change visible behaviour; cancel / nil URL / failed
`initWithURL:` stay silent.
