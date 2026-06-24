# APIAnyware-MacOS Workspace Design

**Date:** 2026-03-26
**Status:** Implemented (Collection, Analysis, and Generation phases all working; Racket is the first completed emitter)
**Supersedes:** 2026-03-23-project-restructure-design.md (which covered a single monorepo approach)

> **Implementation note (2026-04-01):** The workspace structure described here is largely realized. Key divergences from the original plan: (1) Racket emitter was split into `emit-racket/` and `emit-racket-functional/` (separate crates per binding style, rather than one `emit-racket/` crate); (2) pattern-derived Datalog relations (`pattern_instance`, `pattern_participant`, `pattern_constraint`) were not materialized as flat tuples -- patterns are carried as structured JSON directly in the enriched checkpoint; (3) the `violation_unwrapped` verification rule was deferred to the emitter stage; (4) the Generation CLI uses `--lang racket` (not `--lang racket`) since each binding style is a separate emitter.

## Purpose

Define the structure, naming, and inter-phase contracts for `APIAnyware-MacOS` — a Rust workspace that extracts, analyzes, and generates idiomatic language bindings for macOS platform APIs. This is the first platform in a family that will eventually include `APIAnyware-Windows` and `APIAnyware-Linux`, each as independent repos with their own workspaces.

The generation phase targets a broad set of languages: Racket, Chez Scheme, Gerbil Scheme, Common Lisp (SBCL, CCL), Haskell, Idris2, OCaml, Prolog, Mercury, Rhombus, Pharo Smalltalk, Zig, and others. Each target produces bindings idiomatic to that language's conventions — not a lowest-common-denominator C wrapper. Languages with both OO and functional idioms may produce multiple binding styles from the same enriched IR.

## Principles

1. **Phases communicate via files.** Each phase reads checkpoint files from the previous phase and writes its own. No in-memory coupling between phases.
2. **Checkpoints are resumable.** Expensive steps (especially LLM annotation) are not re-run unless their inputs change. Each checkpoint is a complete, self-contained JSON file per framework.
3. **Collection is mechanical.** It uses existing parsers (libclang, swift-api-extract) and is easy to get 100% right. It runs once per SDK update.
4. **Analysis improves over time.** Datalog rules and LLM annotations evolve independently. The checkpoint model allows iterating on either without re-running the other.
5. **Generation is per-language and idiomatic.** Each target language gets its own emitter crate and runtime support library. Bindings are shaped to the target language's idioms — not a thin veneer over C. Languages with multiple paradigms (e.g., OO + functional) may produce multiple binding styles from the same enriched IR.
6. **Framework discovery is automatic.** Tools scan the SDK or checkpoint directories — no manual framework lists needed for normal operation.
7. **LLM provider is flexible.** The annotation schema is the contract. Annotations can come from Claude Code sessions, cloud APIs, local models, or manual editing.
8. **Rich provenance from collection.** Every declaration carries source location, SDK version, availability attributes, documentation references, and Apple doc URLs. Generation uses these to produce cross-referenced documentation.

---

## Repository & Naming

**GitHub repo / local directory:** `APIAnyware-MacOS`

**Naming conventions:**
- GitHub repos and development directories: PascalCase hyphen-separated (`APIAnyware-MacOS`)
- Rust crate names: lowercase hyphen-separated (`apianyware-macos-extract-objc`)
- CLI binary names: lowercase hyphen-separated (`apianyware-macos-collect`, `apianyware-macos-analyze`)
- File paths and identifiers: lowercase hyphen-separated

**Future sibling repos:** `APIAnyware-Windows`, `APIAnyware-Linux` — independent workspaces with platform-specific parsers, memory models, and type systems. No shared crate across platforms initially; common abstractions extracted later if warranted.

---

## Workspace Structure

