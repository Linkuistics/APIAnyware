# APIAnyware Refactor Final Architecture

**Purpose:** This document captures the final agreed architecture for refactoring the current `~/Development/APIAnyware-MacOS` project into a platform-neutral `APIAnyware` project.

**Intended consumer:** Claude Code or another coding agent working in `~/Development/APIAnyware-MacOS`.

**Primary instruction:** Rename the project from `APIAnyware-MacOS` to `APIAnyware`, then refactor its structure and documentation according to the architecture below.

---

## 1. Project rename

The current project name is too macOS-specific.

Rename:

```text
~/Development/APIAnyware-MacOS
```

to:

```text
~/Development/APIAnyware
```

The project should support multiple source platforms, including at least:

```text
macOS
Linux
.NET
```

macOS remains the first and most developed source platform, but the repository structure must not assume that macOS is the only platform.

---

## 2. Philosophy

APIAnyware is an ideological and architectural project, not merely a practical binding generator.

The project is based on the belief that platform APIs encode rich semantic protocols that are usually flattened into low-level FFI surfaces. These protocols include ownership, lifetimes, memory management, threading, callbacks, delegates, bracketing, builders, state transitions, app lifecycle, UI constraints, error channels, and resource discipline.

The goal is to model those protocols explicitly, then expose them in many target languages according to each language's own paradigms.

The project should respect the character of each target language. It should not force every language into a Rust-shaped, C-shaped, Swift-shaped, or C#-shaped binding model.

Different languages should express the same source API semantics differently:

```text
Rust        -> ownership, lifetimes, Drop, Result, typestate where possible
Common Lisp -> CLOS wrappers, WITH-* macros, conditions, dynamic checks
Scheme      -> dynamic-wind, custodians where available, records, explicit closure
Python      -> objects, context managers, exceptions
Haskell     -> bracket, ForeignPtr, phantom types, IO, Either/exceptions
Elixir      -> processes, NIF resources, ports, supervision where appropriate
Java        -> objects, AutoCloseable, exceptions, listeners
Zig         -> explicit allocators, error unions, defer, comptime where useful
```

The system should not aim for the lowest common denominator. It should aim for semantic preservation, documented representability, and idiomatic projection.

---

## 3. Core thesis

APIAnyware is not merely an FFI generator.

It is a semantic interop system that models source platform APIs as target-independent semantic graphs, then projects those semantics into target-language-specific adapter libraries, bindings, examples, tests, and documentation.

The central claim is:

> APIAnyware exposes platform APIs to non-native languages by generating target-specific semantic adapter libraries plus idiomatic target bindings, driven by a target-independent API model and verified by target-independent application specifications and behavioural tests.

The system should distinguish:

```text
Discovery is probabilistic.
Specification is reviewable.
Interchange is formal.
Generation is deterministic.
Testing is behavioural.
```

---

## 4. Goals

APIAnyware should provide:

1. A target-independent semantic model of source platform APIs.

2. A formal, human-editable specification format for source API semantics.

3. A canonical interchange format, likely YAML, produced from a human-friendly DSL.

4. First-class multi-API semantic patterns, such as bracket, builder, observer, delegate, callback, subscription, typestate, buffer-fill, and error-side-channel.

5. A mechanism for LLM-assisted documentation analysis that generates semantic annotations in a side channel.

6. A workflow where LLM-derived facts are cached, reviewable, regenerable, and manually editable.

7. Target language / implementation capability profiles.

8. Target-language idiom catalogues.

9. Per-platform, per-target native adapter libraries, such as:

```text
macos.gerbil.dylib
macos.sbcl.dylib
macos.racket.dylib
linux.gerbil.so
dotnet.python.dylib
```

10. Target-language bindings that call the adapter library, call the platform directly where appropriate, or use a mix of both.

11. A representability model describing whether a source semantic feature is exact-static, exact-runtime, conventional, lossy, unsafe-only, not representable, or still research.

12. Common, target-independent application specifications.

13. Behavioural test scripts, ideally using `~/Development/TestAnyware`.

14. Target-independent application specifications, ideally using `~/Development/AppSpec`.

15. Comprehensive test coverage at semantic, adapter, binding, app, GUI, packaging, lifecycle, and conformance levels.

16. Sample applications across the range of app types one can write on each source platform.

17. Documentation that helps users map what they see in platform API docs to what they see in a target language binding.

---

## 5. Non-goals

APIAnyware should not attempt to:

1. Reconstruct every source platform abstraction perfectly in every target language.

2. Remap every generic API into every target language. This is impossible for many combinations, especially with Swift generics, .NET generics, JVM generics, C++ templates, and target languages without corresponding abstraction mechanisms.

3. Hide all semantic mismatch. Some features will be exact, some runtime-only, some conventional, some unsafe, and some unsupported.

4. Treat headers as sufficient. Headers are necessary but not sufficient.

5. Treat LLM analysis as truth. LLM output is proposed semantic annotation, not authoritative fact.

6. Force all languages into a single binding style.

7. Prefer direct FFI everywhere. Direct calling is an optimisation, not the semantic model.

8. Put projection information into source platform API specifications.

