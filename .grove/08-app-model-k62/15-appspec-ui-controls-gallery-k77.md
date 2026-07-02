# appspec-ui-controls-gallery-k77

**Kind:** work

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
- **Expected to decompose on entry** — hello-window took 8 leaves. `leaf-decompose`
  into per-stage children (reverse-gen; per-target instrument+build; forward-gen
  suite; live-run) and do only the first child that session. The per-target
  instrumentation patterns now exist for all four targets (k68–k71), so stages may
  merge where they genuinely fit one session.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles (or
`appspec-ui-controls-gallery-k77` if it somehow fits one session).

## Notes

Richer surface than hello-window: many control types → more observable state + more
scenarios. Sample apps must be visually perfect ([[sample_apps_perfect]]) — the suite
should exercise the controls, not just launch/quit.
