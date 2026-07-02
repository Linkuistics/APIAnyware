# racket-instrument-build-k107

**Kind:** work

## Goal

Instrument the **racket** scenekit-viewer impl to the k105 contracts and build it as a
launchable self-contained `.app`: `events.rkt` (lifecycle triad + the two `[scene]`
events), wiring in `scenekit-viewer.rkt` (startup before window construction;
dual-emitted launch line; `geometry-changed` in the `geometryChanged:` handler
post-state — after `setGeometry:` + §7.2 colour re-apply, carrying the folded
stored-colour rgb; `color-changed` on the `colorChanged:` success path post
store+apply; `applicationWillTerminate:` delegate → `shutdown reason=menu`),
`build.sh`, and the `#lang app-spec/impl` descriptor. Owns the **SceneKit corpus
step** the siblings inherit (the k98 twin).

## Context

- Contracts: `apps/macos/scenekit-viewer/docs/{logging-contract,observable-state}.md`
  (k105) — the conformance checklist is the work list. Env/paths:
  `SCENEKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/scenekit-viewer/{events.log,
  test-config.scm}`.
- Template: `targets/racket/app-implementations/macos/pdfkit-viewer/` (k98) —
  `events.rkt` (quoting helper carries over for `shape="…"`), the startup/shutdown/
  delegate wiring block, `build.sh` (bundle → rename → PlistBuddy id → re-sign →
  self-containment gate), `pdfkit-viewer-impl.rkt` descriptor shape.
- **Corpus (k98 twin, expected by the node brief):** SceneKit is absent from the local
  partial corpus (Foundation+AppKit+PDFKit) — `SDKROOT=macosx apianyware-collect --only
  SceneKit` once, then deps-together `apianyware-analyze --only Foundation,AppKit,SceneKit`,
  then `apianyware-generate --target racket` + adapter relink (`swift build --product
  APIAnywareRacket`, never `--target`). Goldens must not move.
- **rgb folding:** `r`/`g`/`b` = stored colour's device-RGB components ×255
  round-to-nearest, converted at emit time via `colorUsingColorSpace:` device-RGB
  (a §7.4-stored colour is already device-RGB; only the initial `systemRedColor`
  converts at emit — consumers never assume the initial values). Needs the nscolor
  component accessors (`redComponent` etc.) from the generated bindings.
- `shape` = the applied catalogue title (`Cube`/`Sphere`/`Torus`/`Cylinder`) ≡ the
  picker's selected-item title. Re-selecting the current item re-runs the handler and
  logs again (§6 unconditional — never count events).
- Silent no-ops (nil panel colour / failed device-RGB conversion) emit nothing; the
  racket stderr `colorChanged:` guard line stays on stderr. Instrumentation must not
  change visible behaviour.
- Names: `SceneKitViewer-racket.app` / `com.linkuistics.scenekit-viewer-racket`
  (bundler emits `SceneKit Viewer.app` from the spec H1; build.sh renames + re-ids).

## Done when

`events.rkt` verified in isolation against the contract matchers; the impl builds via
`build.sh` into `build/SceneKitViewer-racket.app` with `CFBundleIdentifier =
com.linkuistics.scenekit-viewer-racket` and passes the self-containment gate; descriptor
authored; `learnings.md` updated; committed. Live launch/interaction is the Tier-2
live-run leaf's bar ([[use_testanyware]] — no GUI launch host-side).

## Notes

The isolation verify replaces "CLI smoke of the event stream" for the host-side
session (k68/k89/k98 precedent); the Tier-2 leaf exercises the real launch + scene
events in the VM.
