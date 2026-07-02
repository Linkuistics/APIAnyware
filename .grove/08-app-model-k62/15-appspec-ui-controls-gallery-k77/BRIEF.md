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
  1. **`reverse-gen-k86`** ✅ — the projection-free spec from the four impls
     (replaces the precursor `docs/spec.md`), via the AppSpec reverse-gen workflow.
  2. **`conformance-data-k87`** ✅ — `logging-contract.md` + `observable-state.md`
     (the hello-window k67 stage).
  3. **`instrument-builds-k88`** ✅ *(node; children k89 racket / k90 chez / k91
     gerbil / k92 sbcl, all done 2026-07-02)* — see **Instrument+build outcomes**.
  4. **`forward-gen-suite-k93`** — forward-gen scenario suite + `run-values.rkt`.
  5. *(planned)* Tier-2 live-run all four impls → `docs/run-results.md`.

## Instrument+build outcomes (promoted from `instrument-builds-k88` on retirement)

All four impls emit the k87 contract's events and are built as launchable `.app`s —
what the forward-gen (k93) + live-run stages rely on:

- **Artifacts per impl** (`targets/<t>/app-implementations/macos/ui-controls-gallery/`):
  the events emitter, `build.sh`, `.app` at `build/UIControlsGallery-<impl>.app` with
  `CFBundleIdentifier com.linkuistics.ui-controls-gallery-<impl>`, and the
  `#lang app-spec/impl` descriptor `ui-controls-gallery-impl.rkt` (`#:binary
  /Applications/UIControlsGallery-<impl>.app`).
- **Emit semantics shared by all four:** post-state emission (checkbox toggles /
  radio exclusion applied before the event), integer slider/stepper values, lowercase
  `reason`; `shutdown reason=menu` is the implemented terminate path (signal/error
  paths unexercised). Each emitter was verified in isolation against the contract
  matchers.
- **Cross-impl variance** (the suite must respect): sbcl checkbox launches ON (assert
  the flip); sbcl has radios A/B only, racket/chez/gerbil add Option C (assert A/B
  titles only); sbcl radios rely on platform sibling-group exclusion (shared action),
  the others clear siblings explicitly — both conform.
- **sbcl gained a dylib** (k92): the contract callbacks need libAPIAnywareSbcl's
  subclass bounce shim (ADR-0035), so its build moved to the production bundler
  (hello-window k75 shape — vendored libzstd + libAPIAnywareSbcl; the `.app` travels
  alone). gerbil's emitter is pure-Gambit inlined in the `.ss` (no binding rebuild →
  no gcc-15 shim needed); chez keeps its emitter inline in the `.sls` (R6RS body
  semantics).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles (or
`appspec-ui-controls-gallery-k77` if it somehow fits one session).

## Notes

Richer surface than hello-window: many control types → more observable state + more
scenarios. Sample apps must be visually perfect ([[sample_apps_perfect]]) — the suite
should exercise the controls, not just launch/quit.
