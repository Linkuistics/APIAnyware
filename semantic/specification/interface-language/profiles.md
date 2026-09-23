# Profiles, access paths and ABI references

Normative draft 0.1. **A1–A5** specify the provider boundary. **F1** defines a
synthetic catalogue used only by this draft's examples. No production provider
is implemented by these documents.

<a id="a1"></a>

## A1. Provider manifests

A profile is a versioned, digest-pinned definition of additional source types,
clauses, access mechanisms or behavioural rules. Its manifest MUST specify:

- its identifier/version and supported language versions;
- every type constructor, clause, constructor and enum value, with arity, types,
  scopes, applicability, defaults (if any), conflicts and required companions;
- exact interpretation of source identity, environment fields and runtime names;
- semantic obligations, validation rules, dependency versions and access mappings;
- representation requirements and which ABI catalogue entries can satisfy them;
- a canonical machine view and lossless printing rules for its semantic content.

Profile clauses use `alias::clause(...)`; profile types and constructors use the
same namespace. A profile cannot weaken a core requirement, change core semantics
or turn an unknown fact into an authoritative default. A new core meaning requires
a new language version. Pure navigation goes in `doc`/`link`, not an unknown
extension whose meaning consumers might accidentally ignore.

An ABI entry is a tooling-owned, versioned definition of calling conventions and
representations. Its manifest MUST specify accepted environment configurations,
type lowering, parameter/result/exception lowering, aggregate layout rules,
callback entry rules, runtime prerequisites and compatibility conditions. Tooling
may implement it using a native compiler/runtime. The AIL package **references**
this definition; it does not reproduce a register assignment or stack algorithm.
Calling convention is selected within an ABI entry, never treated as the entire ABI.

Different consumers may support different providers. They must identify unsupported
dependencies before claiming complete validation. A syntax reader may preserve an
unsupported package as text, but MUST NOT label it a validated authoritative model.

<a id="a2"></a>

## A2. Access paths

Every function requires one or more `access` blocks; each global and non-literal
constant does too. Callbacks instead require `callback_abi(abiAlias, "convention")`
and `representation(profileAlias, "kind")` in their declaration. A callable's
source spelling does not create an access path.

Each access has a distinct local name and lists environments in which it applies.
The list is a nonempty subset of the declaration's availability. Across all paths
every available environment must have at least one path. Several paths may apply;
selection requires an explicit consumer choice or configuration policy. Document
order does not select a path. Every selected path must implement the *whole*
declaration contract, including exceptional behaviour and callback obligations.

Every path MUST contain exactly one of each core clause:

| Clause | Values and interpretation |
|---|---|
| `abi(alias, "convention")` | Known ABI alias and one of its supported conventions. Even source access must state its effective ABI dependency; a source compiler may be the provider that realizes it. |
| `via(profileAlias, "mechanism", "identity")` | Profile-defined access kind and exact identity: for example linker symbol, message selector, source invocation, managed member or wire request. |
| `mapping(identity)` or `mapping(profileAlias, "mapping-id")` | `identity` is valid only if the access/ABI pair defines a total faithful lowering of the declared signature or data value. Other mappings are named, versioned recipes defined by the profile, not embedded code or prose. |
| `compatibility(stable)` or `compatibility(artifact, "build-id")` or `compatibility(source, "build-recipe-id")` | Required compatibility domain; see A4. |

Input order is declaration order. Explicit receiver parameters participate in the
semantic signature even if a profile lowers them to an implicit receiver. A
mapping must account for every parameter/result, auxiliary native argument and
completion mode exactly once, including inserted context pointers, error-out
storage and ownership adjustments. A mapping must preserve distinctions visible
to clients. ABI lowering such as splitting a complex value across registers does
not create a new semantic declaration. Hiding a meaningful success status does.

No default Objective-C path is inferred from a Swift spelling. A Swift-only member
may have only source access. Macro expansion, inline source and empty/erasing
macros require distinct provider mechanisms; none imply a linker symbol exists.
The same applies to managed projections and wire protocols.

<a id="a3"></a>

## A3. Type representations and data access

A type needed at an access boundary must be representable by the selected provider
over that path's environments. Core scalar widths, record field order, array
extent, enum domain and pointer mutability are semantic facts. Layout such as
size/alignment, packing, endianness, field offsets and bitfields are supplied by
an ABI definition together with profile-controlled representation clauses or an
identified compiler artifact. Mere presence of a record name is insufficient.

For every reachable nominal type and boundary, tooling must resolve one complete
representation recipe. For a resilient opaque value, that recipe may require
runtime metadata/operations rather than expose offsets. It must still define all
operations needed to pass, copy, move and destroy that value. If none applies, or
multiple conflicting recipes apply, validation fails. Tools must not assume that
an aggregate's semantic fields imply a stable native layout.

Data mechanisms distinguish **load stored value**, **use symbol address**, and
**evaluate source expression**. A pointer-valued global normally loads the pointer
held at a symbol; an array export supplies the address of array storage. Their
type spelling alone does not select the mechanism. A macro-created object may
need source construction with ownership/effects supplied by the profile; it is
not necessarily a literal or a linkable constant. Volatile/atomic storage and
effectful evaluations require explicit profile semantics.

<a id="a4"></a>

## A4. Representation and compatibility

`stable` claims compatibility across the ABI entry's specified domain; the
provider must actually guarantee that domain for all reachable types. It is not
synonymous with a stable spelling of the calling convention.

