# appspec-ui-controls-gallery-k77 — brief

## Goal

The full AppSpec cycle for **ui-controls-gallery** (the AppKit controls gallery —
buttons, sliders, text fields, tables): reverse-gen the spec from the four VM-verified
impls, instrument the impls to the contracts, rebuild, forward-gen the scenario suite,
and Tier-2 live-run all four impls. First app through the now-proven toolkit after the
hello-window exemplar.

## Context

- **hello-window is the worked template** (k64 reverse-gen spec; k67 conformance data;
  k68–k71 per-target instrument+build; k72 forward-gen suite; k73/k74 live runs — all
  four impls 3/3). Its artifact shape is the target: `apps/macos/<app>/docs/{spec,
  logging-contract,observable-state,run-results}.md` + `scenarios/` + `run-values.rkt`.
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/ui-controls-gallery/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/ui-controls-gallery/`.
- **Decomposed on entry (2026-07-02)** — per-stage children, materialized lazily
  (grow the next as each retires; stages may merge where they genuinely fit one
  session, since the per-target instrumentation patterns already exist from k68–k71):
  1. **`reverse-gen-k86`** — the projection-free spec from the four impls
     (replaces the precursor `docs/spec.md`), via the AppSpec reverse-gen workflow.
  2. *(planned)* conformance data — `logging-contract.md` + `observable-state.md`
     (the hello-window k67 stage).
  3. *(planned)* per-target instrument+build — may fit fewer than four leaves now
     the patterns exist.
  4. *(planned)* forward-gen scenario suite + `run-values.rkt`.
  5. *(planned)* Tier-2 live-run all four impls → `docs/run-results.md`.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles (or
`appspec-ui-controls-gallery-k77` if it somehow fits one session).

## Notes

Richer surface than hello-window: many control types → more observable state + more
scenarios. Sample apps must be visually perfect ([[sample_apps_perfect]]) — the suite
should exercise the controls, not just launch/quit.
