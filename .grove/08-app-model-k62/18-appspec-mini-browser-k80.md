# appspec-mini-browser-k80

**Kind:** work

## Goal

The full AppSpec cycle for **mini-browser** (the WKWebView browser): reverse-gen the
spec from the four VM-verified impls, instrument to the contracts, rebuild, forward-gen
the scenario suite, Tier-2 live-run all four impls.

## Context

Same shape as `appspec-ui-controls-gallery-k77` — hello-window (k64/k67–k74) is the
worked template; drive via `~/Development/AppSpec/capabilities/*/workflow.md`; data
homes at `apps/macos/mini-browser/` + the per-target
`app-implementations/macos/mini-browser/` (ADR-0052 / AppSpec ADR-0013).
**Expected to decompose on entry** (`leaf-decompose`; first child only that session).

App-specific: the VM has **no network** (the k74 racket provisioning ran with
option 1, no VM network) — scenarios must load a **local fixture page**
(`file://` or a bundled HTML fixture), never a live URL. Navigation state
(URL field, back/forward enablement, page title) is the observable core.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]]);
`docs/run-results.md` authored. Commits name the child handles.
