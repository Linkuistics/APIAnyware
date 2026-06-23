# move-target-crates-k7

**Kind:** work

## Goal

`git mv` the projection crates into the targets domain (Rust crates only — emitted
material is k8):

```text
generation/crates/emit           → targets/_shared/tools/emit          (ADR-0044)
generation/crates/stub-launcher  → targets/_shared/tools/stub-launcher
generation/crates/cli            → targets/_shared/tools/generate-cli   (bin apianyware-generate)
generation/crates/emit-<t>       → targets/<t>/tools/emit-<t>           (racket,chez,gerbil,sbcl)
generation/crates/bundle-<t>     → targets/<t>/tools/bundle-<t>         (racket,chez,gerbil,sbcl)
```

Update root `Cargo.toml` `members` + dep paths for all 11 crates. Fix path strings in
emit/emitters/bundlers that reference each other or `generation/` (the *emitted*-material
paths under `generation/targets/<t>/` are repointed in k8 — leave a `TODO:` if a test
references them and would break, or mark it `#[ignore]` with a note rather than fixing
the data path early).

## Context

See node brief — SC1/ADR-0044 (`emit`→`targets/_shared/`, precedent carries
`stub-launcher` + generate-cli), SC3 (`generate`-cli → `targets/_shared/`). Names
renamed (k4); semantic + platform crates already moved (k5/k6).

## Done when

All 11 crates under `targets/_shared/tools/` + `targets/<t>/tools/`; `cargo build`
green (target-material-dependent *tests* may be deferred to k8 — note any so deferred);
committed as `move-target-crates-k7`. After this, `generation/crates/` is empty.

## Notes

ADR-0010/0011 hermetic isolation is about runtime/output, not emitter code — the shared
`emit` stays one crate (ADR-0044), not duplicated per target. Build crate-by-crate.