`artifact` binds use to a particular built artifact set. The build ID must resolve
in the explicit resolution set to its content identities, compiler/runtime
requirements and representation manifest. A compiler version alone is not an
artifact identity and does not prove reproducible layout.

`source` binds use to a named, fully specified build recipe in a profile manifest.
The recipe pins source dependencies, compiler and options, required module/header
interfaces and the adapter/build procedure. The recipe's compiler establishes
compatibility for that build. Source access does not assert independently stable
binary interoperability. A binding consumer lacking the compiler may refuse that
path while a documentation consumer can describe it accurately.

For illustration, a future Rust-native profile cannot infer stable layout from a
Rust version pin; a Zig profile must distinguish native from externally specified
representations; Swift must distinguish resilient/native source access from
Objective-C exposure; .NET must distinguish managed/WinRT/COM/native access; and
Wayland must distinguish generated C wrappers from the versioned wire protocol.
These are design requirements, not implemented providers. Primary research and
its qualification are in the [survey](../../docs/research/2026-09-22-interface-language-a.md).

<a id="a5"></a>

## A5. Consumer agreement

The authoritative view includes declaration identity, full types, per-environment
access alternatives, slot contracts, all outcomes, callback schedules, availability
and patterns. A documentation renderer may present this in prose; an LLM library
may present a typed object model. Both must retain access to all normative facts
and distinguish API obligations from target-specific restrictions or explanatory
examples. A convenience view cannot silently rewrite ownership or erase errors.

Canonical model equality ignores comments, whitespace, clause order where order
has no meaning, declaration order and navigation clauses. It preserves parameter
and record-field order, identities, imports and provider pins, literal values,
outcome partitions, all contracts, and array/list order where the owning rule
defines order. Lists denoting sets are canonicalized by identity; duplicate set
members are errors. Source navigation and docs must still survive a lossless
authoring round trip, even though they are not part of semantic equality.

Validation of the specification is consumer-independent. Binding feasibility is
a later query over a selected environment, path and target language. A binding
generator may refuse an otherwise valid package because it cannot preserve a
contract. It must report that limitation separately from malformed/incomplete AIL.

<a id="f1"></a>

## F1. Synthetic fixture catalogue

The examples use profile `example.fixture` version `1` and ABI `example.fixture-abi`
version `1`. Their digest pins use `sha256:` plus 64 `a` or 64 `b` digits,
respectively. These are **test resolution tokens** supplied by the conformance
harness, not SHA-256 claims about these Markdown bytes. This exception is confined
to fixture mode; ordinary L2 resolution must reject these pins unless real
manifests happen to hash to them. Fixture mode MUST NOT publish production packages.

The profile supports only target `fixture64`, platform `fixture` version `1`,
and optional toolchain `fixture-compiler` version `1`. Source identities are exact
nonempty strings with no further name resolution. ABI conventions are `c`,
`object-message` and `source`. The ABI guarantees stable fixture-domain
representation for core scalars, pointers, object/interface references, unique
and reference-counted resource handles, and ordered records of representable
fields. Implicit message receivers use that same object-reference recipe.
Integer widths are exact, pointers/handles/object/interface references are
64 bits, and field layout is supplied by the synthetic provider; this is an
abstract test provider, not any host ABI. Callback signatures use the chosen
convention with `representation(fixture, "closure")`, whose stored representation
supports strong retention/release and has no separately visible context argument.

Supported mechanisms, with faithful `mapping(identity)`, are:

| Mechanism | Declaration and identity |
|---|---|
| `symbol` | Function, nonempty linker name; all parameters explicit. Convention `c`. |
| `message` | Function with object member/receiver, exact selector. Receiver becomes implicit; remaining parameter order is preserved. Convention `object-message`. |
| `source-call` | Nonempty source callable spelling, convention `source`. Build recipe `fixture-build` requires exactly `fixture-compiler` version `1` and compiles against this package's source surface; no other source dependencies/options. |
| `load` | Global/constant, linker name, load its declared value. Convention `c`. |
| `address` | Global/constant of pointer type, linker name, address of its pointee storage. Convention `c`. |

Objects use `runtime(fixture, "retain")` and `runtime(fixture, "release")`, with
ordinary shared reference counts and destruction at zero. `copy(region)` is not
supported by this fixture profile. `static` ends at provider unload; clients must
release all owned values and stop using borrows before unloading. The provider
supports encoding `utf-8`. Unique destructors and synchronous callbacks honour
the specified core contracts; asynchronous registration is supported by owner
scope and quiescent destruction, without using an `execution(async)` operation.

Profile clause `fixture::sendability(available|unavailable|nonconforming)` is
allowed once on objects, records, enums, flags and interfaces. It represents
three distinct compiler conformance states, independent of `sharing`.
Optional singular `fixture::actor(none|"name")` is allowed on those same five
declaration kinds only. It records source actor identity and must agree with
core isolation (`none`, or `executor(fixture, "name")`). No actual Swift compiler
conformance is asserted. There are no other fixture types, clauses or mechanisms.

The profile supports only non-throwing synchronous callable entry, non-variadic
signatures, core nominal/value types and the source-call mechanism above. It does
not support optional interface members, generic families, cancellation delivery,
exception unwinding, unions or bitfields. Test packages requiring any of those
must fail provider-capability validation rather than be accepted with holes.