```
APIAnyware-MacOS/
  Cargo.toml                              # workspace root

  # === Phase 1: Collection ===
  collection/
    crates/
      types/                              # apianyware-macos-types
      extract-objc/                       # apianyware-macos-extract-objc (libclang)
      extract-swift/                      # apianyware-macos-extract-swift (swift-api-digester)
      cli/                                # apianyware-macos-collect (binary)
    ir/collected/                         # output: {Framework}.json

  # === Phase 2: Analysis ===
  analysis/
    crates/
      datalog/                            # apianyware-macos-datalog (shared base relations, fact loaders, types)
      resolve/                            # apianyware-macos-resolve (Datalog pass 1, owns its ascent! program)
      annotate/                           # apianyware-macos-annotate (heuristics + merge)
      enrich/                             # apianyware-macos-enrich (Datalog pass 2, owns its ascent! program)
      cli/                                # apianyware-macos-analyze (binary)
    ir/resolved/                          # checkpoint
    ir/annotated/                         # checkpoint (LLM annotations checked in here)
    ir/enriched/                          # checkpoint (Generation reads this)
    scripts/
      llm-annotate.sh                     # provider-agnostic LLM annotation script
      prompt-template.md                  # shared prompt for all LLM providers
      config.example.toml                 # provider URL, model, API key env var
    docs/
      memory-architecture.md              # ObjC/Swift memory model (platform-specific)
      annotation-workflow.md              # how to run the pipeline
      enrich-rules.md                     # what each derived relation means

  # === Phase 3: Generation ===
  generation/
    crates/
      emit/                               # apianyware-macos-emit (shared emitter framework)
      emit-racket/                     # apianyware-macos-emit-racket (complete)
      emit-racket-functional/             # apianyware-macos-emit-racket-functional (stub)
      emit-chez/                          # planned
      emit-gerbil/                        # planned
      emit-cl/                            # Common Lisp (SBCL, CCL) — planned
      emit-haskell/                       # planned
      emit-idris2/                        # planned
      emit-ocaml/                         # planned
      emit-prolog/                        # Prolog + Mercury — planned
      emit-rhombus/                       # planned
      emit-smalltalk/                     # Pharo Smalltalk — planned
      emit-zig/                           # planned
      cli/                                # apianyware-macos-generate (binary)
    targets/
      {lang}/runtime/                     # per-language runtime support library
      {lang}/generated/                   # per-language emitter output

  # === Shared (cross-phase) ===
  swift/                                  # Swift helper dylibs (C-callable ObjC runtime)
    Package.swift
    Sources/APIAnywareCommon/             # shared across all target languages
    Sources/APIAnyware{Lang}/             # per-language if needed
    Tests/

  # === Development infrastructure ===
  .claude/commands/                       # Claude Code commands for LLM analysis
    analyze.md                            # /analyze — annotate all frameworks
  LLM_STATE/                              # plan files for Claude Code sessions
```

The Ravel-Lite runner (peer project at `{{DEV_ROOT}}/Ravel-Lite/`) drives
the multi-phase work cycle and supplies the universal coding-style and
phase-prompt material that LLM_STATE plans reference.

---

## Shared Types Crate

`collection/crates/types/` (`apianyware-macos-types`) defines:

- **IR structs** — `Framework`, `Class`, `Method`, `Property`, `Protocol`, `Enum`, `Struct`, `Function`, `Constant`, `TypeRef`
- **Provenance** — `SourceProvenance` (header path, line, SDK version, availability)
- **Documentation references** — `DocRefs` (header comment, Apple doc URL, USR/symbol ID)
- **Annotation schema** — `MethodAnnotation`, `BlockInvocationStyle`, `OwnershipKind`, `ThreadingConstraint`, `ErrorPattern`, `AnnotationSource`
- **Checkpoint format** — serde `Serialize`/`Deserialize` for all types, JSON as the wire format
- **Null-safe deserialization** — handles Go-style `null` arrays from legacy IR

This crate has no dependencies beyond `serde` and `serde_json`. All other crates in the workspace depend on it.

---

## Phase 1: Collection

### ObjC/C Extraction (`extract` crate)

Uses the `clang` Rust crate (safe wrapper around libclang) to parse ObjC headers from the macOS SDK.

