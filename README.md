# APIAnyware-MacOS

Idiomatic macOS API bindings for every language.

Extracts, analyzes, and generates native bindings for the full macOS platform API surface (ObjC, C, Swift) -- targeting a broad set of languages: Racket, Chez Scheme, Gerbil Scheme, Common Lisp (SBCL, CCL), Haskell, Idris2, OCaml, Prolog, Mercury, Rhombus, Pharo Smalltalk, Zig, and others.

Part of the [APIAnyware](https://linkuistics.com) family by [Linkuistics](https://linkuistics.com) ("The Language of the Web" -- linking languages to platforms). See also `APIAnyware-Windows` and `APIAnyware-Linux` (planned).

## Current Status

The full three-phase pipeline (Collection, Analysis, Generation) is implemented and working end-to-end. The first language target, **Racket**, is substantially complete:

- **Collection** extracts 218 ObjC frameworks and 151 Swift modules from the macOS SDK, merging ObjC and Swift declarations into a unified IR. Cross-import overlay frameworks (`_RealityKit_SwiftUI`, `_AppIntents_SwiftUI`, …) correctly retain the bridged classes that form their API surface.
- **Analysis** runs Datalog-based inheritance resolution, heuristic + LLM semantic annotation (block lifecycle, ownership, threading, error patterns), API pattern recognition (10 stereotype categories, 36+ pattern instances in Foundation alone), and enrichment with verification.
- **Generation** produces Racket bindings for all 284 discovered frameworks (~6,979 files total), with an 18-file Racket runtime library and a Swift helper dylib providing C-callable ObjC runtime access.
- **All 7 active sample apps** in the portfolio (per `knowledge/apps/_index.md`) are implemented for Racket. Sample apps can be packaged as proper macOS `.app` bundles (correct `CFBundleName`, signed with a persistent local code-signing identity so the CDHash is stable and TCC grants survive rebuilds) via `apianyware-macos-bundle-racket`.
- **Racket Functional** emitter crate exists as a registered stub; not yet implemented.
- **Snapshot tests** use a synthetic TestKit framework plus a curated Foundation subset for regression testing.
- **634 Rust tests** and **67 Swift tests** cover the pipeline.

All other language targets (Chez Scheme, Gerbil, Common Lisp, Haskell, Idris2, OCaml, Prolog/Mercury, Rhombus, Pharo Smalltalk, Zig) are planned but not yet started.

## Goals

- **Idiomatic, not mechanical.** Each target language gets bindings that feel native -- not a lowest-common-denominator C wrapper. A Haskell user gets monadic error handling; a Smalltalk user gets message-passing objects; an OCaml user gets modules and variants.
- **Multiple binding styles per language.** Languages with both OO and functional idioms (e.g., Common Lisp, OCaml, Racket) can produce both an object-oriented API and a functional/procedural API from the same enriched IR.
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

**Generation** emits per-language bindings with runtime support libraries and Swift helper dylibs. Each emitter reads the same enriched IR but produces output shaped to the target language's idioms and conventions. Currently produces Racket bindings for all 283 frameworks.

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
cargo run -p apianyware-macos-generate -- --lang racket
cargo run -p apianyware-macos-generate -- --list-languages    # show available emitters
```

Output goes to `generation/targets/{lang}/generated/{style}/`.

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
trait, `CodeWriter`, naming utils, snapshot testing, pattern dispatch),
`emit-racket/` (Racket emission), `cli/` (emitter registry,
orchestration).

**Tooling** -- `generation/crates/stub-launcher/`
(`apianyware-macos-stub-launcher`): generates per-app Swift stub binaries
for TCC-compatible `.app` bundles. Each stub `execv`s into the language
runtime, giving it a unique CDHash so macOS TCC grants permissions per-app
rather than per-runtime. See [App Bundling](#app-bundling) below.

**Swift dylibs** -- `swift/` contains `APIAnywareCommon` (C-callable ObjC
runtime: message sending, memory management, struct marshaling) and
per-language bridges (`APIAnywareRacket` adds block/delegate bridging with
GC prevention).

### Key Patterns

- **`effective_methods()`/`effective_properties()`** in emitters: choose
  between direct and inherited method lists, with deduplication by
  selector/name.
- **`DispatchStrategy`** in emit-racket: methods dispatch via either
  `tell` (Racket's ObjC FFI macro) or typed `_msg-N` bindings depending on
  parameter/return types.
- **`coerce-arg`** in Racket runtime: auto-converts strings -> NSString,
  objc-object -> _id pointer. All generated property setters use it.
- **Snapshot tests**: golden files at `emit-{lang}/tests/golden/{style}/`.
  `GoldenTest::assert_matches()` does directory comparison with unified
  diffs. `assert_subset_matches()` checks only files present in the golden
  dir.
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
(`stub-launcher`) plus a per-language convention crate
(`bundle-racket` for Racket).

#### Per-language convention: `apianyware-macos-bundle-racket`

For racket sample apps, use `apianyware-macos-bundle-racket`. It
walks the entry script's transitive `(require ...)` tree to discover
exactly which runtime modules and generated bindings are needed, and
copies that subset into the bundle's `Resources/` preserving the source
layout so the script's relative `../../runtime` and `../../generated/oo/...`
paths still resolve at runtime.

```sh
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window
# → generation/targets/racket/apps/hello-window/build/Hello Window.app
```

The `hello-window` argument is the script name (the `apps/<name>/<name>.rkt`
identifier). Display name (`Hello Window`) and bundle id
(`com.linkuistics.HelloWindow`) are derived from the kebab-case form. Full
API:

```rust
use apianyware_macos_bundle_racket::{bundle_app, AppSpec};

let spec = AppSpec::from_script_name("hello-window");
let source_root = Path::new("generation/targets/racket");
let output_dir = Path::new("generation/targets/racket/apps/hello-window/build");
let app_path = bundle_app(&spec, source_root, output_dir)?;
```

Resulting bundle layout (Resources mirrors the source tree so relative
requires keep working):

```
Hello Window.app/
  Contents/
    MacOS/Hello Window                <- Swift stub, execvs into racket
    Info.plist                        <- CFBundleName = "Hello Window"
    Resources/racket-app/
      apps/hello-window/hello-window.rkt
      runtime/*.rkt                   <- only files the entry transitively requires
      generated/oo/appkit/...         <- only the appkit classes hello-window requires
      lib/libAPIAnywareRacket.dylib   <- if present in the source tree
```

The walker only copies what the script actually requires — frameworks
the script doesn't import (CoreText, WebKit, etc.) stay out of the
bundle. Built bundles live under `apps/<name>/build/` and are
gitignored.

#### Language-agnostic primitive: `apianyware-macos-stub-launcher`

The lower-level crate handles the parts that are not Racket-specific:
generating the Swift launcher source, compiling it via `swiftc`,
producing `Info.plist`, and assembling the `.app` skeleton. New language
targets get their own bundle convention crate that wraps it.

```rust
use apianyware_macos_stub_launcher::{StubConfig, create_app_bundle};

let config = StubConfig {
    app_name: "Hello Window".into(),                       // Bundle and binary name
    runtime_path: "/opt/homebrew/bin/racket".into(),       // Baked in at compile time
    runtime_args: vec![],                                  // Extra args before script path
    script_resource_name: "main".into(),                   // Script filename (no ext)
    script_resource_type: "rkt".into(),                    // Script extension
    script_resource_dir: "racket-app".into(),              // Subdir in Resources/
    bundle_identifier: "com.example.HelloWindow".into(),   // CFBundleIdentifier
};
let app_path = create_app_bundle(&config, Path::new("output/"))?;
// Caller populates: output/Hello Window.app/Contents/Resources/racket-app/
// (Use bundle-racket to do this automatically for Racket apps.)
```

Lower-level API: `generate_stub_source()` and `compile_stub()` for custom
workflows, `generate_info_plist()` for standalone plist generation.

### GUI Testing with TestAnyware

Sample apps are tested in a macOS VM via `{{DEV_ROOT}}/TestAnyware/`
(the unified successor to Redraw and TestAnywareRedux). Never run GUI
apps directly from the CLI -- always use the VM for visual verification.
Two channels per VM:

- **Agent** (HTTP on port 8648): exec, file upload/download, accessibility
  snapshot/inspect, UI actions
- **VNC**: screenshots, OCR via `find-text`, keyboard/mouse input

Key workflow:

```bash
TA={{DEV_ROOT}}/TestAnyware
TA_BIN=$TA/cli/.build/release/testanyware

# Boot a fresh VM with a viewer attached. vm-start.sh runs as a normal
# subprocess (no `source` needed) and prints the VM id on stdout.
vmid=$($TA/provisioner/scripts/vm-start.sh --viewer)

# Drive the VM via --vm <id> (the CLI reads the per-VM spec written by
# vm-start.sh from $XDG_STATE_HOME/testanyware/vms/<id>.json), or via
# the explicit env vars $TESTANYWARE_AGENT / $TESTANYWARE_VNC.

# Install Racket once per fresh clone (~5 min cold)
$TA_BIN exec --vm "$vmid" "/opt/homebrew/bin/brew install minimal-racket"

# Build and ship a sample app as a .app bundle
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window
APP="generation/targets/racket/apps/hello-window/build/Hello Window.app"
tar -C "$(dirname "$APP")" -czf /tmp/app.tgz "$(basename "$APP")"
$TA_BIN upload --vm "$vmid" /tmp/app.tgz /Users/admin/app.tgz
$TA_BIN exec --vm "$vmid" "tar -xzf /Users/admin/app.tgz -C /Users/admin/ && open '/Users/admin/Hello Window.app'"

# Verify visually
$TA_BIN agent snapshot --vm "$vmid" --window "Hello Window"
$TA_BIN screenshot --vm "$vmid" -o /tmp/screen.png
$TA_BIN find-text --vm "$vmid" "Hello Window"

# Always kill before relaunch
$TA_BIN exec --vm "$vmid" "pkill -9 -f racket"

# Tear down
$TA/provisioner/scripts/vm-stop.sh "$vmid"
```

App specs at `knowledge/apps/{app}/spec.md`, validation checklists at
`knowledge/apps/{app}/test-strategy.md`. The bundling step is required
for menu-bar app names and per-app TCC permissions — running the script
directly via `racket hello-window.rkt` shows up as "racket" in the menu
bar.

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
      emit-racket/      # apianyware-macos-emit-racket    — Racket emitter
      cli/                 # apianyware-macos-generate          — generation CLI
      stub-launcher/       # apianyware-macos-stub-launcher     — Swift stub + Info.plist + .app skeleton (language-agnostic)
      bundle-racket/    # apianyware-macos-bundle-racket  — racket bundling: require walker + resource layout
    targets/
      racket/           # Racket: runtime, generated bindings, sample apps, tests

  swift/                   # Swift helper dylibs (C-callable ObjC runtime interface)
    Sources/
      APIAnywareCommon/    # shared: message send, memory mgmt, string conversion, struct marshal
      APIAnywareRacket/    # Racket-specific: GC prevention, block bridge, delegate bridge
      APIAnywareChez/      # stub
      APIAnywareGerbil/    # stub
```

### Target Languages

| Language | Style(s) | Status |
|---|---|---|
| Racket | OO (classes) | Emitter complete, 283 frameworks generated, 8/8 sample apps, snapshot tests, app bundling |
| Chez Scheme | Functional | Planned (Swift dylib stub exists) |
| Gerbil Scheme | OO + functional | Planned (Swift dylib stub exists) |
| Common Lisp (SBCL, CCL) | CLOS + functional | Planned |
| Haskell | Monadic + lens-based | Planned |
| Idris2 | Dependently-typed wrappers | Planned |
| OCaml | Modules + OO | Planned |
| Prolog / Mercury | Relational | Planned |
| Rhombus | OO (classes) | Planned |
| Pharo Smalltalk | Message-passing OO | Planned |
| Zig | Low-level procedural | Planned |

Languages with both OO and functional paradigms produce multiple binding styles from the same enriched IR -- for example, Common Lisp gets both CLOS wrappers and a `defun`-based procedural API.

## Documentation

- [Design Spec](docs/specs/2026-03-26-macos-workspace-design.md) -- full architecture and checkpoint format
- [Plan Restructure](docs/specs/2026-03-27-plan-restructure-design.md) -- language target milestone structure and template
- [Memory Architecture](analysis/docs/memory-architecture.md) -- ObjC/Swift ownership model, block/delegate lifecycles, GC prevention, verification rules
- [Annotation Workflow](analysis/docs/annotation-workflow.md) -- when and how to run each pipeline step, LLM annotation options, merge precedence
- [Enrichment Rules](analysis/docs/enrich-rules.md) -- what each Datalog-derived relation means and how emitters use it
- [API Pattern Catalog](analysis/docs/api-pattern-catalog.md) -- 10 stereotypical API patterns with detection rules and per-language translation templates
- [Emitter Contract](generation/docs/emitter-contract.md) -- cross-language conventions every target emitter must implement (e.g. OS_OBJECT_USE_OBJC handling)

## License

Apache License 2.0 -- see [LICENSE](LICENSE).