9. Put target-language-specific information into common app specifications.

10. Maintain one central documentation tree detached from the entities being documented.

---

## 6. Constraints

The architecture is shaped by these constraints:

1. Source platform APIs are semantically rich and often under-specified by headers alone.

2. Documentation, naming conventions, examples, runtime metadata, and human review are required to recover API semantics.

3. Target languages vary dramatically in expressiveness, runtime model, FFI maturity, memory model, callback support, packaging model, and app/plugin viability.

4. Some targets need native adapter libraries because their FFI cannot conveniently or safely express the source platform directly.

5. Some targets can call directly into platform APIs for simple cases, but still need adapters for callbacks, threading, errors, object identity, delegates, autorelease pools, generic erasure, and app lifecycle.

6. Some source platform app forms impose host-process, bundle, signing, threading, sandboxing, or plugin-loading constraints that may be impossible or impractical for some target runtimes.

7. The project must be testable by behaviour, not merely by generation success.

8. Common app specs must remain target-independent.

9. Documentation must be isolated with the subject it documents.

10. The repository structure must support multiple platforms and many target language implementations without macOS-specific assumptions.

---

## 7. Design principles

Use these principles to guide the refactor.

### 7.1 Source semantics are projection-independent

The source API spec says what the platform API means.

It does not say how Rust, Gerbil, SBCL, Python, Haskell, Java, or any other target should expose it.

### 7.2 Projection lives in targets

Target capability profiles, idiom catalogues, policies, adapters, bindings, conformance reports, and target documentation live under `targets/<target>/`.

### 7.3 App specs are common

Common AppSpec definitions live under `apps/<platform>/<app>/`.

Target implementations of those apps live under `targets/<target>/app-implementations/<platform>/<app>/`.

### 7.4 Documentation lives with its subject

There should be no large top-level `docs/` directory.

Docs must live beside the thing they document.

### 7.5 Patterns are first-class

Multi-API patterns are semantic entities. They are not generator flags.

Examples:

```text
bracket
builder
observer
delegate
callback
subscription
typestate
buffer-fill
two-call-sizing
error-side-channel
refcounted
parent-child ownership
collection-element ownership
```

### 7.6 Direct calling is an optimisation

The canonical implementation model includes per-platform, per-target native adapter libraries.

Direct target-language calls into the platform are allowed only when they are safe and useful.

### 7.7 Representability must be explicit

Every target/platform combination should be able to report what is:

```text
fully represented
runtime represented
conventionally represented
lossily represented
unsafe-only
unsupported
research
```

### 7.8 Generated apps are tests, not demos

Sample apps are behavioural conformance tests. They prove that a binding is usable, not just callable.

---

## 8. Fundamental repository domains

The system has five primary domains:

```text
semantic/
  shared language of meaning

platforms/
  source platform truth

apps/
  common target-independent behavioural exemplars

targets/
  target-language expression and proof

schemas/
  formal validation
```

These boundaries are important and should be preserved throughout the refactor.

---

## 9. Top-level repository structure

Use this as the target high-level structure:

```text
APIAnyware/
  README.md

  semantic/
    docs/
    pattern-kinds/

  platforms/
    macos/
    linux/
    dotnet/

  apps/
    macos/
    linux/
    dotnet/

  targets/
    gerbil/
    sbcl/
    racket/
    python/
    rust/
    zig/
    haskell/
    ocaml/
    java/
    scala3/
    clojure/
    elixir/
    ruby/
    nim/
    odin/
    factor/
    bqn/
    prolog/
    mercury/
    idris2/

  schemas/
    docs/
```

Not all targets need to be fully implemented immediately. The structure should allow them to be added incrementally.

---

## 10. Documentation placement rule

There should be no large top-level `docs/` directory.

Documentation must live beside the thing it documents.

The only top-level documentation should be a small root `README.md` that acts as a repository map.

Use this rule:

```text
Documentation lives with its subject.
```

Therefore:

```text
semantic docs       -> semantic/docs/
platform docs       -> platforms/<platform>/docs/
platform API docs   -> platforms/<platform>/api/<api-family>/docs/
app kind docs       -> platforms/<platform>/app-kinds/<kind>/docs/
common app docs     -> apps/<platform>/<app>/docs/
target docs         -> targets/<target>/docs/
target idiom docs   -> targets/<target>/idioms/docs/
policy docs         -> targets/<target>/policies/<platform>/docs/
adapter docs        -> targets/<target>/adapters/<platform>/docs/
binding docs        -> targets/<target>/bindings/<platform>/docs/
implementation docs -> targets/<target>/app-implementations/<platform>/<app>/docs/
schema docs         -> schemas/docs/
```

Do not centralise substantive design documentation at the root.

---

## 11. Root README responsibility

The root `README.md` should be an index only.

It should explain:

```text
What APIAnyware is
Where platform specs live
Where target specs live
Where app specs live
Where schemas live
How to run validation
How to run generation
How to run tests
```

It should link to local documentation such as:

```text
semantic/docs/overview.md
platforms/macos/docs/overview.md
targets/gerbil/docs/overview.md
apps/macos/gui-counter/docs/overview.md
schemas/docs/schema-overview.md
```

