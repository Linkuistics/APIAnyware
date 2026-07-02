# forward-gen-suite-k111

**Kind:** work

## Goal

Forward-gen the scenekit-viewer `#lang app-spec` scenario suite + `run-values.rkt`
from the k104 spec + k105 contracts, via the AppSpec forward-gen workflow
(`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) — the pdfkit k102 stage.
Suite homes at `apps/macos/scenekit-viewer/scenarios/`. No fixtures (k104: the app
ships no document).

## Context

- **Template:** the pdfkit-viewer suite (`apps/macos/pdfkit-viewer/scenarios/` +
  `run-values.rkt`) — the k102 worked exemplar (hard vs `recording:` cluster split,
  `;; spec:` per-assertion tracing, coverage-or-gap rule
  `AppSpec/capabilities/forward-gen/validation.md` L1b, two-run consensus for a suite
  gating four impls, presentation-settled `wait-for-log` probe before coordinate
  clicks).
- **Inputs:** `apps/macos/scenekit-viewer/docs/{spec,logging-contract,observable-state}.md`.
  The observable-state **§13 assertion → observation path map is the suite's skeleton**
  — every §13 line verb-backed or a documented gap; this app's headline gap class is
  rendered-scene content (shape identity, colour, spin, orbit — pixel-level, no
  pixel-diff/drag verb; the `[scene]` events are the state-level proxies, appearance is
  live-run's by-eye bar).
- **All four impls are instrumented + built** (k107–k110): the suite can assume the
  contract events (`[lifecycle] startup`, bare launch line beginning `SceneKit Viewer`,
  `[scene] geometry-changed shape="…" r=… g=… b=…` / `color-changed r=… g=… b=…`,
  `shutdown reason=menu`) and the descriptors at
  `targets/<t>/app-implementations/macos/scenekit-viewer/scenekit-viewer-impl.rkt`.
  §7.4 is aligned everywhere (stored colour always device-RGB); the sbcl launch-line
  wording differs by design — match the prefix only.
- **Contract rules the scenarios must respect:** never count `[scene]` events, never
  assume ordering (continuous panel — a drag emits many `color-changed`; re-selecting
  the current picker item logs again); match the specific driven-to line; never assume
  the initial colour's folded values (OS/appearance-dependent — shape-only matching
  until a colour is driven); silent no-ops emit nothing — absence is never asserted;
  the key behaviour (colour persists across a swap) is the single-line
  `geometry-changed shape="…" r=… g=… b=…` assertion after driving a known colour.
- **To-confirm-in-VM rows stay soft:** popup value-fold to AXTitle, open-menu AX
  snapshot shape, SCNView AX exposure (provisional row — the k96 pattern), `Colors`
  panel title/snapshot scope, single-click delivery of the continuous panel action
  (no drag verb — the suite degrades to shape-level matchers + recorded actuals if
  click delivery is unreliable). Firm these at live-run before hard-asserting.
- **Driver guidance (spec §13):** click at AX-reported coordinates; read popup item
  positions from the OPEN menu's AX snapshot (a pop-up re-aligns to the current
  selection); after the panel takes key, the first click on the app window only
  re-activates it — the targeted control fires on the second click.

## Done when

The suite + `run-values.rkt` are authored and validated per the forward-gen workflow's
checks (scenario↔spec correlation review; coverage-or-gap map complete); committed.
Running the suite live is the Tier-2 live-run leaf's bar (grow it on retire — the k79
stage 5, closing the node's Done-when).

## Notes

Window geometry is 640×480 content across all four impls but toolbar layouts may
diverge — apply the k77 per-impl geometry practice: measure from
`agent snapshot --mode layout`, two-launch determinism diff before binding values,
per-impl `run-values-<impl>.rkt` only where layouts diverge.
