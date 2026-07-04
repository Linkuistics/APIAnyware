# APIAnyware

Idiomatic macOS API bindings for every language.

APIAnyware extracts the full macOS platform API surface (Objective-C, C, Swift),
analyses it into a projection-independent semantic model, and generates **native,
idiomatic** bindings per target language — not a lowest-common-denominator C
wrapper. A Haskell user gets monadic error handling; a Smalltalk user gets
message-passing objects; an OCaml user gets modules and variants. Each target's
binding is, abstractly, a complete C-ABI re-export of the entire macOS API vended
by a per-target native (Swift) library — *the native library is the binding*
([ADR-0010](adr/0010-native-library-is-the-binding.md)) — with **trampoline
elision** binding directly whatever the target can already reach
([ADR-0025](adr/0025-complete-api-model-and-trampoline-elision.md)).

Part of the APIAnyware family by [Linkuistics](https://linkuistics.com). See also
`APIAnyware-Windows` and `APIAnyware-Linux` (planned).

## Status

The `collect → analyse → generate` pipeline runs end-to-end. Four language targets
are complete and VM-verified: **Racket**, **Chez Scheme**, **Gerbil Scheme**, and
**SBCL (Common Lisp)**. Remaining Common Lisp implementations and other languages
(Haskell, Idris2, OCaml, Prolog/Mercury, Rhombus, Pharo, Zig, …) are planned.

> **Note:** the repository is mid-way through the `structural-refactoring`
> re-architecture (`REFACTOR.md`) — from pipeline-phase directories
> (`collection/`/`analysis/`/`generation/`) into the domain structure mapped
> below. Some pipeline-internal paths are still being relocated; the domain tree
> is authoritative for where things live.

## Repository map

The repo partitions by **domain** (meaning/role), not by pipeline phase. Each
domain owns its own co-located `docs/` ([ADR-0024](adr/0024-per-language-docs-co-locate-adrs-stay-central.md),
REFACTOR §10) — there is no large top-level `docs/` tree.

| Path | What lives here |
|---|---|
| `semantic/` | Projection-independent source semantics: the meaning of platform APIs, first-class pattern-kinds, relationship entities. Pipeline/analysis docs in `semantic/docs/`. |
| `platforms/<platform>/` | Per-platform formal API truth, kept projection-free. `platforms/macos/` is the only live platform; API families under `api/<family>/`, extractors + annotate under `tools/`. |
| `apps/<platform>/<app>/` | Language-agnostic AppSpec exemplars — the common sample-app portfolio (generated apps are conformance tests, not demos). Portfolio index: [`apps/macos/docs/_index.md`](apps/macos/docs/_index.md). |
| `targets/<target>/` | Everything specific to one target: emitter + bundler (`tools/`), native adapter (`adapters/`), generated bindings (`bindings/`), app implementations (`app-implementations/`), conformance reports, and `docs/`. |
| `targets/_shared/` | Cross-target machinery owned by no target: the shared projection substrate `emit`, `stub-launcher`, the generate CLI ([ADR-0044](adr/0044-shared-emit-substrate-home-targets-shared.md)). |
| `schemas/` | Formal schemas validating every artifact (`schemas/docs/`). |
| `adr/` | The central Architecture Decision Record log — a cross-target decision graph kept central with global numbering ([ADR-0024](adr/0024-per-language-docs-co-locate-adrs-stay-central.md)). |
| `prd/` | Human-facing agreement checkpoints (Product Requirement Documents). |
| `process/` | Development-process / tooling artifacts (completed plans, skill design) owned by no domain. |
| `website/` | The project website (`index.md`, `meta.yml`). |

Targets are **hermetically isolated** — they share the API analysis and nothing
downstream of it ([ADR-0011](adr/0011-targets-hermetically-isolated.md)). One
binding style per target, implicit in the target ([ADR-0004](adr/0004-retire-paradigm-dimension.md)).

## Running the pipeline

Prerequisites: Rust (see `.tool-versions`) and Xcode (libclang + swift-api-digester;
`export SDKROOT=macosx`).

```sh
cargo run -p apianyware-collect                       # extract the macOS SDK API surface
cargo run -p apianyware-analyze                       # resolve → annotate → enrich
cargo run -p apianyware-analyze -- resolve            #   (individual analysis steps)
cargo run -p apianyware-generate -- --target racket   # generate one target's bindings
cargo run -p apianyware-generate -- --list-targets    #   available emitters
```

**LLM annotation** runs inside Claude Code (open the project and run `/analyze`):
it reads resolved IR, fetches Apple docs, and writes semantic annotations under the
platform's API families. See [`platforms/macos/docs/annotation-workflow.md`](platforms/macos/docs/annotation-workflow.md).

## Building & testing

```sh
cargo build                              # build the workspace
cargo test --workspace                   # run all Rust tests
UPDATE_GOLDEN=1 cargo test --workspace   # refresh emitter golden files
cargo fmt --all && cargo clippy --workspace
```

Per-target native adapters (Swift dylibs / native cores) build from each target
unit; see that target's `docs/reference.md`. Every sample app is verified
visually in a macOS VM via TestAnyware — **never run GUI apps from the host CLI**
— per [`testing/testanyware-workflow.md`](testing/testanyware-workflow.md).

## Documentation

Docs live with their subject; start here:

- **Architecture & decisions** — [`adr/`](adr/) (central decision log).
- **Pipeline / analysis** — [`semantic/docs/`](semantic/docs/) (`analysis.md`,
  `enrich-rules.md`, `api-pattern-catalog.md`, `memory-architecture.md`).
- **Platform extraction** — [`platforms/macos/docs/`](platforms/macos/docs/)
  (`collection.md`, `annotation-workflow.md`, `codesigning-identity.md`).
- **Adding a target / emitter contract** — [`targets/_shared/docs/`](targets/_shared/docs/)
  (`adding-a-language-target.md`, `emitter-contract.md`, `type-mapping.md`).
- **Per-target references** — `targets/<target>/docs/reference.md`.
- **App portfolio** — [`apps/macos/docs/_index.md`](apps/macos/docs/_index.md).
- **Glossary / ubiquitous language** — [`CONTEXT.md`](CONTEXT.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE).