It should not contain detailed platform, target, or adapter documentation.

---

## 12. Semantic model

The `semantic/` directory contains universal, target-independent vocabulary.

It defines concepts such as:

```text
resource
ownership
lifetime
borrow
shared reference
weak reference
capability
thread context
execution context
effect
failure mode
callback
subscription
delegate
buffer
typestate
protocol transition
semantic pattern
```

Suggested structure:

```text
semantic/
  docs/
    overview.md
    pattern-model.md
    resource-semantics.md
    ownership.md
    lifetimes.md
    threading.md
    callbacks.md
    typestate.md

  pattern-kinds/
    bracket.apiw
    callback.apiw
    delegate.apiw
    observer.apiw
    typestate.apiw
    buffer-fill.apiw
    error-side-channel.apiw
    refcounted.apiw
    builder.apiw
    subscription.apiw
```

The semantic model should be target-independent.

It should not mention Rust `Drop`, C# `IDisposable`, Scheme `dynamic-wind`, Python context managers, etc. Those belong under `targets/`.

---

## 13. Source platform semantic specifications

The `platforms/` directory describes source platforms.

A platform spec describes what the platform API means, not how any target language should express it.

Example:

```text
platforms/
  macos/
    platform.yaml
    docs/
    api/
    app-kinds/
    tests/
```

A source platform API spec may describe:

```text
types
operations
resources
ownership
lifetimes
relationships
semantic patterns
threading constraints
failure modes
callbacks
effects
protocol states
app kinds
platform-level tests
fixtures
```

It must not contain projection details.

For example, it may say:

```text
This operation returns an owned resource.
This callback escapes.
This delegate is weakly held.
This operation must run on the main thread.
This resource must be released exactly once.
```

It must not say:

```text
Generate Rust Drop.
Generate C# IDisposable.
Generate Scheme dynamic-wind.
Generate Python context manager.
```

---

## 14. Platform directory structure

Use this shape for macOS initially:

```text
platforms/
  macos/
    README.md
    platform.yaml

    docs/
      overview.md
      api-extraction.md
      app-kinds.md
      testing-obligations.md

    api/
      CoreFoundation/
        README.md
        extracted.yaml
        annotations.apiw
        resolved.yaml
        docs/
          ownership.md
          naming-conventions.md
          coverage.md

      Foundation/
        README.md
        extracted.yaml
        annotations.apiw
        resolved.yaml
        docs/
          objc-bridging.md
          nserror.md
          collections.md

      AppKit/
        README.md
        extracted.yaml
        annotations.apiw
        resolved.yaml
        docs/
          main-thread.md
          delegates.md
          app-lifecycle.md

    app-kinds/
      cli-tool/
        kind.apiw
        docs/
          lifecycle.md
          test-obligations.md

      gui-app/
        kind.apiw
        docs/
          lifecycle.md
          bundle-structure.md
          test-obligations.md

      menu-bar-daemon/
        kind.apiw
        docs/
          status-items.md
          lsui-element.md
          test-obligations.md

      launch-agent/
        kind.apiw
        docs/
          launchd.md
          lifecycle.md
          test-obligations.md

      spotlight-importer/
        kind.apiw
        docs/
          importer-bundles.md
          indexing-tests.md
          host-process-constraints.md

      quicklook-extension/
        kind.apiw
        docs/
          extension-bundles.md
          test-obligations.md

      finder-sync-extension/
        kind.apiw
        docs/
          extension-bundles.md
          test-obligations.md

    tests/
      api-semantics/
        ownership.yaml
        callbacks.yaml
        threading.yaml
        errors.yaml

      app-kinds/
        gui-app.yaml
        menu-bar-daemon.yaml
        spotlight-importer.yaml

      fixtures/
        pasteboard/
        spotlight/
        sample-documents/
        sample-images/
```

Equivalent structures should later exist for:

```text
platforms/linux/
platforms/dotnet/
```

---

## 15. Common app specifications

App specs are common to all targets.

They do not live under `targets/`.

They live under:

```text
apps/<platform>/<app>/
```

Example:

```text
apps/
  macos/
    cli-system-info/
    gui-counter/
    menu-daemon-clipboard/
    pasteboard-watcher/
    spotlight-indexer/
```

Each common app spec should be target-language-independent.

Suggested per-app structure:

```text
apps/macos/gui-counter/
  app.apiapp
  tests.apitest
  coverage.yaml
  docs/
    overview.md
    expected-behaviour.md
    semantic-coverage.md
```

The app spec should describe platform-visible behaviour, not implementation details.

It should not mention Gerbil, SBCL, Python, Rust, Haskell, etc.

Example app spec concepts:

```text
app kind
menus
windows
controls
actions
behaviour
permissions
platform integration
expected outputs
test steps
accessibility expectations
```

---

## 16. Target app implementations

Targets contain implementations of common app specs, not the app specs themselves.

Use:

```text
targets/<target>/app-implementations/<platform>/<app>/
```

Example:

```text
targets/
  gerbil/
    app-implementations/
      macos/
        gui-counter/
          generated/
          build/
          reports/
          docs/
            implementation-notes.md
            llm-generation-notes.md
            failures-and-workarounds.md

        menu-daemon-clipboard/
          generated/
          build/
          reports/
          docs/
```

The common app spec remains:

```text
apps/macos/gui-counter/app.apiapp
```

The Gerbil implementation is:

```text
targets/gerbil/app-implementations/macos/gui-counter/
```

The SBCL implementation is:

```text
targets/sbcl/app-implementations/macos/gui-counter/
```

All implementations must satisfy the same common app spec and TestAnyware tests.

---

## 17. Target model

A target is not merely a language name.

A target should distinguish:

```text
language family
language or dialect
implementation
FFI backend
runtime model
projection policy
adapter strategy
```

Examples:

```text
Scheme
  Gerbil
  Racket
  Guile
  Chicken
  Chez

Common Lisp
  SBCL + CFFI
  ECL + CFFI

Python
  CPython + extension module
  CPython + cffi
  CPython + ctypes

Haskell
  GHC + FFI

OCaml
  OCaml native + C stubs
  OCaml + ctypes
```

Target support must be modelled per language implementation, not only per language family.

---

## 18. Target directory structure

A target should have this shape:

```text
targets/
  gerbil/
    README.md
    target.yaml

    docs/
      overview.md
      language-characteristics.md
      ffi-model.md
      idiom-map.md
      representability.md

    implementations/
      gerbil-current.yaml
      docs/
        implementation-notes.md
        runtime-model.md

    idioms/
      resources.yaml
      callbacks.yaml
      errors.yaml
      gui.yaml
      packaging.yaml
      docs/
        resources.md
        callbacks.md
        errors.md
        gui.md
        packaging.md

    policies/
      macos/
        safe-adapter.yaml
        thin-direct.yaml
        docs/
          safe-adapter.md
          thin-direct.md
          tradeoffs.md

      linux/
        safe-adapter.yaml

      dotnet/
        safe-adapter.yaml

    adapters/
      macos/
        spec.yaml
        docs/
          architecture.md
          exported-abi.md
          callback-registry.md
          main-thread-dispatch.md
          error-normalisation.md
        generated/
        build/
        tests/

    bindings/
      macos/
        docs/
          user-guide.md
          platform-docs-mapping.md
          api-coverage.md
          unsafe-escape-hatches.md
        generated/
        build/
        tests/

    app-implementations/
      macos/
        gui-counter/
        menu-daemon-clipboard/

    conformance/
      macos.yaml
      docs/
        macos-conformance.md
        unsupported-features.md
```

This structure should be replicated for other targets as they are added.

---

## 19. Targets to account for

The project should be structured to eventually analyse and spike at least these targets:

```text
Scheme(s)
Lisp(s)
Clojure
OCaml
Haskell
Prolog
Mercury
Idris2
Java
Scala 3
Zig
Nim
Factor
BQN
Ruby
Swift
Odin
Elixir
Python
```

However, native-platform cases are lower priority or skipped as binding targets.

Examples:

```text
Swift bindings on macOS are not required.
C# / F# bindings on .NET are not required.
```

These languages may still be useful as reference models or source-platform comparison points.

---

## 20. Target capability profiles

Each target implementation needs a formal profile.

A profile should describe what the implementation can express statically, dynamically, conventionally, unsafely, or not at all.

Example capabilities:

```text
deterministic cleanup
finalization
ownership
borrowing
lifetime tracking
callback support
escaping callbacks
callback rooting
foreign-thread callbacks
thread affinity
main-thread dispatch
typestate
async/event integration
struct by value
strings
arrays
buffers
errno / platform errors
packaging
app bundle support
plugin support
sandboxing
native runtime embedding
```

Use representability levels such as:

```text
exact-static
exact-runtime
idiomatic-conventional
lossy-but-documented
unsafe-only
not-representable
research
```

---

## 21. Target idiom catalogue

Each target should have a catalogue of paradigmatic idioms.

This catalogue maps source semantic concepts to target-language expressions.

It should answer:

```text
When the platform API docs say X, how does that appear in this target?
```

Core idiom categories:

```text
owned resource
borrowed value
shared/reference-counted resource
explicit release
bracketed use
builder
typestate
nullable result
error side channel
exception-like failure
callback
escaping callback
subscription
delegate
async completion
thread affinity
main-thread requirement
buffer fill
two-call sizing
array/slice/view
string encoding
foreign struct
foreign enum / flags
global singleton
unsafe escape hatch
```

Example:

```yaml
target: common-lisp.sbcl-cffi

idioms:
  owned_resource:
    preferred:
      construct: clos-wrapper
      cleanup: explicit-close
      scoped: with-macro
    explanation: >
      Owned foreign resources are represented by CLOS objects that
      contain the foreign pointer and closed-state metadata.

  bracket:
    preferred:
      construct: with-macro
      mechanism: unwind-protect

  error_side_channel:
    preferred:
      construct: condition
      alternate:
        - multiple-values
```

Target idiom docs should be generated or maintained under:

```text
targets/<target>/idioms/docs/
```

---

## 22. Mapping documentation

Each target/platform binding should include mapping docs that help a user translate platform API documentation into target-language usage.