**Process:**
1. Discover SDK path via `xcrun --show-sdk-path`
2. Scan `{SDK}/System/Library/Frameworks/` for available frameworks
3. For each framework, locate the umbrella header (e.g., `Foundation/Foundation.h`)
4. Parse with libclang: `-x objective-c`, SDK include paths, deployment target flags
5. Walk the AST extracting declarations
6. Capture provenance: source file, line number, SDK version, availability attributes
7. Capture doc refs: header doc comments, compute Apple doc URL from USR
8. Write `ir/collected/{Framework}.json`

**What libclang provides:**
- Full AST with type information
- Nullability annotations (`_Nullable`, `_Nonnull`) from headers
- Availability attributes (`API_AVAILABLE`, `NS_DEPRECATED`)
- Documentation comments from headers
- USR (Unified Symbol Resolution) — stable symbol identifier
- Block parameter types fully resolved (no typedef aliasing problem)

### Swift Extraction (`extract-swift` crate)

Uses `swift-api-digester -dump-sdk` (ships with Xcode toolchain) to extract Swift API metadata as JSON.

**Process:**
1. Locate via `xcrun --find swift-api-digester`
2. For each framework with `.swiftmodule`, invoke `xcrun swift-api-digester -dump-sdk -module {Framework} -sdk $(xcrun --show-sdk-path) -o {output}.json`
3. Parse the `ABIRoot` JSON tree into IR types
4. Tag each declaration with `source: "swift_interface"`
5. Merge with ObjC declarations for the same framework (Swift extensions on ObjC classes)
6. Capture availability and doc comments from the Swift interface

**Output merging:** A single `ir/collected/{Framework}.json` per framework contains declarations from both ObjC headers and Swift interfaces. Each declaration carries a `source` field (`"objc_header"` or `"swift_interface"`) so downstream phases know which bridging pattern applies.

### CLI (`apianyware-macos-collect`)

```
apianyware-macos-collect                    # discover and extract all SDK frameworks
apianyware-macos-collect --only Foundation   # extract specific framework(s)
apianyware-macos-collect --list              # list available frameworks
```

---

## Phase 2: Analysis

### Resolve (`resolve` crate) — Datalog Pass 1

Reads `collection/ir/collected/` and computes derived relations via Datalog (ascent crate).

**Derived relations:**
- `ancestor(class, ancestor_class)` — transitive inheritance
- `effective_method(class, selector, ...)` — inheritance-flattened methods with override detection
- `effective_property(class, prop_name, ...)` — inheritance-flattened properties
- `returns_retained_method(class, selector, is_class_method)` — ownership family detection
- `satisfies_protocol_method(class, selector, protocol)` — protocol conformance

**Process:**
1. Discover all `*.json` in `collection/ir/collected/`
2. Load all frameworks (cross-framework dependencies resolved by loading all)
3. Run the ascent Datalog program
4. Write `analysis/ir/resolved/{Framework}.json` — collected data + derived relations

### Annotate (`annotate` crate) — Heuristics + LLM Merge

Reads `analysis/ir/resolved/` and adds semantic annotations.

**Heuristic classification (Rust, deterministic):**
- Block invocation style from selector naming (`enumerate` → sync, `completion` → async, `observer` → stored)
- Parameter ownership from naming (`delegate`/`dataSource` → weak)
- Threading from class identity (AppKit UI classes → main thread only)
- Error pattern from parameter signature (last param named `error` with pointer type → error_out_param)

**LLM annotation merge:**
- Reads existing `analysis/ir/annotated/{Framework}.json` if present
- Methods with `source: "llm"` or `source: "human_reviewed"` are preserved (LLM takes precedence)
- Methods without LLM annotations get heuristic-only annotations
- The LLM analysis is a separate step (Claude Code session, script, or manual) that writes to the same file

**Process:**
1. Discover all `*.json` in `analysis/ir/resolved/`
2. For each framework, run heuristics on all methods
3. Merge with existing LLM annotations (if the annotated checkpoint exists)
4. Write `analysis/ir/annotated/{Framework}.json`

### LLM Annotation (External Process)

