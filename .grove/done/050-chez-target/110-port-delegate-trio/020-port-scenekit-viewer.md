# 020-port-scenekit-viewer

**Kind:** work

## Goal
Port `scenekit-viewer` from racket to chez. End state: a
`generation/targets/chez/apps/scenekit-viewer/scenekit-viewer.sls`
that bundles via `bundle-chez`, launches in the VM (via leaf `040`'s
TestAnyware run), and looks indistinguishable from the racket bar.

This is the first chez app that pulls in **SceneKit**. The runtime
piece exercised is a **single sync delegate**, simpler shape than
ui-controls-gallery's pair of target-actions.

## Context
- Racket source: `generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt`
  (219 LOC).
- Knowledge spec: `knowledge/apps/scenekit-viewer/spec.md`.
- SceneKit is in the staged chez tree as `apianyware/scenekit.sls`
  and `apianyware/scenekit/*.sls`. Verify before porting; if any
  per-class library the racket source uses is missing, that's an
  emitter gap and the leaf splits.
- Chez delegate API: see node BRIEF.

## Done when
- `apps/scenekit-viewer/scenekit-viewer.sls` exists and is
  idiomatic Chez (no `tell`, no `_cprocedure`, no `define-cstruct`,
  geometry via `make-nsrect`/`make-nssize`, fallible methods
  via `(values result error)`).
- Single delegate uses chez list-of-specs shape; held in a top-level
  variable that outlives the owner.
- App bundles via `bundle_app -- scenekit-viewer`. Precompile pass
  succeeds.
- CLI smoke: imports load, class/method resolution succeeds, run
  loop reached. Full UI verification deferred to leaf `040`.
- `knowledge/apps/scenekit-viewer/spec.md` exists (copy from racket).

## Notes
- SceneKit is heavy at the framework level; the chez `scenekit.sls`
  facade may take noticeable time during the precompile pass even
  in this leaf's bundle. Acceptable — leaf `105` already
  established the precompile baseline.
- The racket version uses standard SceneKit setup: SCNView with a
  SCNScene, an SCNNode containing geometry, an animation block or
  delegate driving rotation. Mirror that shape; spell-check
  selectors against the racket source.
- If the SceneKit per-class set has any gaps (constants missing,
  protocols not exported), that's a stop-and-fix-emitter sub-leaf,
  not in-scope for this leaf — split into `020a-emit-scenekit-fix`
  before continuing the port.

## Pointers
- Reference shape: ui-controls-gallery `.sls` produced by leaf
  `010` of this node — same import set + `define-entry-point`
  wrapper.