Example:

```text
targets/gerbil/bindings/macos/docs/platform-docs-mapping.md
```

These docs should answer questions like:

```text
The Apple docs say “caller owns”; what does that mean in Gerbil?
The docs say “delegate is weakly referenced”; how do I keep it alive?
The docs say “callback may be called on a background thread”; what does the binding do?
The docs say “NSError **”; why do I see a condition/result/error object?
The docs say “must be called on the main thread”; how is that expressed?
```

Mapping docs should be organized around source platform documentation concepts, not generator internals.

---

## 23. Projection information is target-specific

Projection information must not be part of the platform API specification.

It belongs under target-specific files, such as:

```text
targets/<target>/target.yaml
targets/<target>/idioms/
targets/<target>/policies/<platform>/
targets/<target>/adapters/<platform>/spec.yaml
targets/<target>/bindings/<platform>/docs/
```

The platform spec describes source facts.

The target profile describes target capabilities.

The policy describes how to map source semantics into target idioms.

The adapter spec describes what native adaptation is required for a specific platform/target pair.

---

## 24. Native adapter model

For each platform/target implementation combination, APIAnyware may generate a native adapter library.

Examples:

```text
macos.gerbil.dylib
macos.sbcl.dylib
macos.racket.dylib
macos.python.dylib
linux.gerbil.so
dotnet.python.dylib
```

The adapter is not merely FFI glue.

It may provide:

```text
memory management adaptation
lifetime tracking
callback rooting
thread marshalling
main-thread dispatch
autorelease pool management
error normalization
buffer sizing helpers
generic-erasure helpers
reflection/metadata helpers
delegate/subscription management
typestate runtime checks
object identity tables
resource registries
test instrumentation
```

Direct target-language FFI calls are allowed as an optimisation when safe and useful.

The target binding can use:

```text
direct call
direct call plus wrapper
adapter call
adapter call plus wrapper
unsafe escape hatch
unsupported marker
```

The choice is target-policy-specific.

---

## 25. Adapter ABI

The adapter ABI should be conservative and broadly consumable.

Prefer:

```text
integers
booleans
opaque handles
pointers
length + pointer buffers
UTF-8 strings
tagged error structs
callback tokens
subscription tokens
stable function pointer trampolines
```

Avoid exposing complex Swift, Objective-C, C++, JVM, or .NET internals directly unless the target can handle them.

The adapter may internally deal with complex platform concepts, but its exported ABI should be boring.

Use semantic handles where useful:

```text
apiw_object_id
apiw_resource_id
apiw_callback_id
apiw_subscription_id
apiw_error_id
apiw_buffer_id
apiw_iterator_id
```

This is especially useful for GC languages, dynamic languages, logic languages, array languages, actor runtimes, and targets with weak callback support.

---

## 26. Adapter roles

Adapter functions should be classifiable by role.

Suggested roles:

```text
direct_forwarder
semantic_adapter
utility_adapter
lifetime_adapter
callback_adapter
thread_adapter
error_adapter
buffer_adapter
collection_adapter
generic_erasure_adapter
reflection_adapter
test_probe
```

A target/platform adapter spec should describe which roles are required.

Example:

```yaml
adapter:
  id: macos.gerbil
  platform: macos
  target: scheme.gerbil
  output:
    library: macos.gerbil.dylib
    package: apiw-macos-gerbil

runtime_services:
  object_registry: required
  callback_registry: required
  subscription_registry: required
  main_thread_dispatch: required
  autorelease_pool_management: required
  error_registry: required
  test_instrumentation: enabled

direct_call_policy:
  allow:
    - simple_c_function
    - pure_value_function
  deny:
    - escaping_callback
    - objc_delegate
    - block_parameter
    - api_requires_autorelease_pool
```

---

## 27. Complete API surface

“Complete API surface” does not mean every source abstraction is perfectly remapped into every target language.

Instead, define completeness as:

> The adaptation system provides a mechanically addressable representation of the whole platform API surface, plus higher-level semantic adapters for the subset of APIs whose semantics are representable in the target implementation.

Use layers:

```text
Layer 0: raw platform symbol access
Layer 1: mechanically described API surface
Layer 2: normalized calling ABI
Layer 3: semantic helpers and adapters
Layer 4: paradigmatic target-language wrappers
Layer 5: sample applications and tests
```

For generic-heavy APIs, use one or more of:

```text
metadata inspection
erased representation
selected monomorphized adapters
collection-like common operations
raw escape hatch
manual target-specific wrapper
unsupported marker
```

Do not promise universal generic remapping.

---

## 28. LLM-assisted analysis

Headers alone are insufficient.

The extraction and annotation process should use:

```text
headers
runtime metadata
documentation
naming conventions
examples
manual annotations
LLM analysis
```

LLM analysis should generate annotations in a side channel.

LLM-derived annotations must be:

```text
cached
regenerable
diffable
reviewable
manually editable
provenance-tracked
confidence-scored
```

The LLM should propose facts, not decide truth.

Suggested fact precedence:

```text
manual override
accepted LLM annotation
platform convention rule
raw extraction
unknown
```

