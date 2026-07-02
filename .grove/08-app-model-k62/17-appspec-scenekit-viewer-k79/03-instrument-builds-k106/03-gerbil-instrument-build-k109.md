# gerbil-instrument-build-k109

**Kind:** work

## Goal

Instrument the **gerbil** scenekit-viewer impl to the k105 contracts and build it as
a launchable `.app` — the k107/k108 pattern realized the gerbil way (the pdfkit k100
/ gallery k91 precedent: inline emitter block; startup before the run loop; the
`applicationWillTerminate:` hook; dual-emitted launch line; the two `[scene]` events
post-state).

## Context

- Contracts: `apps/macos/scenekit-viewer/docs/{logging-contract,observable-state}.md`
  (k105) — the conformance checklist is the work list. Env/paths:
  `SCENEKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/scenekit-viewer/{events.log,
  test-config.scm}`.
- Templates: the racket/chez siblings
  (`targets/{racket,chez}/app-implementations/macos/scenekit-viewer/`, k107/k108 —
  the make-geometry+title single-source shape, the emit-time `current-color-rgb255`
  device-RGB ×255 fold, §7.4 keep-previous silent no-ops on nil panel colour /
  failed conversion) and the gerbil pdfkit-viewer
  (`targets/gerbil/app-implementations/macos/pdfkit-viewer/`, k100 — emitter block,
  delegate wiring, `build.sh`, descriptor).
- **Corpus is done** (k107): SceneKit collected + deps-together resolved. This child
  needs only its own `apianyware-generate --target gerbil` + adapter relink + bundle,
  **in that order** — SceneKit adds zero trampolines but grows the generated typed
  dispatch (k107), so relink (`swift build --product APIAnywareGerbil`, never
  `--target`) BEFORE bundling; verify with the `nm -gU` bundled-vs-fresh symbol diff
  where the bundle carries the dylib. Expect the gxc recompile — gcc-15 shim
  `/tmp/aw-gcc15-shim` if needed ([[gerbil_gcc15_drift]]).
- Never a bare `values` identity token in generated gerbil bindings
  ([[gerbil_values_coerce_shadow]]).
- build.sh prereq keys on the target's scenekit binding artifact (the k99 rule).
- Names: `SceneKitViewer-gerbil.app` / `com.linkuistics.scenekit-viewer-gerbil`.
- Silent no-ops emit nothing; stderr guards stay stderr; no visible-behaviour
  change (spec §12).

## Done when

Emitter verified in isolation against the contract matchers; the impl builds to
`build/SceneKitViewer-gerbil.app` with `CFBundleIdentifier =
com.linkuistics.scenekit-viewer-gerbil`; descriptor authored; `learnings.md`
updated; committed. Live launch is the Tier-2 live-run leaf's bar
([[use_testanyware]]).

## Notes

Grow the sbcl sibling on retirement (the lazy-children rule). The sbcl child owns
the two k104 seeds (bundle id + `CFBundleInfoDictionaryVersion`; the §7.4
stores-raw → keep-previous alignment).
