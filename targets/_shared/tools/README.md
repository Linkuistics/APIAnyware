# targets/_shared/tools/ — shared projection substrate (crate home)

Crate home for the projection substrate shared across all four targets
(crate-home convention: Rust crates live under `<domain>/tools/`). Will hold the
`emit` crate (the cross-cutting emitter library plus the `naming` acronym table),
`stub-launcher`, and the generate CLI — consumed by every emitter
(`emit-racket`/`-chez`/`-gerbil`/`-sbcl`) and by zero analysis crates, which is
why it is target-domain machinery rather than `semantic/` (ADR-0044).

TODO: empty until `move-target-crates-k7` `git mv`s `emit`, `stub-launcher`, and
`generate-cli` here and repoints the workspace `members` + `[workspace.dependencies]`
paths.
