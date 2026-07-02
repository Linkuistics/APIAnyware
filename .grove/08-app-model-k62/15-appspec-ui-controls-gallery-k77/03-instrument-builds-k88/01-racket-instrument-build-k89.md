# racket-instrument-build-k89

**Kind:** work

## Goal

Instrument the **racket** ui-controls-gallery impl to the k87 contracts and rebuild it as a
launchable self-contained `.app`: `events.rkt` (lifecycle + the four `[controls]` events),
wiring in `ui-controls-gallery.rkt` (startup/launch/shutdown + attach emits in the existing
`selectRadio:`/`sliderChanged:`/`stepperChanged:` handlers + new checkbox target-action),
`build.sh`, and the `#lang app-spec/impl` descriptor.

## Context

- Contracts: `apps/macos/ui-controls-gallery/docs/{logging-contract,observable-state}.md`
  (k87) — the conformance checklist is the work list. Env/paths:
  `UI_CONTROLS_GALLERY_{EVENTS_LOG,TEST_CONFIG}` →
  `/tmp/ui-controls-gallery/{events.log,test-config.scm}`.
- Template: `targets/racket/app-implementations/macos/hello-window/` (k28/k68 + the k76
  self-contained bundle) — `events.rkt`, `build.sh` (bundle → rename → PlistBuddy id →
  re-sign → self-containment gate), `hello-window-impl.rkt`.
- Racket-specific deltas: three handlers already exist (attach emits); checkbox has **no**
  action (add one); the impl has a third radio `Option C` (the contract tolerates it —
  emit its title the same way). `radio-selected` carries a **quoted string** value — the
  hello-window emitter had no string values, so add the contract's quoting
  (`\\`/`\"`/newline escaped). Title read: `nsbutton-title` + `nsstring-utf8-string`.
- Names: `UIControlsGallery-racket.app` / `com.linkuistics.ui-controls-gallery-racket`
  (hello-window convention; bundler emits `UI Controls Gallery.app` from the spec H1,
  build.sh renames + re-ids).
- Instrumentation must not change visible behaviour; never log text-field/secure-field
  contents.

## Done when

`events.rkt` verified in isolation against the contract matchers (incl. the four
`[controls]` matchers); the impl module builds via `build.sh` into
`build/UIControlsGallery-racket.app` with `CFBundleIdentifier =
com.linkuistics.ui-controls-gallery-racket` and passes the self-containment gate;
descriptor authored; `learnings.md` updated; committed. Live launch/interaction is the
Tier-2 live-run leaf's bar (hello-window precedent: host-side, no GUI launch —
[[use_testanyware]]).

## Notes

The isolation verify replaces the node brief's "direct CLI launch" phrasing for the
host-side session (k68 precedent); the Tier-2 leaf exercises the real launch + control
events in the VM.