Not part of the Rust codebase. The LLM reads resolved IR + Apple documentation and produces annotation JSON matching the schema.

**Invocation paths:**
- **Claude Code:** `/analyze` command discovers frameworks needing annotation and processes them
- **Script:** `analysis/scripts/llm-annotate.sh` calls any OpenAI-compatible API (Anthropic, OpenAI, Ollama, etc.)
- **Manual:** Edit `analysis/ir/annotated/{Framework}.json` directly

All paths produce the same schema. The `annotate` crate's merge step integrates LLM output with heuristics regardless of how the LLM annotations were produced.

**The prompt template** (`analysis/scripts/prompt-template.md`) is the reusable asset. It describes the annotation schema, the method signature format, and what to look for in Apple documentation.

### API Pattern Recognition

Many macOS APIs implement stereotypical multi-method behavioral contracts. Individual method annotations (ownership, threading, block style) are necessary but not sufficient — emitters also need to know which methods work together as a group, what ordering/lifecycle constraints govern them, and what idiomatic construct the group maps to in each target language.

**Pattern stereotypes** (discovered via research; see Milestone 5.5 in plan):

| Stereotype | Shape | macOS examples | Idiomatic target |
|---|---|---|---|
| **Resource lifecycle** | open → use* → close | `CGPathCreateMutable` → add* → release; `CGContextBeginPath` → draw* → `StrokePath` | `with-path`, `withContext`, RAII guard |
| **Builder sequence** | create → configure* → build | `NSMutableURLRequest` setters → copy to `NSURLRequest` | builder DSL, `let`-chain |
| **Observer pair** | register → (callback)* → unregister | `addObserver:` / `removeObserver:`; KVO | scoped observer, bracket pattern |
| **Transaction bracket** | begin → mutate* → commit/rollback | `CATransaction.begin()` / `.commit()` | `with-transaction`, `atomically` |
| **Enumeration** | container → iterate → element* | `NSFastEnumeration`, `enumerateObjectsUsingBlock:` | `for`/`map`/`fold`, lazy sequence |
| **Error-out** | call → check error param → handle | `...error:(NSError **)` pattern | `Result`, `Either`, exception, condition |
| **Delegate protocol** | setDelegate → (callbacks)* | `NSWindowDelegate`, `UITableViewDataSource` | trait impl, protocol extension, mixin |
| **Target-action** | setTarget + setAction + (trigger)* | `NSControl` / `NSMenuItem` | event handler, signal/slot |
| **Paired state** | enable/disable, lock/unlock, show/hide | `NSLock.lock()` / `.unlock()` | `with-lock`, scoped guard |
| **Factory cluster** | abstract class → concrete subclass selection | `NSNumber numberWithInt:`, `NSString stringWith*:` | smart constructor, `from`/`into` |

**How patterns are discovered:**

1. **Heuristic detection** (Rust, deterministic): Selector naming conventions and type signatures catch many instances — `begin`/`end` pairs, `add`/`remove` observer pairs, `create`/`release` lifecycles, mutable/immutable class pairs.

2. **LLM analysis of documentation** (primary source): The LLM reads not only API reference documentation but also **Apple's programming guides and tutorials** (e.g., "Quartz 2D Programming Guide", "Cocoa Drawing Guide", "Key-Value Observing Programming Guide"). Guides describe usage patterns explicitly — they show the sequence of calls, the constraints, and the intended lifecycle. This is information that cannot be derived from headers alone.

3. **Pattern catalog** (`analysis/docs/api-pattern-catalog.md`): A curated, versioned catalog of known stereotypes with their detection rules and per-language translation templates. LLM analysis proposes new instances; human review promotes them to the catalog. The catalog is the contract between analysis and generation.

**Pattern representation in the IR:**

Patterns are stored in the annotated checkpoint alongside per-method annotations:

```json
{
  "api_patterns": [
    {
      "stereotype": "resource_lifecycle",
      "name": "CGPath construction",
      "participants": {
        "open": { "function": "CGPathCreateMutable" },
        "operations": [
          { "function": "CGPathMoveToPoint" },
          { "function": "CGPathAddLineToPoint" },
          { "function": "CGPathAddArc" },
          { "function": "CGPathCloseSubpath" }
        ],
        "close": { "function": "CGPathRelease" }
      },
      "constraints": {
        "ordering": "open must precede operations; close must follow all operations",
        "thread_safety": "not thread-safe; all calls must be on same thread",
        "ownership": "caller owns from open to close"
      },
      "source": "llm",
      "doc_ref": "Quartz 2D Programming Guide > Paths"
    }
  ]
}
```

**How emitters use patterns:**

Each emitter maps stereotypes to language-idiomatic constructs. The shared `emit` crate provides the stereotype → translation-template dispatch; per-language emitters supply the templates:

- **Resource lifecycle** → `with-path` (Scheme/Lisp), `withCGPath` (Haskell bracket), RAII guard (Zig), `ensure` block (Smalltalk)
- **Builder sequence** → builder DSL with method chaining or `let`-pipeline
- **Observer pair** → scoped observer that auto-unregisters, or bracket pattern
- **Transaction bracket** → `with-transaction` / `atomically` / scoped commit
- **Error-out** → `Result`/`Either` (Haskell/OCaml/Zig), conditions (CL), `exn` (Racket)

### Enrich (`enrich` crate) — Datalog Pass 2

Reads `analysis/ir/annotated/` and runs Datalog with annotation facts to produce generation-facing derived relations.

**Annotation-derived relations:**
- `sync_block_method(class, selector, param_index)` — synchronous block API, needs explicit free
- `async_block_method(class, selector, param_index)` — async block, auto-managed
- `stored_block_method(class, selector, param_index)` — stored block (observers, timers)
- `delegate_protocol(protocol)` — protocol suitable for typed delegate builder
- `convenience_error_method(class, selector)` — method with NSError** that can get a result-or-error wrapper
- `collection_iterable(class)` — class with count + objectAtIndex: or NSFastEnumeration
- `scoped_resource(class, open_selector, close_selector)` — begin/end or open/close pairs for `with-` forms
- `main_thread_class(class)` — all methods on this class must be called from main thread

**Pattern-derived relations** (from API pattern annotations):
- `pattern_instance(stereotype, pattern_name, framework)` — a recognized API usage pattern
- `pattern_participant(pattern_name, role, class_or_function, selector)` — method/function participating in a pattern
- `pattern_constraint(pattern_name, constraint_kind, description)` — ordering, threading, or ownership constraints on a pattern

These relations enable emitters to query "give me all resource-lifecycle patterns in CoreGraphics" and generate `with-*` forms, bracket patterns, or RAII guards as appropriate for the target language.

**Verification rules (violations = CI failure):**
- `violation_unwrapped(class, selector)` — id-returning method not wrapped
- `violation_flag_mismatch(class, selector)` — retained flag doesn't match ownership family
- `violation_unclassified_block(class, selector, param_index)` — block param without sync/async classification

**Fact loading:** The enrichment Datalog program loads facts from **two sources**: (1) type-level facts from the annotated checkpoint (which carries forward resolved data — classes, methods, inheritance), and (2) annotation facts (block classifications, ownership, threading, error patterns). Both are in the same `ir/annotated/{Framework}.json` file since each checkpoint is a superset of previous phases.

**`datalog` crate role:** The `datalog` crate is a library that defines shared base relation types, fact-loading utilities, and helper functions used by both `resolve` and `enrich`. Each of `resolve` and `enrich` defines its own `ascent!` program with its own rules, using the `datalog` crate's types for fact representation.

**Process:**
1. Discover all `*.json` in `analysis/ir/annotated/`
2. Load type facts + annotation facts into the enrichment ascent program
3. Run enrichment rules → derived relations
4. Run verification rules → violation report
5. Write `analysis/ir/enriched/{Framework}.json` — fully enriched, ready for Generation
6. Write `analysis/ir/enriched/{Framework}.verification.json` — violation details (if any)

---

## Phase 3: Generation