Unknowns should remain explicit and should not be silently guessed.

---

## 29. Specification format

There should be a human-editable DSL and a canonical interchange format.

Preferred workflow:

```text
.apiw DSL source
  -> parser
  -> canonical YAML
  -> validator
  -> resolver
  -> generator
```

The DSL should be pleasant for humans.

The YAML should be stable and machine-consumable.

Generators should consume canonical resolved YAML, not raw DSL.

Suggested files:

```text
extracted.yaml
annotations.apiw
resolved.yaml
```

Where:

```text
extracted.yaml
  mechanically extracted facts

annotations.apiw
  manually authored and/or LLM-proposed semantic annotations

resolved.yaml
  deterministic merged semantic graph used by generators
```

---

## 30. Source semantic weirdness to model

The source model must be rich enough to cover real-world API weirdness.

Ownership weirdness:

```text
owned
borrowed
shared
weak
retained
autoreleased
interned/static
borrowed-until-next-call
borrowed-until-owner-mutated
borrowed-until-callback-returns
borrowed-until-runloop-drains
caller-allocated
callee-allocated-caller-frees
container-owned
element-owned
transfer-container-only
conditional-transfer
ownership-depends-on-parameter
ownership-depends-on-return-code
ownership-unknown
```

Lifetime weirdness:

```text
call lifetime
owner lifetime
scope lifetime
manual release lifetime
callback lifetime
event subscription lifetime
thread lifetime
run-loop lifetime
autorelease-pool lifetime
transaction lifetime
arena lifetime
static lifetime
until next API call
until buffer mutation
until object invalidation
unknown lifetime
```

Threading weirdness:

```text
thread-safe
thread-compatible
thread-confined
main-thread-only
owning-thread-only
callback-thread-unspecified
callback-on-registering-thread
callback-on-main-thread
callback-on-private-thread
requires-run-loop
requires-message-pump
may-reenter
not-reentrant
may-block
must-not-block
async-signal-safe
fork-safe
fork-unsafe
```

Error weirdness:

```text
errno meaningful only on failure
errno may be stale
return null means failure
return null may be legitimate
negative return means failure
zero return means success
HRESULT
NSError**
GetLastError
exception
out-error valid only when false/null returned
out-value valid only when success
partial initialization on failure
failure consumes input
failure leaves input valid
cleanup required after partial failure
```

Callback weirdness:

```text
synchronous callback
escaping callback
callback with user-data pointer
callback with destroy notifier
callback must not call back into API
callback may be reentrant
callback may be called after unregister returns
callback called exactly once
callback called zero or more times
callback called from foreign thread
callback owns data
callback borrows data
callback captures must be rooted
callback lifetime tied to subscription token
callback lifetime tied to object lifetime
```

Buffer weirdness:

```text
caller provides buffer
callee fills buffer
callee writes required size
two-call sizing pattern
buffer may be partially written on failure
buffer length in bytes
buffer length in elements
output not null-terminated
output null-terminated if space
callee allocates buffer
caller frees with specific function
alignment requirements
pinned memory required
```

Relationship weirdness:

```text
parent owns child
child borrows parent
child keeps parent alive
parent weakly references child
delegate weakly held
observer strongly retained
subscription token controls lifetime
collection owns elements
collection borrows elements
element lifetime tied to collection
view invalidated by mutation
iterator invalidated by mutation
```

---

## 31. Relationship entities

The source spec should support explicit relationships, not only types and operations.

Examples:

```yaml
relationships:
  nsview.subview_ownership:
    kind: parent_child
    parent: NSView
    child: NSView
    ownership:
      parent_to_child: strong
      child_to_parent: weak_or_borrowed
    invalidation:
      child_removed_from_parent: relationship_ends
```

```yaml
relationships:
  callback.user_data_destroy:
    kind: callback_destroy_notifier
    callback: operation.register.callback
    user_data: operation.register.user_data
    destroy: operation.register.destroy_notify
    lifetime:
      user_data_valid_until: destroy_notify_called
```

Patterns may compose operations plus relationships.

---

## 32. Pattern library

Patterns should be first-class semantic entities.

A pattern should have:

```text
identity
kind
participants
roles
constraints
laws
source evidence
confidence
manual override status
```

Examples:

```text
bracket
builder
factory
observer
subscription
delegate
async completion
buffer fill
two-call sizing
typestate
error side channel
refcounted object
parent-child ownership
collection-element ownership
lock guard
transaction
iterator
```

A pattern is source semantic structure. It is not a target-language idiom.

For example:

```text
Source semantic pattern:
  bracket(acquire=fopen, release=fclose)

Target projection idioms:
  Rust Drop
  C# IDisposable
  Python context manager
  Common Lisp WITH-* macro
  Scheme dynamic-wind
  Haskell bracket
```

---

## 33. Testing architecture

Testing must happen at multiple levels.

Test layers:

```text
1. Spec validation tests
2. Extraction regression tests
3. Annotation/LLM review tests
4. Adapter ABI tests
5. Target binding unit tests
6. Semantic pattern tests
7. Cross-target conformance tests
8. AppSpec sample app tests
9. GUI/accessibility tests
10. Packaging/signing/install tests
11. Performance tests
12. Leak/lifetime/threading stress tests
```

