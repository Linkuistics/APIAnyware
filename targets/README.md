# targets/ — target-language expression and proof

The `targets/` domain holds everything specific to one target language
(REFACTOR.md §8, §7.2): capability profiles, idiom catalogues, policies, native
adapters, idiomatic bindings, app-implementations, conformance reports, and target
docs (§18). Projection lives here, never in `platforms/` (§45.10). Four targets
are live — `racket`, `chez`, `gerbil`, `sbcl` — and the shape accommodates the
many more in §19 without redesign (§45.9). Each target keeps a `targets/<t>/`
tree; cross-target machinery that belongs to no single target lives under
`_shared/` (ADR-0044).

TODO: per-target `targets/<t>/` trees are formed as material arrives in
`move-target-crates-k7` (the per-target Rust crates) and `move-target-material-k8`
(generated bindings, app-implementations, adapters, docs, reports). Capability
profiles, idiom catalogues, and policies are workstream 6 (target model). No
content this leaf.