**Status:** The Racket emitter is complete and generates bindings for all 283 frameworks. The shared emitter framework, Swift helper dylibs, and generation CLI are working. Other emitters are planned.

**Core principle: idiomatic, not mechanical.** Each emitter produces bindings shaped to its target language's conventions. A Haskell emitter produces monadic APIs with lens-based property access. A Smalltalk emitter produces message-passing objects. A Zig emitter produces explicit allocation with errdefer patterns. The enriched IR carries enough semantic information for emitters to make these decisions automatically.

**Multiple binding styles.** Languages with both OO and functional idioms can produce multiple APIs from the same IR. For example, Common Lisp gets both CLOS class wrappers and a `defun`-based procedural API; OCaml gets both a module-based functional API and an OO API using OCaml's object system. Each style is a separate emitter output, not a compromise between the two.

**Architecture:**
- Reads `analysis/ir/enriched/{Framework}.json`
- Shared emitter framework (`emit` crate) provides common utilities: name mapping, type resolution, documentation rendering, framework dependency ordering, snapshot testing, pattern dispatch
- Per-language emitter crates (`emit-racket`, `emit-racket-functional`, etc.) implement language-specific code generation
- Each emitter uses enrichment relations (ownership, threading, block lifecycle, error patterns) and API pattern instances to decide wrapping strategies
- API pattern stereotypes drive high-level idiomatic constructs: resource lifecycles -> `with-*` / bracket / RAII; builder sequences -> DSLs or `let`-chains; observer pairs -> scoped auto-unregister; transaction brackets -> `atomically` / `with-transaction`
- Runtime support libraries (per-language) provide ObjC object lifecycle management, block/delegate bridging, memory safety guarantees appropriate to the target language
- Swift helper dylibs provide the C-callable ObjC runtime interface shared across all target languages
- Generated documentation cross-references Apple docs using `doc_refs` from collected IR

**Target languages:**

| Language | Binding style(s) | Notes |
|---|---|---|
| Racket | OO (classes) | Complete: emitter, runtime, 283 frameworks, sample apps, tests |
| Racket | Functional | Stub emitter registered |
| Chez Scheme | Functional | Planned (Swift dylib stub exists) |
| Gerbil Scheme | OO + functional | Planned (Swift dylib stub exists) |
| Common Lisp (SBCL, CCL) | CLOS + functional | Two implementations, one emitter |
| Haskell | Monadic + lens-based | |
| Idris2 | Dependently-typed wrappers | |
| OCaml | Modules + OO | |
| Prolog / Mercury | Relational | |
| Rhombus | OO (classes) | |
| Pharo Smalltalk | Message-passing OO | |
| Zig | Low-level procedural | |

---

## Checkpoint File Format

### Collected (`collection/ir/collected/{Framework}.json`)

```json
{
  "format_version": "1.0",
  "checkpoint": "collected",
  "name": "Foundation",
  "sdk_version": "15.4",
  "collected_at": "2026-03-26T10:00:00Z",
  "classes": [
    {
      "name": "NSString",
      "superclass": "NSObject",
      "protocols": ["NSCopying", "NSSecureCoding"],
      "properties": [...],
      "methods": [
        {
          "selector": "initWithString:",
          "class_method": false,
          "init_method": true,
          "params": [
            {
              "name": "aString",
              "type": { "kind": "id", "nullable": false }
            }
          ],
          "return_type": { "kind": "instancetype" },
          "deprecated": false,
          "variadic": false,
          "source": "objc_header",
          "provenance": {
            "header": "Foundation/NSString.h",
            "line": 142,
            "availability": {
              "introduced": "10.0",
              "deprecated": null
            }
          },
          "doc_refs": {
            "header_comment": "Returns an NSString object initialized by copying the characters from another given string.",
            "apple_doc_url": "https://developer.apple.com/documentation/foundation/nsstring/1497402-initwithstring",
            "usr": "c:objc(cs)NSString(im)initWithString:"
          }
        }
      ]
    }
  ],
  "protocols": [...],
  "enums": [...],
  "structs": [...],
  "functions": [...],
  "constants": [...],
  "category_methods": [...]
}
```

