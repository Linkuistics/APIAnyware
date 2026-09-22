# An authoritative interface language: initial research

Research date: 2026-09-22. This is a bounded initial survey, supporting the
[design proposal](../design/2026-09-22-interface-language.md). It is not a census
of every IDL or every field in APIAnyware.

## Requirements established with the author

The output is a dedicated interface specification language, writable by people,
APIAnyware, and independent producers. Its consumers include binding generators,
documentation systems, and LLM development tools. Published specifications must
be complete and authoritative. Partial analysis, confidence scores, unresolved
facts, and competing interpretations belong upstream. The author explicitly
selected a dedicated language syntax rather than retaining KDL/.apiw.

Swift is the initial source-language focus. Rust, Zig, Windows APIs reached
through .NET-related tooling, and C APIs for Linux/X11/Wayland are future pressure
tests. Documents identify ABIs; tooling owns the supported ABI definitions.

## Evidence from APIAnyware

Main workspace parent: `d0ed4c83`; the working change when research began was
`83c8e708`. The OCaml workspace reported `27488a80` with `--ignore-working-copy`;
the evidence below comes from files read directly, not an assertion that its
entire live tree equals that commit.

Graph verification used Tier 2. Main project
`Users-antony-Development-APIAnyware` reported generation
`2026-08-31T10:09:23Z`; the cited Rust paths had matching metadata and no recorded
coverage gaps. OCaml project `APIAnyware.add-ocaml-target`, generation
`2026-09-08T08:04:02Z`, excludes `semantic/tools/`. Its relevant source was read
directly. Coverage is best-effort, not a completeness proof. ADRs record intent;
source checks below establish the narrower implementation claims.

| Evidence | What it establishes | Consequence for the language |
|---|---|---|
| [ADR-0046](../../../adr/0046-spec-interchange-format-kdl-everywhere.md), [Cargo.toml](../../../Cargo.toml) | Existing architecture distinguishes extracted facts, authored overlays and resolved output; KDL is already adopted. | This work changes the public contract boundary as well as syntax. It must not merely relabel the existing checkpoint. |
| [MethodAnnotation](../../tools/types/src/annotation.rs) | Parameters have ownership; block parameters have invocation styles; threading, error patterns, confidence and provenance are represented. | Preserve the semantic facts; keep inference state outside the published language. |
| [TypeRefKind](../../tools/types/src/type_ref.rs) | The repertoire includes ObjC classes, protocols on `id`, selectors, blocks, C callbacks, aliases, structs and primitives. | The initial baseline is Swift-facing Apple APIs, already spanning ObjC and C semantics. |
| [PatternKind](../../tools/patterns/src/kind.rs), [PatternInstance](../../tools/types/src/pattern_instance.rs) | Reusable role/law definitions are separate from concrete participant bindings. | Retain kind/instance separation and typed references across operations and types. |
| [Callback relationship](../../pattern-kinds/callback-destroy-notifier.apiw), [subscription](../../pattern-kinds/subscription.apiw) | Some material lifetime laws currently live in prose beside vocabulary tokens. | A normative language needs explicit meanings for laws that bindings must act on. Tokens and explanatory prose alone are insufficient. |
| [resolve_loaded_frameworks](../../tools/resolve/src/lib.rs) | Resolution loads frameworks together and derives inherited/effective members through Datalog. | A published document must have resolved imports and relationships; consumers should not reconstruct extraction history. |
| [Capability decision](../../../adr/0051-capability-profiles-and-derived-representability.md) | API facts and target representability are distinct concerns. | A complete API specification may still be unsupported by a particular consumer. |

The graph trace of `resolve_loaded_frameworks` was bounded to depth 1 in both
directions, with no pagination remaining. Some graph-resolved callees were
implausible Rust resolutions, so its source body was read before describing the
path. Broad symbol discovery was narrowed to these candidates; no exhaustive
symbol inventory is claimed.

### Changes visible in the OCaml workspace

The following are confirmed in the branch's
[type model](../../../../APIAnyware.add-ocaml-target/semantic/tools/types/src/type_ref.rs),
[declaration model](../../../../APIAnyware.add-ocaml-target/semantic/tools/types/src/ir.rs),
and [provenance model](../../../../APIAnyware.add-ocaml-target/semantic/tools/types/src/provenance.rs):

- `Nullability` distinguishes nullable, non-null and unknown. Publication must
  settle an unknown at a nullable position; silently converting it to non-null
  or nullable changes the claim.
- Raw pointers retain recursive pointee types, pointee constness, incompleteness
  and a typedef name. An intentionally opaque type is different from an
  unrecorded pointee.
- C complex values are a distinct type. An unsupported value representation
  cannot be encoded as a pointer just to make a backend accept it.
- Method ownership attributes distinguish return ownership and receiver
  consumption; parameters separately record consumed ownership. Direct C
  function returns have their own contract. A single `owned` flag is inadequate.
- Availability includes withdrawal and unversioned deprecation. Source-view
  limits remain: absence of a withdrawal fact is not a positive guarantee of
  availability on later OS versions.
- `objc_exposed` and Swift call metadata distinguish runtime dispatch from
  Swift-native calls. Source language alone cannot choose a calling path.

Rationales and known limits are recorded in branch
[ADR-0079](../../../../APIAnyware.add-ocaml-target/adr/0079-ownership-attributes-are-an-extracted-fact.md),
[ADR-0080](../../../../APIAnyware.add-ocaml-target/adr/0080-pointer-pointee-is-an-extracted-fact.md),
[ADR-0082](../../../../APIAnyware.add-ocaml-target/adr/0082-nullability-is-a-three-answer-extracted-fact.md),
[ADR-0101](../../../../APIAnyware.add-ocaml-target/adr/0101-objc-extraction-floor-and-withdrawal-facts.md),
and [ADR-0102](../../../../APIAnyware.add-ocaml-target/adr/0102-c-complex-is-a-distinct-ir-type.md).
Their historical whole-SDK counts have not been rerun for this research.