Platform tests define obligations.

Target tests prove obligations for one target.

Common app tests define behaviour for a target-independent sample application.

Target app implementation tests prove that a target implementation satisfies the common app spec.

---

## 34. AppSpec and TestAnyware integration

The app specification layer should be isolated from target languages.

Use:

```text
~/Development/AppSpec
```

for target-independent app descriptions.

Use:

```text
~/Development/TestAnyware
```

for target-independent behavioural and GUI testing scripts.

APIAnyware should consume or reference these systems where appropriate.

An LLM should be able to:

```text
read a common app spec
read target binding docs and idiom catalogue
generate a target-language implementation
build it
run TestAnyware tests
inspect failures
patch the implementation
repeat
```

The tests validate the result, not the LLM’s confidence.

---

## 35. Sample app catalogue

For macOS, include or plan for sample apps such as:

```text
CLI tool
GUI document app
single-window GUI app
menu-bar daemon
agent/background-only app
LaunchAgent service
preferences/settings app
Spotlight importer/plugin
Quick Look extension
Finder Sync extension
Share extension
notification app
pasteboard utility
URL scheme handler
file association/document opener
global hotkey utility
accessibility-controlled app
audio/MIDI utility
network client
sandboxed app
```

Not every target must support every app kind immediately.

The support matrix should record:

```text
supported
possible
requires native adapter
requires packaging support
research
not applicable
unsupported
```

---

## 36. Packaging and app-form feasibility

Target/platform feasibility is not just about calling APIs.

It includes:

```text
Can the target runtime be bundled?
Can an app bundle be built?
Can the app be signed?
Can the app be notarized?
Can plugins load the runtime?
Can host-process constraints be satisfied?
Can callbacks enter the runtime safely?
Can sandboxing work?
Can the app be launched by the platform service manager?
```

Some targets may support CLI apps but not GUI apps.

Some may support GUI apps but not plugin-style apps.

Some may support standalone apps but not Spotlight importers or Quick Look extensions.

Record this in target conformance files.

---

## 37. Conformance reports

Each target/platform pair should have conformance files, for example:

```text
targets/gerbil/conformance/macos.yaml
```

These should report:

```text
API coverage
semantic feature coverage
adapter coverage
binding tests
app-kind support
common app implementation status
unsupported features
research items
known issues
```

Example statuses:

```text
pass
partial
research
unsupported
failed
skipped
```

---

## 38. Support matrix

The project should maintain a structured support matrix.

It should classify:

```text
platform × target implementation × app kind × semantic feature
```

Example:

```yaml
support:
  platform: macos
  target: scheme.gerbil

api_surface:
  simple_c: good
  corefoundation: good
  objective_c: possible
  appkit: possible
  swift_generics: limited
  blocks: adapter_required
  delegates: adapter_required

app_kinds:
  cli:
    status: good
  gui_app:
    status: possible
    requires:
      - native_launcher
      - bundled_runtime
      - main_thread_adapter
  menu_bar_daemon:
    status: possible
  spotlight_importer:
    status: research
    concerns:
      - plugin_loading_runtime
      - signing
      - host_process_constraints

semantic_features:
  owned_resource: good
  borrowed_lifetime: runtime
  callback: adapter_required
  foreign_thread_callback: risky
  main_thread_affinity: adapter_required
```

---

## 39. Recommended initial spike set

Do not try to implement everything first.

Use representative targets.

Initial targets:

```text
Gerbil
SBCL/CFFI
Racket
Python
Rust
Zig
Haskell/GHC
Java
Elixir
```

Initial macOS API subset:

```text
Foundation NSString/NSArray
CoreFoundation ownership
NSError mapping
NSApplication minimal lifecycle
NSStatusItem menu daemon
callbacks/subscriptions
main-thread dispatch
```

Initial common apps:

```text
CLI system info
GUI counter
menu-bar clipboard daemon
pasteboard watcher
Spotlight indexer as research spike
```

Initial tests:

```text
adapter ABI smoke tests
binding smoke tests
resource lifecycle tests
callback rooting tests
main-thread tests
GUI launch tests
menu tests
window tests
packaging tests
```

---

## 40. Implementation approach for Claude Code

Claude Code should refactor incrementally.

Recommended sequence:

1. Rename project directory and internal references from `APIAnyware-MacOS` to `APIAnyware`.

2. Create the top-level directory structure:

```text
semantic/
platforms/
apps/
targets/
schemas/
```

3. Move existing macOS-specific material under:

```text
platforms/macos/
```

4. Move or create target-specific material under:

```text
targets/<target>/
```

5. Ensure common app specs live under:

```text
apps/macos/<app>/
```

not under targets.

6. Ensure target app implementations live under:

```text
targets/<target>/app-implementations/macos/<app>/
```

7. Move documentation beside the thing it documents.

8. Reduce the root README to a repository map.

9. Add placeholder README files where needed to explain empty or future directories.

10. Add initial schema placeholders under `schemas/`.

11. Add semantic pattern-kind placeholders under `semantic/pattern-kinds/`.

