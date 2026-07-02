# sbcl-instrument-build-k110

**Kind:** work

## Goal

Instrument the **sbcl** scenekit-viewer impl to the k105 contracts and build it as
a launchable `.app` — the last of the four instrument+build children (k107/k108/k109
precedents realized the CL way: the pdfkit k101 / gallery k92 pattern — emitter
block, `applicationWillTerminate:` hook, dual-emitted launch line, the two `[scene]`
events post-state). Closes the `instrument-builds-k106` node.

## Context

- Contracts: `apps/macos/scenekit-viewer/docs/{logging-contract,observable-state}.md`
  (k105) — the conformance checklist is the work list. Env/paths:
  `SCENEKIT_VIEWER_{EVENTS_LOG,TEST_CONFIG}` → `/tmp/scenekit-viewer/{events.log,
  test-config.scm}`.
- **This child owns the k104 seeds** (the alignments seeded to the owning impl):
  - `build.sh` bundle id must become `com.linkuistics.scenekit-viewer-sbcl` (today
    unsuffixed `com.linkuistics.scenekit-viewer`) and Info.plist lacks the
    kind-required `CFBundleInfoDictionaryVersion` — both align here.
  - **§7.4 conversion-failure divergence: align stores-raw → keep-previous** (the
    contract's stored-colour-is-always-device-RGB invariant; majority behaviour).
    Note the sbcl launch line differs by design: `SceneKit Viewer opened. Quit with
    Cmd-Q.` — conforms (prefix match), keep it.
- Templates: the three siblings
  (`targets/{racket,chez,gerbil}/app-implementations/macos/scenekit-viewer/`,
  k107/k108/k109 — the make-geometry+title single-source shape (event ≡ applied
  state from one cond), the emit-time `current-color-rgb255` device-RGB ×255 fold,
  §7.4 silent no-ops) and the sbcl pdfkit-viewer
  (`targets/sbcl/app-implementations/macos/pdfkit-viewer/`, k101 — emitter,
  delegate wiring, `build.sh` + dump.lisp, descriptor).
- **Corpus is done** (k107) and SceneKit adds zero trampolines, but the sbcl child
  still runs its own `apianyware-generate --target sbcl` + adapter relink
  (`swift build --product APIAnywareSbcl`, never `--target`) **before** bundling —
  and note sbcl's dylib is the *sole native unit* (ADR-0038), so check
  `Generated/*.swift` currency via git status after generate (the k109 shortcut:
  a git-clean regenerated source proves the existing dylib current).
- Expect the §6d full-corpus-count tests to stay red on the partial local corpus
  ([[sbcl_6d_test_stale]] — not a regression; don't edit the numbers).
- Names: `SceneKitViewer-sbcl.app` / `com.linkuistics.scenekit-viewer-sbcl`.
- Silent no-ops emit nothing; stderr guards stay stderr; no visible-behaviour
  change (spec §12).

## Done when

Emitter verified in isolation against the contract matchers; §7.4 aligned to
keep-previous; the impl builds to `build/SceneKitViewer-sbcl.app` with
`CFBundleIdentifier = com.linkuistics.scenekit-viewer-sbcl` and a
`CFBundleInfoDictionaryVersion` in Info.plist; descriptor authored; `learnings.md`
updated; committed. Live launch is the Tier-2 live-run leaf's bar
([[use_testanyware]]).

## Notes

Last child of `instrument-builds-k106` — on retirement the node has no live leaf:
ask the user before treating it as done, then grow the forward-gen-suite stage
under `appspec-scenekit-viewer-k79` (the parent brief's stage 4).
