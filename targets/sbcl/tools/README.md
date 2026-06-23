# targets/sbcl/tools/ — sbcl target crate home

Crate home for the `sbcl` target's Rust toolchain (crate-home convention: Rust
crates live under `<domain>/tools/`): the emitter `emit-sbcl` and the bundler
`bundle-sbcl`. Both depend on the shared `emit` substrate under
`targets/_shared/tools/` and are hermetically the `sbcl` target's own (ADR-0011
governs the generated runtime/output, not this emitter code — ADR-0043/0044).

Landed in `move-target-crates-k7` (`git mv` from `generation/crates/`, workspace
`members` + `[workspace.dependencies]` paths repointed). The emitted *material*
(bindings, app-implementations, adapters, docs, reports) relocates into
`targets/sbcl/` in `move-target-material-k8`.
