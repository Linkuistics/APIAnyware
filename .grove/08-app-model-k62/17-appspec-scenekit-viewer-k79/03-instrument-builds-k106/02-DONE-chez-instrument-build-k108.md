# chez-instrument-build-k108

**Kind:** work

## Goal

Instrument the **chez** scenekit-viewer impl to the k105 contracts and build it as a
launchable `.app` — the k107 racket reference pattern realized the chez way (the
pdfkit k99 / gallery k90 precedent: emitter inline in the `.sls`; startup at top
level before `(main)`; the `applicationWillTerminate:` hook; dual-emitted launch
line; the two `[scene]` events post-state).

## Context

- Contracts: `apps/macos/scenekit-viewer/docs/{logging-contract,observable-state}.md`
  (k105) — the conformance checklist is the work list. Env/paths:
  `SCENEKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/scenekit-viewer/{events.log,
  test-config.scm}`.
- Templates: the racket sibling
  (`targets/racket/app-implementations/macos/scenekit-viewer/`, k107 — the
  make-geometry+title single-source shape, the emit-time `current-color-rgb255`
  device-RGB fold, the tightened §7.4 nil checks) and the chez pdfkit-viewer
  (`targets/chez/app-implementations/macos/pdfkit-viewer/`, k99 — the inline
  emitter + build.sh shape).
- **Corpus is done** (k107): SceneKit collected + deps-together resolved
  (`--only Foundation,AppKit,SceneKit`). This child needs only its own
  `apianyware-generate --target chez` + adapter relink + bundle, **in that order**
  — the k107 finding: SceneKit adds zero trampolines but GROWS the generated
  typed dispatch (new ABI shapes, e.g. three-float `rotateByX:y:z:duration:`),
  so the relink (`swift build --product APIAnywareChez`, never `--target`) is
  required BEFORE bundling; build.sh's dylib prereq checks existence only.
  Verify with the `nm -gU` bundled-vs-fresh symbol diff where the bundle carries
  the dylib.
- build.sh prereq keys on the target's scenekit binding artifact (the k99 rule).
- Names: `SceneKitViewer-chez.app` / `com.linkuistics.scenekit-viewer-chez`.
- Silent no-ops emit nothing; stderr guards stay stderr; no visible-behaviour
  change (spec §12).

## Done when

Emitter verified in isolation against the contract matchers; the impl builds to
`build/SceneKitViewer-chez.app` with `CFBundleIdentifier =
com.linkuistics.scenekit-viewer-chez`; descriptor authored; `learnings.md` updated;
committed. Live launch is the Tier-2 live-run leaf's bar ([[use_testanyware]]).

## Notes

Grow the gerbil sibling on retirement (the lazy-children rule). The sbcl child
owns the two k104 seeds (bundle id + `CFBundleInfoDictionaryVersion`; the §7.4
stores-raw → keep-previous alignment).