**Checkpoint composition:** Each successive checkpoint is a **superset** — it carries forward all fields from the previous phase and adds new ones. The enriched checkpoint contains everything from collected + resolved + annotated + enrichment-derived relations. Each checkpoint is self-contained and can be consumed without reading earlier checkpoints.

### Resolved (`analysis/ir/resolved/{Framework}.json`)

Adds to the collected format (all collected fields are preserved):
```json
{
  "format_version": "1.0",
  "checkpoint": "resolved",
  "classes": [
    {
      "name": "NSMutableString",
      "ancestors": ["NSString", "NSObject"],
      "effective_methods": [...],
      "effective_properties": [...],
      "returns_retained_selectors": ["init", "initWithString:", "copy", "mutableCopy"]
    }
  ]
}
```

### Annotated (`analysis/ir/annotated/{Framework}.json`)

Adds to the resolved format:
```json
{
  "format_version": "1.0",
  "checkpoint": "annotated",
  "classes": [
    {
      "name": "NSArray",
      "methods": [
        {
          "selector": "enumerateObjectsUsingBlock:",
          "annotations": {
            "block_parameters": [
              { "param_index": 0, "invocation": "synchronous" }
            ],
            "parameter_ownership": [
              { "param_index": 0, "ownership": "copy" }
            ],
            "source": "llm"
          }
        }
      ]
    }
  ]
}
```

### Enriched (`analysis/ir/enriched/{Framework}.json`)

Adds to the annotated format:
```json
{
  "format_version": "1.0",
  "checkpoint": "enriched",
  "enrichment": {
    "sync_block_methods": [
      { "class": "NSArray", "selector": "enumerateObjectsUsingBlock:", "param_index": 0 }
    ],
    "delegate_protocols": ["NSWindowDelegate", "NSTableViewDelegate"],
    "convenience_error_methods": [
      { "class": "NSFileManager", "selector": "contentsOfDirectoryAtPath:error:" }
    ],
    "main_thread_classes": ["NSView", "NSWindow", "NSApplication"],
    "collection_iterables": ["NSArray", "NSSet", "NSOrderedSet"],
    "api_patterns": [
      {
        "stereotype": "resource_lifecycle",
        "name": "CGPath construction",
        "participants": {
          "open": { "function": "CGPathCreateMutable" },
          "operations": ["CGPathMoveToPoint", "CGPathAddLineToPoint", "CGPathAddArc", "CGPathCloseSubpath"],
          "close": { "function": "CGPathRelease" }
        },
        "constraints": ["open-before-use", "close-after-use", "single-thread"]
      },
      {
        "stereotype": "observer_pair",
        "name": "NSNotificationCenter observation",
        "participants": {
          "register": { "class": "NSNotificationCenter", "selector": "addObserver:selector:name:object:" },
          "unregister": { "class": "NSNotificationCenter", "selector": "removeObserver:" }
        },
        "constraints": ["must-unregister-before-dealloc"]
      }
    ]
  },
  "verification": {
    "passed": true,
    "violations": []
  }
}
```

---

## CLI Summary

### Collection
```
apianyware-macos-collect                      # extract all SDK frameworks
apianyware-macos-collect --only Foundation     # extract specific framework(s)
apianyware-macos-collect --list                # list available frameworks
```

### Analysis
```
apianyware-macos-analyze                      # run full pipeline: resolve → annotate → enrich
apianyware-macos-analyze resolve              # just Datalog pass 1
apianyware-macos-analyze annotate             # just heuristics + LLM merge
apianyware-macos-analyze enrich               # just Datalog pass 2 + verification
apianyware-macos-analyze --only Foundation     # process specific framework(s)
```

### Generation
```
apianyware-macos-generate                     # generate all languages, all frameworks
apianyware-macos-generate --lang racket       # generate specific language
apianyware-macos-generate --lang cl --style oo       # CLOS bindings
apianyware-macos-generate --lang cl --style functional  # defun-based bindings
apianyware-macos-generate --only Foundation    # generate specific framework(s)
apianyware-macos-generate --list-langs         # list available target languages
```

