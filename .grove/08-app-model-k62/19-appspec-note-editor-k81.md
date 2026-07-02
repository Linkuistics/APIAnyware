# appspec-note-editor-k81

**Kind:** work

## Goal

The full AppSpec cycle for **note-editor** (the text-editing + persistence app):
reverse-gen the spec from the four VM-verified impls, instrument to the contracts,
rebuild, forward-gen the scenario suite, Tier-2 live-run all four impls.

## Context

Same shape as `appspec-ui-controls-gallery-k77` — hello-window (k64/k67–k74) is the
worked template; drive via `~/Development/AppSpec/capabilities/*/workflow.md`; data
homes at `apps/macos/note-editor/` + the per-target
`app-implementations/macos/note-editor/` (ADR-0052 / AppSpec ADR-0013).
**Expected to decompose on entry** (`leaf-decompose`; first child only that session).

App-specific: the first app with **state-mutating persistence** — scenarios that
create/edit/save notes mutate on-disk state, so suite ordering + cleanup between
scenarios matter (the `#lang app-spec` state-mutating discipline hello-window's
scenario 03 established). Editing behaviours the user called out — double-click,
edit-in-place, empty state — are first-class expectations
([[sample_apps_perfect]]).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored. Commits name the child handles.
