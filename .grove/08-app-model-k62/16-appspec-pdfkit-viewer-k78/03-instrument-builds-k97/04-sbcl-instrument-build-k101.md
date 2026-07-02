# sbcl-instrument-build-k101

**Kind:** work

## Goal

Instrument the **sbcl** pdfkit-viewer impl to the k96 contracts and build it as a
launchable `.app`: the emitter (gallery k92 pattern — sbcl carries a separate
`events.lisp`, loaded by `dump.lisp`, unlike the inline scheme targets), wiring
(startup before the run loop; dual-emitted launch line; `opened` in the
`openDocument:` success path post-refresh; `page-changed` in `pageChanged:`
post-refresh; `applicationWillTerminate:` delegate → `shutdown reason=menu`),
the `build.sh`/`dump.lisp` adaptation, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/pdfkit-viewer/docs/{logging-contract,observable-state}.md`
  (k96). Env/paths: `PDFKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/pdfkit-viewer/{events.log,test-config.scm}`.
- Templates: `targets/sbcl/app-implementations/macos/ui-controls-gallery/` (k92) —
  `events.lisp` emitter, delegate wiring, `build.sh` + `dump.lisp`, descriptor.
  The pdfkit-viewer dir already has its own pre-instrumentation
  `build.sh`/`dump.lisp`/`run.lisp` (the earlier port) — adapt, don't clone
  blindly. App-level shape settled by the k98/k99/k100 siblings:
  **`refresh-ui!` returns the applied state** (`nil` empty / `(page . total)`
  loaded) so both `[document]` events mirror the §7.2 label by construction;
  `opened` fires only on the open success path (basename from the URL,
  nil-guarded); silent no-ops emit nothing.
- **PDFKit corpus is local** (k98): no re-collection; the sbcl binding tree
  likely predates the PDFKit collection (the k99/k100 twin) — run
  `apianyware-generate --target sbcl` + `swift build --product APIAnywareSbcl`
  (`--product`, not `--target`) as the build requires; key the build prereq on a
  pdfkit binding artifact, not an appkit one. Vendored libzstd is already
  handled (`sbcl-vendor-libzstd-k75`).
- Names: `PDFKitViewer-sbcl.app` / `com.linkuistics.pdfkit-viewer-sbcl`.

## Done when

Emitter verified in isolation against the contract matchers (k91/k100 precedent —
sbcl's `events.lisp` can be driven under plain `sbcl --script`); the impl builds
via `build.sh` into `build/PDFKitViewer-sbcl.app` with
`CFBundleIdentifier = com.linkuistics.pdfkit-viewer-sbcl`; descriptor authored;
`learnings.md` updated; committed. Live launch is the Tier-2 live-run leaf's bar
([[use_testanyware]]). Retiring this leaf empties the k97 node — confirm the
node-done cascade with the user (or grow the forward-gen-suite sibling at the k78
level first, per the k78 stage list).

## Notes

Instrumentation must not change visible behaviour; cancel / nil URL / failed
`initWithURL:` stay silent.