### Claude Code
```
/analyze                                      # LLM-annotate all frameworks needing analysis
```

---

## Migration from POC

The current `APIAnyware` project is a proof-of-concept. Code harvested into the new workspace:

| POC location | New location | Changes |
|---|---|---|
| `crates/core/src/ir.rs` | `collection/crates/types/` | Add provenance + doc_refs fields |
| `crates/core/src/datalog.rs` | `analysis/crates/datalog/` | Split into resolution + enrichment programs |
| `crates/core/src/verification.rs` | `analysis/crates/enrich/` | Integrate into enrichment pass |
| `crates/annotate/src/schema.rs` | `collection/crates/types/` | Merge into shared types |
| `crates/annotate/src/heuristics.rs` | `analysis/crates/annotate/` | Reuse as-is |
| `crates/annotate/src/validate.rs` | `analysis/crates/annotate/` | Reuse as-is |
| `crates/annotate/src/fact_loader.rs` | `analysis/crates/enrich/` | Adapt for enrichment input |
| `crates/emit/` | `generation/crates/emit/` | Move as-is |
| `crates/emit-racket/` | `generation/crates/emit-racket/` | Update to read enriched checkpoint |
| `swift/Sources/` | `swift/Sources/` | Move as-is |
| `targets/racket/runtime/` | `generation/targets/racket/runtime/` | Move as-is |
| `docs/memory-architecture.md` | `analysis/docs/memory-architecture.md` | Move as-is |
| `docs/memory-racket.md` | `generation/docs/memory-racket.md` | Move to generation |
| `.claude/commands/analyze-framework.md` | `.claude/commands/analyze.md` | Adapt for auto-discovery |
| `ir/annotations/*.json` | `analysis/ir/annotated/` | Existing LLM annotations preserved |
| `ir/level0/*.json` | Reference only | Replaced by Rust collection output |
| `ir/level1/*.json` | Reference only | Replaced by resolve step output |
| `go/` | Not migrated | Replaced by Rust collection crates |
| `crates/core/src/datalog.rs` `AnnotationFact` | `analysis/crates/datalog/` | Shared fact types used by annotate + enrich |
| `crates/core/tests/datalog_*.rs` | `analysis/crates/resolve/tests/` | Datalog rule validation tests |
| `crates/core/tests/deserialize_ir.rs` | `collection/crates/types/tests/` | IR deserialization tests |
| `crates/emit-racket/tests/` | `generation/crates/emit-racket/tests/` | Emitter regression tests |
| `docs/swift-api-bridging-pattern.md` | `swift/docs/` | Swift C-bridge pattern documentation |
| `.claude/commands/analyze-all-frameworks.md` | Replaced by `/analyze` | Auto-discovery replaces per-framework commands |

---

## Dependencies

### Collection
- `clang` crate (libclang Rust wrapper) — ObjC/C header parsing
- `serde`, `serde_json` — IR serialization
- Xcode (provides libclang and swift-api-digester)

### Analysis
- `ascent` — Datalog engine
- `serde`, `serde_json` — checkpoint I/O
- `clap` — CLI argument parsing
- `tracing` — structured logging

### Generation
- `serde`, `serde_json` — enriched checkpoint I/O
- `clap`, `tracing`
- No heavy dependencies (no reqwest, no tokio)

### Swift helpers
- Swift 6.0+ toolchain
- `@_cdecl` for C-callable exports
- macOS 14+ (for Swift runtime libraries)

---

## What This Design Does Not Cover

- **Windows platform** — separate repo (`APIAnyware-Windows`), COM/WinRT/.NET GC memory model, Roslyn-based collection
- **Linux platform** — separate repo (`APIAnyware-Linux`), GObject/GLib memory model, GIR-based collection
- **Cross-platform shared types** — deferred until a second platform is built and common patterns emerge
- **Bazel build system** — not needed for analysis (pure Rust + scripts); may return for generation phase if multi-toolchain builds are needed
- **Homebrew distribution** — deferred to generation phase completion