12. Add macOS platform placeholders under `platforms/macos/`.

13. Add at least one target skeleton, preferably `targets/gerbil/` and/or the currently active SBCL/CLOS branch target.

14. Do not delete existing useful code. Move it into the closest appropriate new location and leave migration notes where necessary.

15. Preserve buildability at each step where possible.

16. Add TODO markers for unresolved migration decisions.

---

## 41. Naming conventions

Use lowercase kebab-case for directories where possible:

```text
menu-bar-daemon
gui-counter
core-foundation
error-side-channel
buffer-fill
```

For platform API families, use conventional names when clearer:

```text
CoreFoundation
Foundation
AppKit
```

Target identifiers should be stable and lowercase:

```text
gerbil
sbcl
racket
python
rust
zig
haskell
ocaml
java
scala3
clojure
elixir
ruby
nim
odin
factor
bqn
prolog
mercury
idris2
```

When an implementation matters, use explicit files:

```text
targets/sbcl/implementations/sbcl-cffi.yaml
targets/racket/implementations/racket-cs.yaml
targets/python/implementations/cpython-cffi.yaml
targets/python/implementations/cpython-extension.yaml
```

---

## 42. Generated vs build outputs

Use:

```text
generated/
```

for reproducible generated source artifacts that may be reviewed or checked in.

Use:

```text
build/
```

for disposable compiler outputs, dylibs, object files, logs, and temporary build products.

Use:

```text
reports/
```

for test outputs, coverage outputs, screenshots, conformance reports, and generated dashboards.

Example:

```text
targets/gerbil/adapters/macos/generated/
targets/gerbil/adapters/macos/build/
targets/gerbil/app-implementations/macos/gui-counter/reports/
```

---

## 43. Safety and honesty requirements

Generated bindings and docs should be honest about unsupported or weakened semantics.

Do not silently generate unsafe APIs as if they were safe.

If a feature is not representable, mark it.

If a feature is runtime-only, document it.

If a callback may be unsafe from a foreign thread, report it.

If finalization is non-deterministic, do not present it as deterministic cleanup.

If a borrowed lifetime cannot be statically enforced, document how it is guarded or where it is unsafe.

---

## 44. Final desired mental model

The final repository should communicate this model:

```text
semantic/
  What meanings exist?

platforms/
  What does each source platform provide and require?

apps/
  What common behaviours should bindings be able to realise?

targets/
  How does each target language implementation express those meanings,
  and how well does it pass the tests?

schemas/
  How are all of these artifacts validated?
```

Or more compactly:

```text
semantic = concepts
platforms = source truth
apps = behavioural benchmarks
targets = expression and proof
schemas = validation
```

---

## 45. Success criteria for the refactor

The refactor is successful when:

1. The project is renamed to `APIAnyware`.

2. macOS-specific source platform material lives under `platforms/macos/`.

3. Target-specific material lives under `targets/<target>/`.

4. Common app specs live under `apps/<platform>/<app>/`.

5. Target app implementations live under `targets/<target>/app-implementations/<platform>/<app>/`.

6. Documentation is local to its subject.

7. The root README is only a map.

8. The structure can accommodate Linux and .NET without redesign.

9. The structure can accommodate many target languages and implementations.

10. Projection information is absent from platform specs.

11. Common app specs are target-independent.

12. Native adapter libraries are represented as platform/target-specific artifacts.

13. There is an obvious place for schemas, semantic pattern kinds, target idiom catalogues, adapter specs, binding docs, conformance reports, and tests.

14. Claude Code can continue from the new structure without needing to infer the architecture from scattered files.

---

## 46. Short instruction block for Claude Code

Use this as a concise task summary:

```text
Rename APIAnyware-MacOS to APIAnyware.

Refactor the project into five top-level domains:
semantic/, platforms/, apps/, targets/, schemas/.

Move macOS source-platform API material under platforms/macos/.
Move common target-independent app specs under apps/macos/.
Move target-language-specific profiles, idioms, policies, adapters, bindings,
generated code, app implementations, tests, conformance files, and docs under
targets/<target>/.

Do not put substantive docs in a top-level docs/ directory. Documentation must
live beside the thing it documents.

Keep platform specs projection-free. Projection policy belongs under targets/.

Keep app specs target-independent. Target-specific app code belongs under
targets/<target>/app-implementations/<platform>/<app>/.

Represent per-platform/per-target native adapter libraries explicitly under
targets/<target>/adapters/<platform>/.

Add placeholder schemas, semantic pattern kinds, macOS platform structure, common
macOS apps, and at least one target skeleton.

Preserve existing useful code by moving it to the closest appropriate new
location. Leave migration notes for unresolved decisions.
```

---

## 47. End state summary

APIAnyware should become a platform-neutral semantic interop system.

It should model source APIs formally, analyse documentation with reviewable LLM assistance, expose multi-API patterns as first-class semantic entities, generate target-specific native adapters and idiomatic bindings, document how platform API concepts map into each target language, and verify the whole system through common target-independent app specs and behavioural tests.

The project should be structured so that platforms, targets, apps, schemas, and semantic vocabulary are isolated but composable.
