# appspec-drawing-canvas-k82

**Kind:** work

## Goal

The full AppSpec cycle for **drawing-canvas** (the custom-view drawing app):
reverse-gen the spec from the four VM-verified impls, instrument to the contracts,
rebuild, forward-gen the scenario suite, Tier-2 live-run all four impls.

## Context

Same shape as `appspec-ui-controls-gallery-k77` — hello-window (k64/k67–k74) is the
worked template; drive via `~/Development/AppSpec/capabilities/*/workflow.md`; data
homes at `apps/macos/drawing-canvas/` + the per-target
`app-implementations/macos/drawing-canvas/` (ADR-0052 / AppSpec ADR-0013).
**Expected to decompose on entry** (`leaf-decompose`; first child only that session).

App-specific: a custom `NSView` canvas exposes little AX structure — drawing
verification leans on the **logging contract** (stroke-committed events, tool/color
selection state) + coordinate-driven mouse gestures (drag paths via `run-values.rkt`
geometry, the k73 close-button-measurement pattern generalized to strokes).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored. Commits name the child handles.
