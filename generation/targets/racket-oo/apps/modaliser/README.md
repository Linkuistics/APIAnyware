# modaliser — racket-oo

Capstone application: a Racket reimplementation of the Modaliser modal
keyboard system for macOS. Multi-file (vs. the demo apps) — entry point is
`main.rkt`; the .app bundle is built via `bundle/build.sh`.

## Required reading

- Spec: `{{PROJECT}}/knowledge/apps/modaliser/spec.md`
- Logging contract: `{{PROJECT}}/knowledge/apps/modaliser/logging-contract.md`
- Observable state: `{{PROJECT}}/knowledge/apps/modaliser/observable-state.md`
- Test strategy: `{{PROJECT}}/knowledge/apps/modaliser/test-strategy.md`
- App learnings: `{{PROJECT}}/knowledge/apps/modaliser/learnings.md`
- Cross-impl scenarios: `{{PROJECT}}/knowledge/apps/modaliser/scenarios/`
  (run via `{{DEV_ROOT}}/AppSpec/run.sh`)
- Target plan: `{{PROJECT}}/LLM_STATE/targets/racket-oo/backlog.md`
- App-specific plan: `{{PROJECT}}/LLM_STATE/apps/modaliser-racket/backlog.md`

## Local entry points

- `main.rkt` — app entry (NSApplication + Cocoa run loop).
- `modaliser-impl.rkt` — `--impl` config consumed by the AppSpec runner.
- `bundle/build.sh` — builds `build/Modaliser.app` with the Swift stub
  launcher (~3 s; requires `swiftc` and a stable codesigning identity for TCC
  to survive rebuilds — see `bundle/setup-dev-cert.sh`).
- `tests/run-all.sh` — full impl test suite (VM-only; integration tests need
  Accessibility permission for the `racket` binary).

## User config

`~/.config/modaliser/config.scm` — user's keymap and command definitions,
loaded at startup into a flat namespace pre-populated with the DSL functions.
