# Related Plans

## Parents
Peer projects this plan depends on:
- {{DEV_ROOT}}/Modaliser — original Swift app being reimplemented (reference source at Sources/Modaliser/)
- {{DEV_ROOT}}/AppSpec — consumes the spec runner; this app's `modaliser-impl.rkt` is `#lang app-spec/impl`
- {{DEV_ROOT}}/TestAnyware — VM driver / agent / vision pipeline consumed by AppSpec (transitive)

## In-repo
- `generation/targets/racket-oo/` — racket-oo bindings (was cross-project `{{DEV_ROOT}}/APIAnyware-MacOS`; in-repo since the 2026-04-26 reorg)
