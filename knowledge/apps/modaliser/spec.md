# Modaliser

## Purpose
Capstone application — the final proof that a target's bindings are production-ready.
Exercises keyboard capture, window management, app lifecycle, UI overlays, and a
language-idiomatic configuration/scripting system.

## Complexity Level
Position 8 of 8 (capstone, after all 7 standard apps).

## Prerequisites
All 7 standard apps should be completed first — Modaliser builds on every capability
they exercise.

## Capabilities Exercised
- Global keyboard capture (CGEvent taps)
- Window management (position, resize, animate)
- App lifecycle (activate, hide, quit external apps)
- Modal UI overlays (transparent overlay windows)
- Fuzzy search
- Clipboard integration
- Hierarchical command trees
- Per-app configuration overrides
- Theme customisation

## Specification
_Derived from the working POC at `{{DEV_ROOT}}/Modaliser`. To be filled in by cataloguing
all features and behaviours from the POC, abstracting away Swift/Scheme-specific
implementation details._

The operational contract that any implementation must satisfy is split across
neighbouring files:

- `logging-contract.md` — structured event format every impl must emit.
- `observable-state.md` — per-state observables the spec runner can read.
- `scenarios/` — executable cross-impl scenario suites in `#lang app-spec`,
  organised by area (`launch/`, `lifecycle/`, `modal/`, `choosers/`,
  `windows/`, plus shared `helpers/`). Run via the AppSpec runner
  (`{{DEV_ROOT}}/AppSpec/run.sh`) against a chosen `--impl` config.
- `artifacts/` — captured runner outputs (gitignored).

## Platform Compliance Requirements
_To be defined during spec derivation._

## Reference Implementation
The POC at `{{DEV_ROOT}}/Modaliser` is a working Swift app with LispKit (Scheme) scripting.
It is the authoritative source for behaviour, features, and UX expectations.

The Racket-OO target's reference implementation lives at
`../../../generation/targets/racket-oo/apps/modaliser/`; its `--impl` config
for the AppSpec runner is `modaliser-impl.rkt` in that directory.
