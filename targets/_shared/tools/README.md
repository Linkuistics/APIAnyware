# targets/_shared/tools/ — shared projection substrate (crate home)

Crate home for the projection substrate shared across all four targets
(crate-home convention: Rust crates live under `<domain>/tools/`). Holds the
`emit` crate (the cross-cutting emitter library plus the `naming` acronym table),
`stub-launcher`, and `generate-cli` (the `apianyware-generate` binary) — consumed
by every emitter (`emit-racket`/`-chez`/`-gerbil`/`-sbcl`) and by zero analysis
crates, which is why it is target-domain machinery rather than `semantic/`
(ADR-0044).

Landed in `move-target-crates-k7` (`git mv` from `generation/crates/`, workspace
`members` + `[workspace.dependencies]` paths repointed). The emitted *material*
under `generation/targets/<t>/` still relocates in `move-target-material-k8`.
