# appspec-scenekit-viewer-k79

**Kind:** work

## Goal

The full AppSpec cycle for **scenekit-viewer** (the SceneKit 3D scene viewer):
reverse-gen the spec from the four VM-verified impls, instrument to the contracts,
rebuild, forward-gen the scenario suite, Tier-2 live-run all four impls.

## Context

Same shape as `appspec-ui-controls-gallery-k77` — hello-window (k64/k67–k74) is the
worked template; drive via `~/Development/AppSpec/capabilities/*/workflow.md`; data
homes at `apps/macos/scenekit-viewer/` + the per-target
`app-implementations/macos/scenekit-viewer/` (ADR-0052 / AppSpec ADR-0013).
**Expected to decompose on entry** (`leaf-decompose`; first child only that session).

App-specific: a GPU/3D view renders in the VM but its *contents* are not
AX-observable — expectations must lean on the logging contract + window/AX structure
(the scene-loaded log line, the SCNView's presence), not rendered pixels. A finding
about what 3D behaviour *is* verifiable in-VM is itself spec-quality output.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored. Commits name the child handles.
