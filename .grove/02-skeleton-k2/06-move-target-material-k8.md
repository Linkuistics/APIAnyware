# move-target-material-k8

**Kind:** work

## Goal

Relocate the per-target emitted/runtime material + Swift adapters into the §18 target
shape, and fix every golden/test/build-script path so `cargo test` + smokes go green.
For each target `<t>` in {racket, chez, gerbil, sbcl}:

```text
generation/targets/<t>/lib          → targets/<t>/bindings/macos/generated  (emitted binding)
generation/targets/<t>/apps         → targets/<t>/app-implementations/macos
generation/targets/<t>/runtime      → targets/<t>/bindings/macos/... (racket only; see note)
generation/targets/<t>/docs         → targets/<t>/docs
generation/targets/<t>/test-results → targets/<t>/.../reports             (§42)
generation/targets/<t>/tests        → targets/<t>/.../tests
swift/Sources/APIAnyware<T>         → targets/<t>/adapters/macos/<...>     (§45.12 native adapter)
swift/Tests/APIAnyware<T>Tests      → targets/<t>/adapters/macos/.../tests
```

Then fix the ~132 phase-dir path references catalogued in planning — golden-test paths,
emitter output dirs, bundler input/output paths (`bundle-<t>` src/examples/tests),
per-target build/smoke scripts (`gerbil/apps/hello-window/build.sh`,
`gerbil/lib/runtime/tests/run-swift-method-smoke.sh`, `racket/runtime/smoke/run.sh`),
and the Swift `Package.swift` (split per-target or repoint paths).

## Context

See node brief — §18 target shape, §42 generated/build/reports naming, SC6
(relocate-not-restructure). Target crates already moved (k7). Memories worth heeding:
`swift build --product` (not `--target`) to relink dylibs; gerbil gcc-15 shim; VM-verify
is a *later* workstream's bar, not this leaf's (CLI/test green suffices here).

## Done when

All four targets' material + Swift adapters relocated; phase-dir path references fixed;
`cargo test` green + each target's existing smoke runs from its new home; committed as
`move-target-material-k8`. After this, `generation/` is empty.

## Notes

**This is the heaviest leaf** — if one session can't hold all four targets, decompose
it per-target (`grove-llm leaf-decompose` → racket/chez/gerbil/sbcl children) rather
than rushing. The Swift `Package.swift` currently defines one umbrella with 4 modules;
decide per-target `Package.swift` vs a repointed umbrella — repoint is lower-risk for
the skeleton (note for adapter-model workstream 6). racket `runtime/` is the only target
with a hand-written runtime dir — give it a home under `bindings/macos/` with a TODO.