## Prior art and what transfers

### WIT and the WebAssembly Component Model

WIT supplies a dedicated interface syntax, packages, records, variants and
resource handles. Its owned and borrowed handles have precise semantics;
borrowing is tied to the duration of a call. This is useful precedent for
readable contracts and explicit ownership. Native APIs with stored callbacks,
receiver-dependent borrows and multiple native calling paths need an evaluated
mapping rather than an assumed equivalence. That last conclusion is a design
inference, not a claim that WIT has failed at its intended purpose.
[WIT specification](https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md)
and [WIT overview](https://component-model.bytecodealliance.org/design/wit.html).

Walk-away result: text interfaces remain legible without a generator. Reuse the
dedicated syntax discipline; do not make the proposed language's native ABI
meaning depend implicitly on the Component Model's lowering conventions.

### GObject Introspection

GObject Introspection distinguishes transfer of the container from transfer of
its elements, relates callbacks to user data and destroy notifiers, and specifies
callback scopes. It also distinguishes a nullable output value from a nullable
output destination. Those distinctions should be in the contract corpus used to
evaluate this language. Its annotation defaults are ecosystem conventions; they
should not become universal defaults for unrelated APIs.
[Official annotation reference](https://gi.readthedocs.io/en/latest/annotations/giannotations.html).

Walk-away result: source annotations remain readable; GIR is an inspectable
interchange artifact. The useful lesson is the vocabulary of foreign-memory
contracts, not a requirement to adopt its annotation syntax.

### Win32 metadata and WinRT

Win32 metadata describes native APIs for independently developed language
projections. It includes resource-disposal information. Microsoft explicitly
states that its ECMA-335-based metadata is not directly callable by the .NET
runtime as if it were a normal .NET assembly.
[Repository](https://github.com/microsoft/win32metadata) and
[FAQ](https://github.com/microsoft/win32metadata/blob/main/docs/faq.md).

WinRT interfaces use the IInspectable/IUnknown relationship, including COM
reference counting. A metadata format, a managed runtime and a native object ABI
therefore need separate identities in the proposal.
[WinRT type system](https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system).

Walk-away result: metadata remains an interchange artifact but needs a metadata
reader for inspection. A standalone textual language should improve that
authoring/inspection boundary while retaining projection-independent facts.

### Rust, Zig and Swift ABI constraints

Rust's reference gives the native Rust ABI no stability guarantee; `C` means the
target's dominant C ABI, and `system` is target-dependent. Unwinding variants are
also distinct. An ABI name without environment and compatibility constraints is
not sufficient.
[Rust Reference](https://doc.rust-lang.org/reference/items/external-blocks.html#abi).

Zig's `extern struct` and `extern union` explicitly select C-compatible layout;
packed representations have different rules. A source-language label cannot
stand in for representation selection.
[Zig language reference](https://ziglang.org/documentation/master/#extern-struct).
This is a moving reference; a future profile must pin a released version.

Swift distinguishes ABI stability, module stability and library evolution.
The design must preserve the distinction between an addressable binary entry and
a call compiled against a source/module interface, including resilient types.
[Swift library evolution](https://www.swift.org/blog/library-evolution/) and
[ABI manifesto](https://github.com/swiftlang/swift/blob/main/docs/ABIStabilityManifesto.md).
The historical blog is evidence of those distinctions, not a fresh platform
support matrix.

Walk-away result: source declarations and their documented contracts remain
readable, but operating a binary still requires the relevant compiler/runtime.
The language can name these dependencies without reimplementing their ABIs.

Two additional checks sharpen this boundary. Rust permits type layout to vary
between compilations, so a compiler-version pin alone does not establish binary
compatibility. A path needs a stated stable ABI or a sufficiently constrained
artifact/build domain. [Rust layout guarantees](https://doc.rust-lang.org/stable/reference/type-layout.html#layout.guarantees).
Microsoft's `PreserveSig` documentation describes how a managed COM signature
can hide HRESULT distinctions, including different successful values. Related
access paths therefore need explicit mappings and must not silently promise
identical observable contracts. [PreserveSig reference](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.preservesigattribute?view=net-10.0).

### Wayland

Wayland's XML defines interfaces, requests and events. Its generated inline
protocol entry points are not part of the library ABI; the official documentation
directs language bindings to generate their own stubs. A declaration that looks
callable in C is therefore not necessarily an exported symbol. Protocol version
and object lifetime are additional contract axes.
[Official protocol documentation](https://wayland.freedesktop.org/docs/book/Protocol.html).

Walk-away result: XML and protocol documentation remain readable. For the initial
language, distinguish C library access from protocol access. A future wire
protocol profile is a separate capability, not an invented C ABI identifier.

## Research conclusions and limits

The recommended design is a common semantic contract model plus versioned
source/access profiles and references to a tooling-owned ABI catalogue. This is
a synthesis of the evidence above, not a feature supplied by any one prior tool.

Three questions still need dedicated specification work: the exact constraint
expression language; the full mapping of the existing Swift/ObjC/C repertoire;
and precise version/compatibility rules for profile and catalogue evolution.
No primary source found in this bounded survey establishes that one existing
IDL directly meets all requested native ABI and behavioural-contract needs.
That is a limit of this survey, not proof that no such language exists.

The next research should compare a concrete corpus across candidate syntax and
semantics, rather than continue collecting unrelated IDLs. The design proposal
defines that corpus and the rejection cases. No parser, native ABI probe or
cross-language authoring experiment was run in this initial research.
