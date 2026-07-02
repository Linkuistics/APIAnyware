# racket-instrument-build-k98

**Kind:** work

## Goal

Instrument the **racket** pdfkit-viewer impl to the k96 contracts and build it as a
launchable self-contained `.app`: `events.rkt` (lifecycle triad + the two `[document]`
events), wiring in `pdfkit-viewer.rkt` (startup before window construction; dual-emitted
launch line; `opened` on the open handler's success path post-state; `page-changed` in
the `pageChanged:` observer post-refresh; `applicationWillTerminate:` delegate →
`shutdown reason=menu`), `build.sh`, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/pdfkit-viewer/docs/{logging-contract,observable-state}.md`
  (k96) — the conformance checklist is the work list. Env/paths:
  `PDFKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/pdfkit-viewer/{events.log,
  test-config.scm}`.
- Template: `targets/racket/app-implementations/macos/ui-controls-gallery/` (k89) —
  `events.rkt` (quoting helper carries over for `file="…"`), the startup/shutdown/
  delegate wiring block, `build.sh` (bundle → rename → PlistBuddy id → re-sign →
  self-containment gate), `ui-controls-gallery-impl.rkt` descriptor.
- Racket-specific emission points (k96 verified): `openDocument:` success path — emit
  `opened` after `set! current-document` + `pdfview-set-document!` + `refresh-ui!`;
  the `pageChanged:` observer — emit `page-changed` after `refresh-ui!`. `file` = URL
  basename (`nsurl` → path → `lastPathComponent` or racket-side basename); `pages` =
  `pdfdocument-page-count`; `page` = the refresh rule's `index+1` (nil-current-page
  fallback ⇒ `page=1`) — factor the label computation so event and label cannot
  diverge (§7.2 single source of truth).
- Names: `PDFKitViewer-racket.app` / `com.linkuistics.pdfkit-viewer-racket` (bundler
  emits `PDFKit Viewer.app` from the spec H1; build.sh renames + re-ids).
- Silent no-ops (cancel / nil URL / failed `initWithURL:`) emit nothing.
  Instrumentation must not change visible behaviour.

## Done when

`events.rkt` verified in isolation against the contract matchers; the impl builds via
`build.sh` into `build/PDFKitViewer-racket.app` with `CFBundleIdentifier =
com.linkuistics.pdfkit-viewer-racket` and passes the self-containment gate; descriptor
authored; `learnings.md` updated; committed. Live launch/interaction is the Tier-2
live-run leaf's bar ([[use_testanyware]] — no GUI launch host-side).

## Notes

The isolation verify replaces "CLI smoke of the event stream" for the host-side
session (k68/k89 precedent); the Tier-2 leaf exercises the real launch + document
events in the VM.
