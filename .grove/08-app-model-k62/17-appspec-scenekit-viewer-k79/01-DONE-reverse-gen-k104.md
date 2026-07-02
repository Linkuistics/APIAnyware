# reverse-gen-k104

**Kind:** work

## Goal

Reverse-gen the projection-free, replication-grade **scenekit-viewer spec** from the
four VM-verified impls, per the AppSpec reverse-gen workflow
(`~/Development/AppSpec/capabilities/reverse-gen/{workflow,prompt}.md`): dispatch the
read-only subagent, validate its modeling notes (anchor order: app-kind contract >
impl behaviour > human prose), and write the accepted spec to
`apps/macos/scenekit-viewer/docs/spec.md` (replacing the precursor prose — the lowest
anchor). The commit is the propose→review→accept boundary (ADR-0050/0052).

## Context

- Inputs: impls at `targets/{racket,chez,gerbil,sbcl}/app-implementations/macos/
  scenekit-viewer/` (sbcl carries extra build/run/dump scripts + a README); app-kind
  contract `platforms/macos/app-kinds/gui-app/kind.apiw`; precursor prose
  `apps/macos/scenekit-viewer/docs/spec.md` (the only app-level doc — no
  learnings/test-strategy precursors; per-impl `learnings.md` are impl-side);
  portfolio catalogue `apps/macos/docs/_index.md` (complexity = portfolio rank);
  pattern-kind registry `semantic/pattern-kinds/`; closed verb set
  `~/Development/AppSpec/app-spec/main.rkt`.
- Templates: `apps/macos/hello-window/docs/spec.md` (the k64 exemplar — H1 = display
  name for the bundlers; provenance line; §1 structural facts; behavioural-exemplar
  final § mapped to the closed scenario-verb set) and
  `apps/macos/pdfkit-viewer/docs/spec.md` (the k95 precedent — richest recent shape,
  document/panel-drive concerns).
- Watch for stale-prose risks (the k86/k95 lesson: precursor claims that match *no*
  impl get cut) — verify every geometry-swap / colour-panel / camera-control /
  animation claim against what the impls actually realize.
- **App-specific:** SCNView contents are not AX-observable — the exemplar must lean
  on log lines + AX structure (popup value, SCNView presence), and per-behaviour
  in-VM verifiability is itself spec-quality output. Note explicitly how each impl
  builds its scene (geometry factories, lighting, camera, spin animation) and how
  the colour panel is opened/observed — that grounds the later suite child.

## Done when

`apps/macos/scenekit-viewer/docs/spec.md` is the validated reverse-gen spec (first H1
bundler-safe — the display name), committed with the modeling notes reviewed;
unsupported claims grounded or cut, gaps honestly marked `(to confirm in-VM)`.

## Notes

The behavioural-exemplar section is the forward-gen input for the later suite child —
it should enumerate geometry selection (popup, all four shapes), colour change
(NSColorPanel open + apply), camera-control (orbit/zoom), and the spin animation as
observable assertions where in-VM-verifiable, not just launch/quit
([[sample_apps_perfect]]). Where a 3D behaviour has no observable witness, that gap
is a finding, not a failure.

## Status — done 2026-07-02 (validated & accepted)

Subagent dispatched per the AppSpec workflow; modeling notes worked; load-bearing
witnesses mechanically re-verified against all four sources (window 640×480 / min
480×360 / viewport 640×432 / toolbar 12,440,616,32 / spacing 8 / orientation
horizontal / MinYMargin pin; picker items Cube/Sphere/Torus/Cylinder ×4 +
pullsDown false; geometry catalogue params + else→cube fallback ×4; spin
0/1.5/0/4.0 ×4; systemRed initial + darkGray background + setContinuous +
deviceRGB normalization ×4; delegate/shouldTerminate absence ×4; launch-line
`SceneKit Viewer` prefix ×4; title set ×4). Key acceptances:

- **In-VM verifiability finding (constrains the suite child — the brief predicted
  it):** rendered-scene content (shape identity, colour, spin, orbit/zoom) is
  pixel-level — the closed verb set has no screenshot-diff and **no mouse-drag verb**
  (verified against `app-spec/main.rkt`), so live-recolour + colour-persists-across-
  swap + animation assertions stay spec prose; the runnable surface is AX/OCR
  (title, popup value, `Colo` button, `Colors` panel presence), the launch log line,
  and quit. The contract-instrumentation child should consider log events for
  geometry-swap/colour-change to make the key behaviours log-observable.
- **Quit-title witness asymmetry resolved at validation** (the k95 precedent):
  verified the shared `install-standard-app-menu!` helper bodies directly (racket
  `app-menu.rkt` L186–188, chez `cocoa.sls`, gerbil `cocoa.ss`) — all build
  `"Quit " + name` / `terminate:` / key `q`; sbcl witnesses inline. §8 confirmed.
- **Precursor over-claims cut:** the raw-`tell` SCNActionable/SCNSceneRenderer
  "protocol gap" (closed by gerbil leaf 120; both now generated bindings — impl
  behaviour wins); "lighting via material's omnidirectional ambient" (no witness;
  lighting is `setAutoenablesDefaultLighting:`); the device-RGB
  component-access rationale (no impl accesses components — racket L195 says so
  explicitly; the witnessed rationale is SceneKit-sampling).
- **Conversion-failure divergence accepted as "not specified":** racket/chez/gerbil
  keep-previous (`when rgb` / `unless zero?`), sbcl stores unconverted
  (`(or rgb raw)`). §7.4 made self-contained on acceptance (no modeling-notes
  reference — the k86 lesson). Alignment decision seeded to the instrument child
  (majority keep-previous; sbcl the outlier).
- **Handoff to instrument-builds:** sbcl `build.sh` Info.plist lacks the
  kind-required `CFBundleInfoDictionaryVersion` (+ check `LSMinimumSystemVersion`)
  — align when rebuilding.
- **Common-mode platform assumptions carried with in-VM markers** (fresh
  firstMaterial per geometry; `setGeometry:` does not cancel node actions;
  continuous panel delivery on drag; popup first-item default) — corroborated by
  impl-side VM learnings, not dropped.
- **Classifications confirmed:** complexity 6/7 against the catalogue row;
  `target-action` + `parent-child` against the registry; descriptive remainder
  matches the accepted hello-window/pdfkit style. Notably not claimed: `observer`
  (no notifications), `delegate` (no `setDelegate:`), `factory-cluster`.
- **Exemplar gaps recorded:** viewport-render, animation-live, live-recolour,
  colour-persistence, panel-dismiss-no-op have no runnable verb — spec prose only;
  close-button behaviour is an in-VM gap the suite records as observed.
