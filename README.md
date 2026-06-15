# APIAnyware-MacOS

Idiomatic macOS API bindings for every language.

Extracts, analyzes, and generates native bindings for the full macOS platform API surface (ObjC, C, Swift) -- targeting a broad set of languages: Racket, Chez Scheme, Gerbil Scheme, Common Lisp (SBCL, CCL), Haskell, Idris2, OCaml, Prolog, Mercury, Rhombus, Pharo Smalltalk, Zig, and others.

Part of the [APIAnyware](https://linkuistics.com) family by [Linkuistics](https://linkuistics.com) ("The Language of the Web" -- linking languages to platforms). See also `APIAnyware-Windows` and `APIAnyware-Linux` (planned).

## Current Status

The full three-phase pipeline (Collection, Analysis, Generation) is implemented and working end-to-end. Three language targets are complete: **Racket**, **Chez Scheme**, and **Gerbil Scheme**.

- **Collection** extracts 218 ObjC frameworks and 151 Swift modules from the macOS SDK, merging ObjC and Swift declarations into a unified IR. Cross-import overlay frameworks (`_RealityKit_SwiftUI`, `_AppIntents_SwiftUI`, …) correctly retain the bridged classes that form their API surface.
- **Analysis** runs Datalog-based inheritance resolution, heuristic + LLM semantic annotation (block lifecycle, ownership, threading, error patterns), API pattern recognition (10 stereotype categories, 36+ pattern instances in Foundation alone), and enrichment with verification.
- **Generation** produces bindings per target — Racket for all 284 discovered frameworks (~6,979 files), Chez and Gerbil for the frameworks the sample-app portfolio exercises — each with its own hand-written runtime library and per-target native binding layer (a Swift helper dylib for racket/chez; an ObjC-in-gsc native core for gerbil).
- **All active sample apps** in the portfolio (per `docs/apps/_index.md`) are implemented and VM-verified for each completed target. Sample apps are packaged as proper macOS `.app` bundles (correct `CFBundleName`, signed with a persistent local code-signing identity so the CDHash is stable and TCC grants survive rebuilds) via the per-target bundler crates (`bundle-racket`, `bundle-chez`, `bundle-gerbil`); chez and gerbil bundles are fully self-contained native binaries needing no runtime install.
- **Snapshot tests** use a synthetic TestKit framework plus a curated Foundation subset for regression testing; Rust and Swift test suites cover the pipeline.

All other language targets (Common Lisp, Haskell, Idris2, OCaml, Prolog/Mercury, Rhombus, Pharo Smalltalk, Zig) are planned but not yet started.

## Goals

- **Idiomatic, not mechanical.** Each target language gets bindings that feel native -- not a lowest-common-denominator C wrapper. A Haskell user gets monadic error handling; a Smalltalk user gets message-passing objects; an OCaml user gets modules and variants.
- **One binding style per target.** Each target commits to a single idiomatic shape, implicit in the target (ADR-0004 retired the per-target style dimension). A language wanting two shapes registers two targets — and language *implementations* are separate targets too (chez and gerbil are siblings, not flavours of "Scheme").
- **Full API coverage.** Every framework in the macOS SDK, not just Foundation and AppKit. Both ObjC and Swift-only APIs.
- **API pattern recognition.** Many APIs implement stereotypical patterns -- builder sequences, open/use/close lifecycles, observer registration/removal pairs, begin/commit transactions. The analysis phase recognizes these cross-method behavioral contracts and encodes them in the IR, enabling emitters to produce idiomatic wrappers like `with-path` (Lisp/Scheme), `withCGContext` (Haskell), or RAII guards (Zig) automatically.
- **Auto-generated with human-quality results.** The enriched IR carries enough semantic information (ownership, threading, block lifecycle, error patterns, API usage patterns) for emitters to make intelligent wrapping decisions without per-method human intervention.

## Architecture

Three-phase pipeline, each communicating via JSON checkpoint files:

```
Collection ──► Analysis ──► Generation
```

**Collection** parses macOS SDK headers (libclang) and Swift modules (swift-api-digester) to produce raw API metadata with full provenance and documentation references. Discovers 218 ObjC frameworks and 151 Swift modules automatically.

**Analysis** resolves inheritance via Datalog (ascent crate), adds semantic annotations (block invocation style, parameter ownership, threading constraints, error patterns, API usage patterns) via heuristics and LLM analysis, then enriches with Datalog-derived relations for generation. API pattern recognition identifies stereotypical multi-method contracts (builder sequences, resource lifecycles, observer pairs) by analyzing Apple's guides and tutorials in addition to API reference documentation. Includes verification rules that flag annotation inconsistencies.

**Generation** emits per-target bindings with runtime support libraries and per-target native binding layers. Each emitter reads the same enriched IR but produces output shaped to the target language's idioms and conventions. Currently produces bindings for the racket, chez, and gerbil targets.

## Pipeline & Checkpoints

Each phase reads the previous checkpoint and writes the next. Intermediate checkpoints allow re-running expensive steps (especially LLM annotation) independently.

| Checkpoint | Location | Produced by | Contains |
|---|---|---|---|
| Collected | `collection/ir/collected/` | `apianyware-macos-collect` | Raw declarations, provenance, doc refs |
| Resolved | `analysis/ir/resolved/` | `apianyware-macos-analyze resolve` | + inheritance, effective methods, ownership |
| Annotated | `analysis/ir/annotated/` | `apianyware-macos-analyze annotate` + LLM | + block/threading/ownership/pattern annotations |
| Enriched | `analysis/ir/enriched/` | `apianyware-macos-analyze enrich` | + derived relations, pattern instances, verification |
| Generated | `generation/targets/{lang}/generated/` | `apianyware-macos-generate` | Per-language, per-style bindings |

## Quick Start

### Prerequisites

- Rust (see `.tool-versions`)
- Xcode (provides libclang and swift-api-digester)

### Collect API metadata from the SDK

```sh
cargo run -p apianyware-macos-collect
```

Discovers all frameworks in the macOS SDK and writes `collection/ir/collected/{Framework}.json`.

### Run the analysis pipeline

```sh
cargo run -p apianyware-macos-analyze
```

Runs resolve -> annotate -> enrich on all collected frameworks. Individual steps:

```sh
cargo run -p apianyware-macos-analyze -- resolve     # Datalog pass 1
cargo run -p apianyware-macos-analyze -- annotate    # heuristics + LLM merge
cargo run -p apianyware-macos-analyze -- enrich      # Datalog pass 2 + verification
```

### Generate language bindings

```sh
cargo run -p apianyware-macos-generate
```

Generates bindings for all registered languages and all binding styles from the enriched IR. To generate for a specific language:

```sh
cargo run -p apianyware-macos-generate -- --target racket
cargo run -p apianyware-macos-generate -- --list-targets    # show available emitters
```

Output goes to `generation/targets/{target}/` — under the target's library-root convention (`racket/generated/`, `chez/apianyware/`, `gerbil/lib/`).

### LLM annotation (Claude Code)

Open this project in Claude Code and run:

```
/analyze
```

This reads resolved IR, fetches Apple documentation, and produces semantic annotations. The annotations are checked into `analysis/ir/annotated/` and only need to be re-run when the SDK updates.

Alternatively, use any OpenAI-compatible API:

```sh
./analysis/scripts/llm-annotate.sh
```

## Development

### Build & Test Commands

```bash
# Rust workspace
cargo build                                    # Build all crates
cargo test --workspace                         # Run all tests (~248 tests)
cargo test -p apianyware-macos-emit-racket  # Single crate
cargo +nightly fmt                             # Format (requires nightly)
cargo clippy --workspace                       # Lint

# Swift dylibs (from repo root)
cd swift && swift build                        # Build all dylibs
cd swift && swift test                         # Run Swift tests (~64 tests)

# Snapshot tests: update golden files after emitter changes
UPDATE_GOLDEN=1 cargo test --workspace
```

### Coding Conventions

- **TDD** -- write tests first
- **Descriptive names** -- long is fine; consistency matters (don't mix
  `get_thing`/`fetch_thing`)
- **Small files** -- each file handles one concern
- **`thiserror`** for library errors, **`anyhow`** for CLI/application errors
- **`tracing`** macros only (not `log` crate)
- **Bounded channels only** -- `unbounded_channel` is banned
- **No `unwrap`/`expect`** in production code
- **Import grouping**: stdlib -> external -> local (enforced by rustfmt)
- **`cargo +nightly fmt`** before committing

### Crate Map

**Shared types** -- `collection/crates/types/` (`apianyware-macos-types`):
IR structs (Framework, Class, Method, Property, Protocol, Enum, TypeRef),
annotation schema, checkpoint format. Depended on by everything.

**Collection** -- `collection/crates/extract-objc/` (libclang parsing),
`extract-swift/` (swift-api-digester), `cli/` (orchestration). The ObjC
extractor's `type_mapping.rs` resolves typedefs to canonical types at
extraction time -- this is critical for correct FFI signatures downstream.

**Analysis** -- `analysis/crates/datalog/` (shared Ascent-based relations),
`resolve/` (inheritance flattening, ownership detection), `annotate/`
(heuristic + LLM annotation merge), `enrich/` (derived relations,
verification), `cli/`.

**Generation** -- `generation/crates/emit/` (shared framework: `FfiTypeMapper`
trait, `CodeWriter`, naming utils, snapshot testing, pattern dispatch), one
`emit-{target}/` crate per target (`emit-racket/`, `emit-chez/`, `emit-gerbil/`),
`cli/` (emitter registry, orchestration). Per-target emission specifics live in
each target's own `generation/targets/{target}/docs/reference.md`.

**Tooling** -- `generation/crates/stub-launcher/`
(`apianyware-macos-stub-launcher`): generates per-app Swift stub binaries
for TCC-compatible `.app` bundles. Each stub `execv`s into the language
runtime, giving it a unique CDHash so macOS TCC grants permissions per-app
rather than per-runtime. See [App Bundling](#app-bundling) below.

**Swift dylibs** -- `swift/` contains the per-target C-callable bridges
(`APIAnywareRacket`, `APIAnywareChez`) that handle message sending, memory
management, struct marshaling, and block/delegate bridging. There is **no shared
native substrate** — each target's bridge is self-contained (ADR-0011); gerbil
has no Swift dylib at all (its ObjC core is compiled into the exe by `gsc`,
ADR-0017).

### Key Patterns

These are the cross-cutting patterns in the shared emitter framework; how each
target dispatches, coerces arguments, and tests emission is target-specific and
documented in that target's `generation/targets/{target}/docs/reference.md`.

- **`effective_methods()`/`effective_properties()`** in emitters: choose
  between direct and inherited method lists, with deduplication by
  selector/name.
- **Pattern dispatch**: the enriched IR's recognized API patterns (builder
  sequences, resource lifecycles, observer pairs) drive emitter decisions
  uniformly across targets.
- **`GoldenTest`** (`emit::snapshot_testing`): directory-comparison snapshot
  harness with unified diffs; targets opt into external golden files or inline
  `#[test]`s as suits them.
- **`test_fixtures::build_snapshot_test_framework()`**: deterministic
  synthetic `TestKit` framework exercising all emitter code paths.

### App Bundling

Sample apps need to be packaged as proper macOS `.app` bundles for two
reasons:

1. **Menu bar app name.** Cocoa reads the bold app name in the menu bar
   from `CFBundleName` in `Info.plist`. An unbundled `racket script.rkt`
   process shows up as "racket"; a bundled process shows the real app
   name. `NSProcessInfo setProcessName:` is filtered by modern macOS and
   doesn't help.
2. **Per-app TCC permissions** (Accessibility, Camera, Screen Recording,
   etc.). macOS TCC keys permission grants on the binary's CDHash. Without
   a unique stub binary per app, every Racket app shares one TCC entry
   under `/opt/homebrew/bin/racket`.

The bundling story is layered: a language-agnostic primitive
(`stub-launcher`) plus a **per-target convention crate** that knows how that
language's apps are assembled — `bundle-racket`, `bundle-chez`, `bundle-gerbil`.

#### Per-target convention crates

Each target ships its own bundler that handles the language-specific assembly —
racket's `bundle-racket` walks the entry script's transitive `(require ...)`
tree and stages only the needed runtime/generated files; chez's `bundle-chez`
and gerbil's `bundle-gerbil` instead produce self-contained native binaries that
need no runtime install. The invocation is uniform:

```sh
cargo run --example bundle_app -p apianyware-macos-bundle-<target> -- <app>
# → generation/targets/<target>/apps/<app>/build/<App Name>.app
```

Display name and `com.linkuistics.<NoSpaceTitle>` bundle id are derived from the
kebab-case app name; built bundles live under `apps/<app>/build/` and are
gitignored. The per-target bundling mechanics (require-walking, kernel embedding,
`gxc -exe` + dylib relocation, resulting bundle layout) are documented in each
target's `generation/targets/<target>/docs/reference.md`.

#### Language-agnostic primitive: `apianyware-macos-stub-launcher`

The lower-level crate handles the target-neutral parts: generating the Swift
launcher source, compiling it via `swiftc`, producing `Info.plist`, and
assembling the `.app` skeleton. A `StubConfig` parameterizes the app name,
the runtime path baked in at compile time, the script resource, and the bundle
identifier; `create_app_bundle()` emits the skeleton and each per-target bundler
crate wraps it. New language targets get their own convention crate that does the
same. (`generate_stub_source()` / `compile_stub()` / `generate_info_plist()` are
exposed for custom workflows.)

### GUI Testing with TestAnyware

Every sample app, for every target, is verified visually in a macOS VM via
TestAnyware — a window must actually draw and behave; CLI smoke never satisfies
the bar. **Never run GUI apps directly from the host CLI.** Each VM exposes an
Agent channel (exec, file transfer, accessibility snapshot/inspect, UI actions)
and a VNC channel (screenshots, OCR `find-text`, input). Results are recorded per
app under `generation/targets/<target>/test-results/<app>/report.md`.

The full step-by-step QA workflow (boot a VM, stage the bundle, launch, verify,
tear down) and the report format live in **[docs/testing/general.md](docs/testing/general.md)**.
App specs and validation checklists are at `docs/apps/<app>/spec.md` and
`docs/apps/<app>/test-strategy.md`. Bundling is required before testing: an
unbundled script shows up under the runtime's name (e.g. "racket") in the menu
bar and shares one TCC identity.

## Workspace Structure

```
APIAnyware-MacOS/
  Cargo.toml                              # workspace root

  collection/
    crates/
      types/               # apianyware-macos-types            — shared IR + annotation schema
      extract-objc/        # apianyware-macos-extract-objc     — libclang ObjC/C parsing
      extract-swift/       # apianyware-macos-extract-swift    — swift-api-digester
      cli/                 # apianyware-macos-collect           — collection CLI
    ir/collected/                                               — checkpoint output

  analysis/
    crates/
      datalog/             # apianyware-macos-datalog           — shared Datalog types + loaders
      resolve/             # apianyware-macos-resolve           — Datalog pass 1
      annotate/            # apianyware-macos-annotate          — heuristics + LLM merge
      enrich/              # apianyware-macos-enrich            — Datalog pass 2 + verification
      cli/                 # apianyware-macos-analyze           — analysis CLI
    ir/resolved/                                                — checkpoint
    ir/annotated/                                               — checkpoint (LLM annotations here)
    ir/enriched/                                                — checkpoint (Generation reads this)
    docs/                                                       — memory model, workflow docs
    scripts/                                                    — LLM annotation scripts

  generation/
    crates/
      emit/                # apianyware-macos-emit              — shared emitter framework
      emit-racket/         # apianyware-macos-emit-racket       — Racket emitter
      emit-chez/           # apianyware-macos-emit-chez         — Chez emitter
      emit-gerbil/         # apianyware-macos-emit-gerbil       — Gerbil emitter
      cli/                 # apianyware-macos-generate          — generation CLI
      stub-launcher/       # apianyware-macos-stub-launcher     — Swift stub + Info.plist + .app skeleton (language-agnostic)
      bundle-racket/       # apianyware-macos-bundle-racket     — racket bundling: require walker + resource layout
      bundle-chez/         # apianyware-macos-bundle-chez       — chez bundling: self-contained kernel-embed binary
      bundle-gerbil/       # apianyware-macos-bundle-gerbil     — gerbil bundling: gxc -exe + dylib relocation
    targets/
      racket/              # Racket: runtime, generated bindings, sample apps, tests
      chez/                # Chez: runtime, generated bindings, sample apps, tests
      gerbil/              # Gerbil: runtime + ObjC-in-gsc native core, generated bindings, sample apps, tests

  swift/                   # Swift helper dylibs (C-callable ObjC runtime interface; per-target — no shared substrate, ADR-0011)
    Sources/
      APIAnywareRacket/    # Racket-specific: GC prevention, block bridge, delegate bridge
      APIAnywareChez/      # Chez-specific: foreign-callable trampolines, block/delegate/dynamic-class bridges
                           # (gerbil has NO Swift dylib — its native core is ObjC compiled by gsc into the exe, ADR-0017)
```

### Target Languages

| Target | Binding style | Status |
|---|---|---|
| Racket | OO (classes, dynamic `tell` dispatch) | **Complete** — emitter, 283 frameworks generated, 8/8 sample apps, snapshot tests, app bundling |
| Chez Scheme | Procedural (per-class proc namespaces, guardian lifetime) | **Complete** — emitter, runtime, 7/7 sample apps VM-verified, self-contained `.app` bundling (ADR-0009); see `generation/targets/chez/docs/reference.md` |
| Gerbil Scheme | OO (manifest `defclass` graph, `{}` + `:std/generic` dual surface, transparent ObjC subclassing) | **Complete** — emitter, runtime + ObjC-in-gsc native core, 7/7 sample apps VM-verified, self-contained `.app` bundling; see `generation/targets/gerbil/docs/reference.md` |
| Common Lisp (SBCL, CCL) | CLOS + functional | Planned |
| Haskell | Monadic + lens-based | Planned |
| Idris2 | Dependently-typed wrappers | Planned |
| OCaml | Modules + OO | Planned |
| Prolog / Mercury | Relational | Planned |
| Rhombus | OO (classes) | Planned |
| Pharo Smalltalk | Message-passing OO | Planned |
| Zig | Low-level procedural | Planned |

Each target has exactly one binding style, implicit in the target (ADR-0004); a language wanting a second shape registers a second target. Targets are hermetically isolated -- they share the API analysis and nothing downstream of it (ADR-0011).

## Documentation

- [Design Spec](docs/specs/2026-03-26-macos-workspace-design.md) -- full architecture and checkpoint format
- [Adding a Language Target](docs/guides/adding-a-language-target.md) -- the new-target authoring guide: what to read, what to build, and the per-language docs to produce
- [Memory Architecture](docs/pipeline/memory-architecture.md) -- ObjC/Swift ownership model, block/delegate lifecycles, GC prevention, verification rules
- [Annotation Workflow](docs/pipeline/annotation-workflow.md) -- when and how to run each pipeline step, LLM annotation options, merge precedence
- [Enrichment Rules](docs/pipeline/enrich-rules.md) -- what each Datalog-derived relation means and how emitters use it
- [API Pattern Catalog](docs/pipeline/api-pattern-catalog.md) -- 10 stereotypical API patterns with detection rules and per-language translation templates
- [Emitter Contract](docs/pipeline/emitter-contract.md) -- cross-language conventions every target emitter must implement (e.g. OS_OBJECT_USE_OBJC handling)

## License

Apache License 2.0 -- see [LICENSE](LICENSE).
