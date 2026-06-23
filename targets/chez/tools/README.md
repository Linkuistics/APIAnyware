# targets/chez/tools/ — chez target crate home

Crate home for the `chez` target's Rust toolchain (crate-home convention: Rust
crates live under `<domain>/tools/`): the emitter `emit-chez` and the bundler
`bundle-chez`. Both depend on the shared `emit` substrate under
`targets/_shared/tools/` and are hermetically the `chez` target's own (ADR-0011
governs the generated runtime/output, not this emitter code — ADR-0043/0044).

Landed in `move-target-crates-k7` (`git mv` from `generation/crates/`, workspace
`members` + `[workspace.dependencies]` paths repointed). The emitted *material*
(bindings, app-implementations, adapters, docs, reports) relocates into
`targets/chez/` in `move-target-material-k8`.
