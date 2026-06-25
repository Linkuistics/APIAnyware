# targets/ — target-language expression and proof

The `targets/` domain holds everything specific to one target language
(REFACTOR.md §8, §7.2): capability profiles, idiom catalogues, policies, native
adapters, idiomatic bindings, app-implementations, conformance reports, and target
docs (§18). Projection lives here, never in `platforms/` (§45.10). Four targets
are live — `racket`, `chez`, `gerbil`, `sbcl` — and the shape accommodates the
many more in §19 without redesign (§45.9). Each target keeps a `targets/<t>/`
tree; cross-target machinery that belongs to no single target lives under
`_shared/` (ADR-0044).

Per-target `targets/<t>/` trees are formed as material arrives. The per-target
Rust crates (`emit-<t>`, `bundle-<t>`) landed under `targets/<t>/tools/` in
`move-target-crates-k7`; the bindings, app-implementations, adapters, docs, and
reports relocated in `move-target-material-k8`.

**Target model (workstream 6).** The authored knowledge layer over the four built
bindings is added by ws6, shared-crate machinery in
[`_shared/tools/target-model/`](_shared/tools/target-model) over per-target authored
`.apiw` data (decision D5). Landed so far:

- **Target descriptor** — `targets/<t>/target.apiw` (§17: family / dialect /
  implementation / FFI backend / runtime model / projection policy / adapter
  strategy), contract `schemas/spec-format/target.kdl-schema` (`target-descriptor-k51`).

Still owed by later ws6 children: capability profiles + representability,
idiom catalogues, projection policies, adapter specs, conformance reports, mapping
docs, and the bundler apps-root/bindings-root reshape.
