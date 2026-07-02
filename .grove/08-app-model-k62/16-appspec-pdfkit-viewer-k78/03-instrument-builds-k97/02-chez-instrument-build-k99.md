# chez-instrument-build-k99

**Kind:** work

## Goal

Instrument the **chez** pdfkit-viewer impl to the k96 contracts and build it as a
launchable `.app`: the inline emitter in `pdfkit-viewer.sls` (gallery k90 pattern —
no separate events module; `pv-`-prefixed emit procedures), wiring (startup at top
level **before** `(main)` — R6RS body semantics put main's constructor defines ahead
of its first expression; dual-emitted launch line; `opened` in the `openDocument:`
success path post-refresh; `page-changed` in `pageChanged:` post-refresh;
`applicationWillTerminate:` delegate → `shutdown reason=menu`), `build.sh`, and the
`#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/pdfkit-viewer/docs/{logging-contract,observable-state}.md`
  (k96). Env/paths: `PDFKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/pdfkit-viewer/{events.log,test-config.scm}`.
- Templates: `targets/chez/app-implementations/macos/ui-controls-gallery/` (k90) —
  the inline `ucg-*` emitter block (init/quote/emit-line + per-event procs), the
  delegate table entry `applicationWillTerminate:`, `build.sh`, descriptor.
  The racket sibling (k98, `01-DONE-racket-instrument-build-k98.md`) settled the
  app-level shape: **`refresh-ui!` returns the applied state** (`#f` empty /
  `(page . total)` loaded) so both `[document]` events mirror the §7.2 label by
  construction; `opened` fires only on the open success path (basename from the
  URL; nil-guarded); silent no-ops emit nothing.
- Emission points in `pdfkit-viewer.sls`: the `openDocument:` handler (delegate
  table, ~L114) and the `pageChanged:` observer (~L145); `refresh-ui!` at ~L86 is
  a define inside `(define-entry-point (main))`.
- **PDFKit corpus is now local** (k98 — node brief): no re-collection; run
  `apianyware-generate --target chez` + relink the adapter dylib
  (`swift build --product APIAnywareChez`) before building.
- Names: `PDFKitViewer-chez.app` / `com.linkuistics.pdfkit-viewer-chez`.

## Done when

Emitter verified in isolation against the contract matchers (chez `scheme` script,
k90 precedent); the impl builds via `build.sh` into `build/PDFKitViewer-chez.app`
with `CFBundleIdentifier = com.linkuistics.pdfkit-viewer-chez`; descriptor authored;
`learnings.md` updated; committed. Live launch is the Tier-2 live-run leaf's bar
([[use_testanyware]]).

## Notes

Chez idiom over R6RS portability where they differ ([[chez_target_idiomatic]]).
Instrumentation must not change visible behaviour; cancel / nil URL / failed
`initWithURL:` stay silent.
