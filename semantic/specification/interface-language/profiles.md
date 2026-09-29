# Profiles, access paths and ABI references

<!-- reading-aid: page-context -->
> **Purpose:** rules with reading aids — connect API declarations to provider definitions and ways to reach code or data.
> **Reader:** language designers new to API binding, and authors or implementers checking provider boundaries.
> **Before this:** [the package and declaration model](language.md#l2); [the contract rules](contracts.md#c1) explain value and call obligations.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [A1](#a1), [A2](#a2), [A3](#a3), [A4](#a4) and [A5](#a5) below are canonical; [F1](#f1) defines the synthetic fixture catalogue.

Each bordered **Reading aid (non-normative)** explains an example. The paragraphs
outside the border state the requirements. The examples use
invented APIs and F1's abstract test providers. Fragments name their missing
context; the [conformance examples](conformance.md#positive-specifications)
supply complete contracts. [Packages, environments and access paths](explanation/packages.md)
provides a connected explanation.
<!-- /reading-aid -->

Normative draft 0.1. **A1–A5** specify the provider boundary. **F1** defines a
synthetic catalogue used only by this draft's examples. No production provider
is implemented by these documents.

<a id="a1"></a>

## A1. Provider manifests

<!-- reading-aid: a1-dependencies -->
<blockquote>

<a id="reading-aid-non-normative-name-the-definitions-the-package-depends-on"></a>

**Reading aid (non-normative): name the definitions the package depends on**

A tool needs definitions for how to reach an API and how its values cross the
machine boundary. An AIL package selects those definitions by name, version and
digest. A [profile](glossary.md#profile) defines mechanisms and any extra
vocabulary; an [ABI entry](glossary.md#abi-entry) defines calling conventions
and representations. A [provider](glossary.md#provider) supplies the definitions
and the capabilities needed to use them ([A1](#a1)).

Fragment — shows the dependencies and environment of the invented Counter API.
The complete [objects package](examples/objects.ail) also supplies publication
clauses and declarations. These digest strings are **F1 test resolution tokens**,
not hashes of production manifests or of this page.

<!-- ail-example: examples/rule-reading/providers.ail region=dependencies -->
```ail
language "0.1";
package example::objects version "1" {
  use profile fixture = "example.fixture" version "1"
    digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1"
    digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  environment test {
    target("fixture64");
    platform("fixture", "1");
    toolchain("fixture-compiler", "1");
  }
  // Publication clauses and declarations omitted; these pins are F1 test tokens.
}
```

`fixture` and `native` are aliases inside this package. A later
`via(fixture, ...)` selects the profile, while `abi(native, ...)` selects the
ABI entry. The strings `"example.fixture"` and `"example.fixture-abi"` name the
definitions supplied in the [resolution set](glossary.md#resolution-set).
`test` names the exact [environment](glossary.md#environment)
in which this package uses them ([L2](language.md#l2), [L3](language.md#l3)).

The provider manifest states which mechanisms, types, values and environments
it supports. Here [F1](#f1) supplies that synthetic definition. A package using
an unsupported mechanism can still have recognisable syntax, but the
[consumer](glossary.md#consumer)
cannot claim complete validation. The supplied definition must explain the
mechanism's meaning as well as its spelling ([A1](#a1)).

[Dependency grammar and railroad view](reference/notation.md#dependency).

Use the `profile` branch for `fixture` and the `abi` branch for `native` in
the fragment. In each path, the first `identifier` is the local alias; the
three `string` positions supply the external identifier, version and digest.
The [package shell](language.md#l1) places each
dependency among the package's items. F1 defines the special digest tokens
used here; the path alone cannot establish a valid pin.

The [grammar](grammar.ebnf)'s `dependency` production starts with `use`, selects
`profile` or `abi`, then gives an alias, identifier string, version and digest.
It describes a reference to an external definition; it does not embed the
manifest's schema. See [Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: a1-namespace -->
<blockquote>

<a id="reading-aid-non-normative-recognise-a-profile-clause-at-its-declaration"></a>

**Reading aid (non-normative): recognise a profile clause at its declaration**

A profile can add a fact using its alias as a namespace. Counter's description
includes a synthetic compiler-conformance fact alongside its core sharing and
isolation clauses ([A1](#a1), [F1](#f1)).

Fragment — shows the profile clause on Counter. The complete
[objects package](examples/objects.ail) supplies its header, pinned providers,
environment, publication clauses, lifecycle and nominal relations.

<!-- ail-example: examples/rule-reading/providers.ail region=profile-facts -->
```ail
package example::objects version "1" {
  object Counter {
    sharing(confined);
    isolation(main);
    fixture::sendability(nonconforming);
    // Availability, lifecycle and nominal relations omitted.
  }
  // Header, fixture profile pin, environment and publication context omitted.
}
```

`fixture::sendability(nonconforming)` selects a clause defined by the profile
aliased `fixture`. The `::` separates the namespace from its clause name.
The manifest defines the allowed values and locations; the ordinary clause
syntax still ends in `;`. `sharing(confined)` and `isolation(main)` remain
core facts about permitted use. The conformance fact describes a different
property and leaves those obligations in place ([C2](contracts.md#c2), [F1](#f1)).

A profile-defined type or constructor uses the same alias qualification where
a type or value is expected. [L4's type example](language.md#l4) shows that
form and its provider-support boundary. F1 defines no extra types, so a new
`fixture::SomeType` spelling would fail its vocabulary check. See the
[profile glossary entry](glossary.md#profile).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: a2-paths -->
<blockquote>

<a id="reading-aid-non-normative-read-one-declaration-with-two-ways-to-reach-it"></a>

**Reading aid (non-normative): read one declaration with two ways to reach it**

Counter has a member function that reads its count. A consumer can reach that
same operation by sending a message or by compiling a source call. Each
[access path](glossary.md#access-path) states the mechanism and the ABI that
makes it usable. Both paths implement the function's whole contract ([A2](#a2)).

Fragment — shows both paths inside `read_count`. The complete
[objects package](examples/objects.ail) supplies Counter, the provider pins and
`test` environment shown at [A1](#a1), publication, input/effect/outcome clauses
and deprecation. The names `objc_like` and `swift_like` describe synthetic
fixture paths; they establish no Objective-C or Swift production support.

<!-- ail-example: examples/rule-reading/providers.ail region=paths -->
```ail
package example::objects version "1" {
  fn read_count(receiver: Counter) -> u64 {
    available([test]);
    member(@Counter, instance);
    receiver($receiver);
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "currentCount");
      mapping(identity);
      compatibility(stable);
    }
    access swift_like in [test] {
      abi(native, "source");
      via(fixture, "source-call", "Outer.Counter.currentCount.get");
      mapping(identity);
      compatibility(source, "fixture-build");
    }
    // Deprecation, input, effects and outcome omitted.
  }
  // Header, provider pins, environment, Counter and publication context omitted.
}
```

`member(@Counter, instance)` associates the package-level function with Counter.
`receiver($receiver)` identifies an ordinary named parameter. The first path,
`objc_like`, applies in `[test]`, selects the `native` ABI's `"object-message"`
convention, and uses the `fixture` profile's `"message"` mechanism with selector
`"currentCount"`. F1's mapping makes the receiver implicit when sending that
message. It remains present in the semantic signature ([L5](language.md#l5),
[A2](#a2), [F1](#f1)).

The second path selects convention `"source"` and mechanism `"source-call"`.
Its identity string names the source getter; its compatibility clause names
the profile's build recipe. [A4](#a4) explains the conditions that recipe pins.
The consumer chooses a path explicitly; their order on the page expresses no
preference. Each path lists applicable environments, and the paths together
cover the declaration's availability ([A2](#a2)).

With `mapping(identity)`, the consumer follows this profile/ABI pair's rules
to pass the receiver and return the count while preserving the function's
contract. This correspondence between the declared values and the native call
is a [mapping](glossary.md#mapping). A profile needing adjustments can instead name
its recipe with `mapping(profileAlias, "mapping-id")` in the same position;
F1 defines only identity mapping. Native register splitting can preserve the
same semantic value, while hiding an observable success status changes the
operation being described. See [Mapping](glossary.md#mapping).

The simpler `position` example in [L2](language.md#l2) selects
`via(fixture, "symbol", "canvas_position")` with convention `"c"`.
The path's local name `direct`, the source spelling and the declaration's
identity each have their own role. Merely knowing the source name supplies
none of these access clauses.

[Access-path grammar and railroad view](reference/notation.md#access).

Take the `access` branch inside the [callable body track](reference/notation.md#callable)
for each of `read_count`'s two paths. The first `identifier` here is
`objc_like` or `swift_like`; the one after `[` is `test`. That first environment
has no bypass, so the list cannot be empty. The return track adds a comma
and another environment. Inside the braces, the clause track carries `abi`,
`via`, `mapping` and `compatibility` from the example.
The grammar permits any number of clauses; A2 requires
exactly one of each core access clause and checks the environment coverage.

The [grammar](grammar.ebnf)'s `access` production gives a local path name,
`in` and a nonempty environment list, then a clause block. [G3's access view](explanation/packages.md#reaching-the-code)
shows the Counter paths and provider relationships; the syntax view locates
their braces and clauses.

</blockquote>
<!-- /reading-aid -->

Every function requires one or more `access` blocks; each global and non-literal
constant does too. Callbacks instead require `callback_abi(abiAlias, "convention")`
and `representation(profileAlias, "kind")` in their declaration. A callable's
source spelling does not create an access path.

<!-- reading-aid: a2-callback -->
<blockquote>

<a id="reading-aid-non-normative-supply-the-representation-of-a-callable-value"></a>

**Reading aid (non-normative): supply the representation of a callable value**

An API can receive a callable value for later invocation. Its callback
declaration describes how that value is represented and entered. The synthetic
Handler uses `callback_abi(native, "c")` and
`representation(fixture, "closure")` in its declaration body
([A2](#a2), [F1](#f1)).

Fragment — shows the complete Handler declaration extracted from the
[callbacks package](examples/callbacks.ail). Its surrounding package supplies
F1's `native` and `fixture` aliases, `test`, the registration and Subscription
lifetime, and publication context.

<!-- ail-example: examples/callbacks.ail lines=19-37 -->
```ail
  callback Handler(value: u64) -> unit {
    available([test]);
    deprecated(no);
    sharing(shared);
    isolation(none);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    callback_abi(native, "c");
    representation(fixture, "closure");
    outcome handled {
      when(returned, any);
      meaning(success);
    }
  }
```

The representation kind `"closure"` is a provider-defined callable value with
saved captures. F1 specifies retention and release for stored values and no
separately visible context argument. [C6](contracts.md#c6) shows how `subscribe`
uses this type and describes the registration's schedule. The callback's
own declaration describes one invocation; its representation tells the tool
how to carry and call the value. See [Callback captures](glossary.md#callback-captures).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: a3-data -->
<blockquote>

<a id="reading-aid-non-normative-distinguish-a-stored-pointer-from-an-address-of-storage"></a>

**Reading aid (non-normative): distinguish a stored pointer from an address of storage**

To pass a `Geometry::Point` between caller and callee, a tool needs to know
where its `x` and `y` fields are stored. The record in [L2](language.md#l2)
declares their types and order. The selected ABI/profile supplies their native
offsets and the record's size and alignment. Those facts form part of its
[representation](glossary.md#representation) recipe. The provider supplies a
complete recipe for every type used at that access boundary, including the
operations needed to pass, copy, move and destroy its values ([A3](#a3)).

Data access also needs an explicit mechanism. The Counter package has two
pointer-valued declarations. One identifies the address of exported byte
storage; the other loads a pointer value stored in a global.

Fragment — shows the data access blocks from the complete
[objects package](examples/objects.ail), with other clauses omitted.
That package supplies provider pins, `test`, publication facts, mutability and
output contracts: both pointers borrow four binary bytes with region `static`
and no earlier invalidator.

<!-- ail-example: examples/rule-reading/providers.ail region=data -->
```ail
package example::objects version "1" {
  constant fixed_bytes: ptr<u8> {
    access direct in [test] {
      abi(native, "c");
      via(fixture, "address", "fixture_fixed_bytes");
      mapping(identity);
      compatibility(stable);
    }
    // Availability, sharing/isolation and output contracts omitted.
  }
  global pointer_value: ptr<u8> {
    access direct in [test] {
      abi(native, "c");
      via(fixture, "load", "fixture_pointer_value");
      mapping(identity);
      compatibility(stable);
    }
    // Availability, mutability, sharing/isolation and output contracts omitted.
  }
  // Header, provider pins, environment and publication context omitted.
}
```

`via(fixture, "address", "fixture_fixed_bytes")` supplies the address of the
byte storage. `via(fixture, "load", "fixture_pointer_value")` loads the pointer
held in the global. Both declarations have type `ptr<u8>`, so the mechanism
is a separate fact a consumer needs. [C7](contracts.md#c7) shows the global's
full local output contract, including the meaning of `$result` on a read.

A source expression would need a provider that explicitly defines evaluation,
ownership and effects. F1's `source-call` is a function mechanism; it does not
supply an arbitrary data-expression mechanism. Likewise, a value requiring
runtime metadata still needs a complete representation recipe even when its
native offsets are hidden ([A3](#a3), [F1](#f1)). See [Reaching the code](explanation/packages.md#reaching-the-code).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: a4-compatibility -->
<blockquote>

<a id="reading-aid-non-normative-state-which-definitions-can-be-used-together"></a>

**Reading aid (non-normative): state which definitions can be used together**

The two `read_count` paths at [A2](#a2) state different conditions for using
their representations. The message path's `compatibility(stable)` uses the
ABI entry's promised fixture domain. The source path's
`compatibility(source, "fixture-build")` instead ties use to one named build
recipe ([A4](#a4), [F1](#f1)).

Both clauses sit inside the same access blocks as `abi`, `via` and `mapping`.
For `"fixture-build"`, F1 requires `fixture-compiler` version `1` and compilation
against this package's source surface, with no additional dependencies or
options. That recipe supplies the conditions under which the compiler
establishes compatibility for the build. A consumer without that compiler
can decline the source path and still explain its contract.

An artifact-bound provider would use
`compatibility(artifact, "build-id")` in that clause position. Its resolution
set would need the named built artifact set's content identities and
representation manifest, including compiler/runtime requirements.
`"build-id"` here illustrates the argument position; it is not an F1 catalogue
entry or an actual resolved build. A compiler-version string alone supplies
less information than this artifact identity ([A4](#a4)).

These are three ways to define a [compatibility domain](glossary.md#compatibility-domain).
A `stable` claim needs a provider guarantee for every reachable type in its
domain; a `source` claim needs the complete recipe; an `artifact` claim needs
the identified artifact set. [The design choices explanation](explanation/choices.md)
discusses why native representations need this explicit boundary.

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: a5-views -->
<blockquote>

<a id="reading-aid-non-normative-keep-the-same-api-facts-in-different-presentations"></a>

**Reading aid (non-normative): keep the same API facts in different presentations**

A documentation renderer can explain the Store view as “the bytes remain usable
until Store destruction.” A binding generator needs the same fact when it
arranges access to that pointer. The [C1 fragment](contracts.md#c1) locates the
source clauses: `give($result, borrow(owner($store)))` and
`invalidated_by($result, [])` in the `viewed` outcome. A typed model or prose
view retains those facts and their connection to Store ([A5](#a5)).

Reordering independent `input`, `retain` and `valid` clauses in that callable
leaves the contract unchanged. Changing the returned `give` from a borrow to
`owned`, or adding an invalidating operation, changes facts that consumers
preserve. In a callable with several parameters, swapping their positions also
changes the signature. In Counter, both `objc_like` and `swift_like` remain
available alternatives even if one consumer chooses only the message path.
The local [access example](#a2) makes that choice inspectable.

Two documents can use different comments and navigation links while describing
the same API contract. A tool comparing their canonical models ignores those
differences. An authoring tool still preserves the comments and links when it
reads and writes a document, so the author keeps that material. Changing a
dependency digest or the order of record fields does change the semantic model.
For a list with set meaning, such as `available([test])`, the tool compares
member identities and rejects duplicates ([A5](#a5)).

A generator may be unable to preserve a callback or lifetime contract in its
target language even when the description is valid. It reports that binding
limitation separately from malformed AIL and explains any extra restrictions
it imposes. See [Consumer](glossary.md#consumer) and
[Validation](glossary.md#validation).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: f1-fixture -->
<blockquote>

<a id="reading-aid-non-normative-read-examples-within-their-supplied-provider-boundary"></a>

**Reading aid (non-normative): read examples within their supplied provider boundary**

The example packages use an invented provider so their contracts can be
inspected without assuming an operating-system implementation. The dependency
fragment at [A1](#a1) binds `fixture` to `"example.fixture"` version `"1"`
and `native` to `"example.fixture-abi"` version `"1"`. Its `a` and `b` digest
strings are special fixture-mode tokens. Ordinary digest checking still applies
to production resolution ([L2](language.md#l2), [F1](#f1)).

The examples on this page locate F1's mechanisms: Counter uses `message` and
`source-call` at [A2](#a2), while the two data declarations use `address` and
`load` at [A3](#a3). The canvas `position` fragment linked from A2 shows
`symbol`. These mechanism strings are arguments to `via`, and each has the
allowed declaration kind and convention stated in the table below. A plausible
new string would still be unsupported.

Counter's `fixture::sendability(nonconforming)` at [A1](#a1) records one
synthetic conformance state. The alternatives `available` and `unavailable`
describe two other states; none replaces core `sharing`. In that same object's
body, `fixture::actor("ui")` would state a source actor identity and require
matching `isolation(executor(fixture, "ui"))`. That is a hypothetical pair:
the actual Counter example uses `isolation(main)` and omits `fixture::actor`.
An explicit `fixture::actor(none)` instead pairs with `isolation(none)`.
F1 limits both profile clauses to the five nominal kinds listed below.

The callback example's `representation(fixture, "closure")` and Counter's
`runtime(fixture, "retain")`/`runtime(fixture, "release")` refer to this same
synthetic provider. [C2](contracts.md#c2) locates the runtime clauses, and
[C4](contracts.md#c4) shows its supported `utf-8` text encoding.
[The complete fixtures](conformance.md#positive-specifications) combine these
facts within F1's supported scope. Optional members, generic families or thrown
completion would require capabilities this catalogue does not supply; the
language's ability to spell them does not extend the catalogue.

</blockquote>
<!-- /reading-aid -->

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
