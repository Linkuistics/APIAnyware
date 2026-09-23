# Packages, environments and access paths

> **Purpose:** explanation — understand what a [package](../glossary.md#package) claims and how its operations reach code.
> **Reader:** language designers who have met [binding](../glossary.md#binding) obligations and AIL's contract [clauses](../glossary.md#clause).
> **Before this:** [Using an API across languages](unsaid.md) and [How AIL states a contract](contracts.md).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L2–L5`](../language.md#l2) and [`A1–A5`](../profiles.md#a1) are canonical; this page gives non-normative explanations.

An API author describing a byte-store library needs more than the contract of
`view`. A tool reading it also needs the `Store` type, the operation that
destroys a store, and a way to call each function. The author brings these
declarations together in a named, versioned [package](../glossary.md#package).
The package says which part of the API it describes and which configurations
it covers ([`L2–L3`](../language.md#l2), [`A2`](../profiles.md#a2)).

This page follows those connections. Its examples describe invented APIs using
the synthetic fixture [profile](../glossary.md#profile), a versioned language
extension. The profile, ABI catalogue and [digest tokens](../glossary.md#digest-pin)
come from [`F1`](../profiles.md#f1). Names resembling Objective-C or Swift
illustrate possible mechanisms within this fixture; production support for
those languages remains future work.

The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows how a package reaches the tools that use it. This page looks inside the
package, then follows how a tool identifies and reaches an API operation.

## Four identities

Suppose a binding generator is preparing a call to the synthetic counter's
`read_count`. The contract tells it to borrow a `Counter` receiver and return
an unsigned integer. The generator identifies that operation by its package,
version and declaration name. Together these form its
[canonical declaration identity](../glossary.md#canonical-identity)
([`L2`](../language.md#l2)).

To reach the implementation, the generator chooses one of two
[access paths](../glossary.md#access-path). The path named `objc_like` asks the
synthetic runtime to send the message `currentCount` to the receiver. The path
named `swift_like` asks a source compiler to build a call to
`Outer.Counter.currentCount.get`. Either path implements the same getter
contract ([`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

The package also records `Outer.Counter` as the type's
[source identity](../glossary.md#source-identity). A source identity connects
the AIL declaration to the declaration named in a source language. The access
path supplies the further information needed to use its implementation.
Finally, `fixture` and `native` select the definitions that tell tools how to
interpret these names and arrange the call ([`L5`](../language.md#l5),
[`A1–A2`](../profiles.md#a1)).

The getter separates four kinds of identity:

| Identity | What it identifies | Synthetic example |
|---|---|---|
| Semantic declaration | The operation or type in the contract | `example::objects`, version `1`, declaration `read_count` |
| [Source declaration](../glossary.md#source-identity) | A declaration as a source profile names it | `source(fixture, "Outer.Counter")` on `Counter` |
| [Access path](../glossary.md#access-path) | A named way to reach code, with its access identity | `objc_like` uses selector `currentCount`; `swift_like` uses source callable `Outer.Counter.currentCount.get` |
| [ABI](../glossary.md#abi) or profile selection | The versioned definition that interprets a path or source fact | `native` selects `example.fixture-abi` version `1`; `fixture` selects `example.fixture` version `1`, each with a synthetic digest token |

The synthetic [buffer example](../examples/buffers.ail) has a simpler case:
`view` has one path naming the linker symbol `fixture_store_view`. A tool can
therefore identify the operation as `view` while using a different name to
locate its code. In summary (non-normative), declaration identity tells tools
which contract they are using; an access path tells them how to reach code
that implements it ([`L2`](../language.md#l2), [`A2`](../profiles.md#a2)).

These distinctions let two access mechanisms implement one contract without
giving that contract two identities. AIL chooses explicit names over inferring
identity and dispatch from source spelling. The cost is more names to author
and relate. The synthetic getter illustrates the separation; its names do not
establish actual Swift or Objective-C support ([`F1`](../profiles.md#f1)).

## What a package claims

An API author can begin with a small, usable part of a library. The synthetic
buffer package describes an immutable sixteen-byte store: creating it, viewing
or copying its bytes, and destroying it. The object package covers a different
particular API: a reference-counted counter and its property. Each package's
[surface](../glossary.md#surface) says which subset and release the author
claims to describe ([`L3`](../language.md#l3)).

Fragment — shows the claimed surface and public declarations. The complete
[buffer package](../examples/buffers.ail) supplies those declarations, its
[environment](../glossary.md#environment), and the synthetic fixture profile,
catalogue and digest tokens.

<!-- ail-example: ../examples/buffers.ail lines=3-4 -->
```ail
  surface("A synthetic immutable sixteen-byte store and its complete lifetime API.");
  exports([@Store, @create, @destroy, @view, @copy_bytes, @store_lifetime]);
```

The `exports` list names the declarations the package presents publicly.
These [exports](../glossary.md#exports) are starting points for following the
contract's references. For example, a tool reading `view` encounters its
`Store` parameter. It reads `Store` to learn how ownership ends, then follows
the type's [lifecycle](../glossary.md#lifecycle) reference to `destroy`. Reading
only the function signature would leave the tool unable to explain how the
caller finishes with the store ([`L2–L3`](../language.md#l2), [`C2`](../contracts.md#c2)).

The tool continues following such references until it has every declaration
and pinned definition needed to interpret the exports. That complete set is
the [dependency closure](../glossary.md#dependency-closure). A support
declaration can belong to that set while remaining private. Its contract still
has authority, even though the author did not list it as a public starting
point. In the buffer fixture, `destroy` happens to be exported itself
([`L2–L3`](../language.md#l2)).

The author can leave an unrelated image API outside this store package. Leaving
out the store's destructor would remove information that an included operation
depends on. Completeness follows the declared subset and all of its dependencies.
Listing fewer exports helps only when the retained exports can still be
described completely ([`L3`](../language.md#l3)).

AIL chooses this boundary instead of requiring a whole library at once. It
lets authors publish a useful portion, at the cost of stating its scope
accurately and supplying every fact that portion needs.
[Validation](../glossary.md#validation) checks that the description is complete
and internally consistent. Comparing its scope and claims with the actual
library requires separate evidence ([`L3`](../language.md#l3)).

The package diagram makes export membership distinct from dependency
membership: referenced private support remains authoritative without becoming
a public root. It also locates exact environments and the package, profile and
ABI pins explained below. This is a schematic structure, not an additional
fixture package; the frozen examples define their types locally, and `destroy`
is itself exported. The view omits individual declaration clauses.

![A package contains a surface claim, exported roots, referenced private support and exact environments. Its pins select imported packages when needed and profile and ABI catalogue entries. Following references reaches the dependency closure without making every dependency an export.](../figures/g2-package.svg)

[Package structure source](../figures/g2-package.puml)

## Where it holds

An author may have established the contract for platform version `1`. Readers
need to know that this is the configuration being described; later versions
may change the API or require separate investigation. An
[environment](../glossary.md#environment) records the exact configuration to
which the package's claims apply ([`L3`](../language.md#l3)).

The synthetic buffer package names its target and platform below. The object
package also names a toolchain, because its source-call path uses a compiler.

Fragment — shows the buffer API's configuration. The complete
[buffer package](../examples/buffers.ail) supplies its declarations and
synthetic fixture dependencies.

<!-- ail-example: ../examples/buffers.ail lines=7-10 -->
```ail
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
```

Fragment — shows the object API's configuration, including its compiler. The
complete [object package](../examples/objects.ail) supplies its declarations
and synthetic fixture dependencies.

<!-- ail-example: ../examples/objects.ail lines=7-11 -->
```ail
  environment test {
    target("fixture64");
    platform("fixture", "1");
    toolchain("fixture-compiler", "1");
  }
```

Both authors used the local name `test`, but the second configuration includes
a toolchain value that the first omits. A tool comparing environments across
imports compares those configuration values. Sharing a local name is
insufficient to establish a match ([`L3`](../language.md#l3)).

Within a package, a declaration uses `available([test])` to say it is offered
in that named environment. This is its [availability](../glossary.md#availability).
Suppose `view` is offered in two environments. Its `Store` parameter and the
declarations it needs must be available wherever that use occurs. If the
signature or contract changes between configurations, the author gives the
variants distinct declarations with disjoint availability, or distinct
identities ([`L3`](../language.md#l3)).

An unlisted configuration remains outside the claim: the package leaves open
whether the API exists there. Version ranges would be an alternative way to
describe coverage. AIL's exact list gives tools a finite set of configurations
against which to check references and access paths, at the cost of enumerating
them. Its practicality for a large platform matrix remains a design question
([`L3`](../language.md#l3)).

Availability also serves a different purpose from checking an optional member
on a particular object. The platform may offer an interface while that object
omits one optional operation. Before invoking it, a caller needs the
profile-defined capability test for the receiver ([`C3`](../contracts.md#c3)).

## What it depends on

Suppose an author puts the store declarations in one package and wants another
package to use them. The second package can [import](../glossary.md#import)
the first, selecting its package name, version and exact contents. An alias
such as `StoreAPI` then lets the author refer to `StoreAPI::Store`. This is a
constructed arrangement; the committed synthetic examples define their types
locally ([`L2`](../language.md#l2)).

The examples do share definitions for their extensions and machine-level
calling rules. `use profile` selects the fixture profile under the alias
`fixture`; `use abi` selects the ABI entry under `native`. These selections
give a tool the rules it needs to interpret clauses and prepare calls
([`L2`](../language.md#l2), [`A1`](../profiles.md#a1)).

Version names alone leave room for different contents to appear under the same
name. A digest pin identifies the exact bytes the author selected. For an
import, those bytes are the package document. For a profile or ABI entry, they
are its provider manifest, the document defining that provider's rules
([`L2`](../language.md#l2)).

Before validation, tooling supplies the dependency documents and manifests
explicitly. This supplied collection is the
[resolution set](../glossary.md#resolution-set). A validator looks up each
selection there and checks the digest. Missing documents or mismatching bytes
prevent successful resolution; validation performs no implicit download or
execution of provider code ([`L2`](../language.md#l2)).

The pin table separates an author's local alias from the identity and bytes
that every consumer resolves.

| Dependency | Identity selected | Bytes fixed by its digest |
|---|---|---|
| Imported package | Package name and version | Package document |
| Profile selection | Profile identifier and version | Profile provider manifest |
| ABI selection | ABI identifier and version | ABI provider manifest |

Two importing packages can use different aliases for the same store package
and select the same bytes. Their local spelling differs while their dependency
agrees. If they instead select different digests for that same package name
and version, a consumer would receive two competing definitions of one
identity. Renaming an alias leaves that conflict in place.

In summary (non-normative), each package name and version resolves to one
digest throughout the dependency closure. The same consistency rule applies
separately to profile and ABI identities. Imports also form an acyclic graph:
following imports cannot lead back to the package where the chain began
([`L2`](../language.md#l2); mutations N28–N29 in the
[conformance corpus](../conformance.md#rejection-mutations)).

AIL chooses exact pins and explicit resolution over implicit discovery of a
locally installed version. This makes dependency selection inspectable, at the
cost of preparing the complete resolution set and updating pins when bytes
change. A digest establishes byte identity, not trust in the author; installation
and trust remain tooling decisions ([`L2`](../language.md#l2)).

## Reaching the code

To call `read_count`, a binding generator first needs a mechanism that reaches
the getter. In the message path, generated code sends `currentCount` to the
counter through the synthetic runtime. In the source path, a compiler builds
code that calls `Outer.Counter.currentCount.get`. The blocks below tell the
generator which definitions govern each choice ([`A2`](../profiles.md#a2),
[`F1`](../profiles.md#f1)).

Both paths keep the getter's contract. The caller enters on the main thread,
passes a [borrowed](../glossary.md#borrow) receiver and receives a readable
`u64` result. Borrowing leaves the caller's ownership obligation in place; it
does not imply Rust's static borrow checking. Choosing a path changes the
calling mechanism while preserving those obligations
([`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

Fragment — shows the getter's two call paths. The complete
[object package](../examples/objects.ail) supplies `read_count` and its contract,
plus the synthetic fixture profile, catalogue and digest tokens.

<!-- ail-example: ../examples/objects.ail lines=44-55 -->
```ail
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
```

Read the first block as instructions to the consumer about the call. `abi`
selects the `object-message` [calling convention](../glossary.md#calling-convention)
within the `native` [ABI entry](../glossary.md#abi-entry). `via` selects the
fixture's message mechanism and the selector `currentCount`. The `mapping`
clause connects the AIL signature to that mechanism, and `compatibility`
states where the chosen representations can be used together
([`A2`](../profiles.md#a2), [`A4`](../profiles.md#a4)).

The second block selects a source call instead. Its compatibility clause
names `fixture-build`, the recipe that lets a compiler build that call.
The table collects the four facts (non-normative summary):

| Clause | Question answered | Difference between these paths |
|---|---|---|
| `abi` | Which [ABI entry](../glossary.md#abi-entry) and [calling convention](../glossary.md#calling-convention) govern the call? | `object-message` versus `source`, within the synthetic `native` entry |
| `via` | Which profile mechanism and identity reach the code? | An exact selector versus a source callable spelling |
| `mapping` | How does the semantic signature become that call? | Both use the [provider](../glossary.md#provider)'s faithful identity [mapping](../glossary.md#mapping); message dispatch makes the receiver implicit |
| `compatibility` | In which [compatibility domain](../glossary.md#compatibility-domain) can the [representation](../glossary.md#representation) be used? | The synthetic ABI's stable domain versus the pinned `fixture-build` source recipe |

A [mapping](../glossary.md#mapping) tells the consumer how the declared values
become a call through the selected mechanism. For the message path, AIL names
`receiver` as an explicit parameter, while the runtime treats it as the object
receiving the message. The fixture defines how to make that conversion, so
`mapping(identity)` preserves the declared operation even though the physical
argument list changes ([`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

For a more involved call, a mapping may also need to account for a callback's
context pointer or native error-output storage. In summary (non-normative),
it accounts for each parameter, result, auxiliary argument and
[completion](../glossary.md#completion) mode exactly once. If a convenience
wrapper hides a meaningful success status, callers observe a different
operation. AIL gives that operation a distinct declaration ([`A2`](../profiles.md#a2)).

A consumer selects a path explicitly or through a configuration policy. The
first block in the document has no special priority. Each available environment
needs at least one path, and every selected path implements the whole contract.
This lets consumers use alternative mechanisms, at the cost of choosing among
them. Inferring one route from the source spelling would make that choice
implicit ([`A2`](../profiles.md#a2)).

The caller and implementation also need compatible representations of the
values they exchange. With `stable`, the provider guarantees compatibility
over a specified set of circumstances. That set is its
[compatibility domain](../glossary.md#compatibility-domain). With `artifact`,
the path instead selects particular built artifacts and their representation
manifest from the supplied resolution set. Naming a compiler version alone
leaves those artifacts unidentified ([`A4`](../profiles.md#a4)).

With `source`, the consumer uses a fully specified build recipe. It identifies
the source dependencies, compiler, options, interfaces and build procedure.
The compiler establishes compatibility for that build. Separately built
binaries need their own compatibility guarantee ([`A4`](../profiles.md#a4)).

The access diagram shows two alternatives converging on the same synthetic
ABI entry while choosing different conventions. Both use the synthetic
fixture profile and identity mapping, and both implement the whole getter
contract. Their `test` environment is `fixture64`, platform `fixture` version
`1`, with `fixture-compiler` version `1`; their catalogue selections use the
synthetic digest tokens described below. This view zooms into access selection
and omits native calling algorithms. Arrow order is not a selection policy.

![Synthetic read_count offers objc_like via currentCount and swift_like via Outer.Counter.currentCount.get. Both select native, the synthetic example.fixture-abi version 1 entry, with object-message or source convention respectively; both use fixture profile mechanisms. The first uses the stable fixture domain, the second the fixture-build source recipe.](../figures/g3-access.svg)

[Access structure source](../figures/g3-access.puml)

Data access needs an equally concrete action. The synthetic `fixed_bytes`
names an array: a consumer obtains the address of that array's storage.
`pointer_value` names a variable containing a pointer: a consumer reads the
pointer stored there. Both deliver `ptr<u8>`, but the consumer performs a
different action at the symbol in each case
([`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1);
[object example](../examples/objects.ail)).

The access mechanism tells the consumer which of these actions to perform.

| Synthetic declaration | Access obtains | Result type |
|---|---|---|
| `fixed_bytes` | The address of array storage | `ptr<u8>` |
| `pointer_value` | The pointer loaded from a variable | `ptr<u8>` |

## Profiles and ABI entries

For the message call above, a tool needs a definition of what the selector
means and how the receiver participates. The synthetic profile supplies those
rules. It also needs to know how object references are represented and passed
at the machine boundary. The synthetic ABI entry supplies those rules.
A [provider](../glossary.md#provider) supplies a definition and tooling support
for interpreting or implementing it ([`A1`](../profiles.md#a1),
[`F1`](../profiles.md#f1)).

A provider records its definition in a manifest. For a profile clause, a
reader needs to learn what the clause means, which arguments it takes, where
it applies and which other clauses it requires. Tool implementers also need
rules for checking it and preserving its meaning in a machine view or printed
document. The manifest supplies these, along with exact source-name and
environment interpretation. [`A1`](../profiles.md#a1) lists its required
contents.

An ABI manifest covers the mechanics of passing values and entering calls.
For example, it defines record layout as well as parameter passing, and
[callback](../glossary.md#callback) entry as well as ordinary calls. It states
the environments and runtime facilities those mechanics require
([`A1`](../profiles.md#a1)).

Consider a record with an integer followed by a pointer. Its field list tells
tools which values it holds and in what order. The selected provider supplies
the sizes, alignment and offsets needed to pass the record to code. These
facts form its [representation](../glossary.md#representation). A package
references the definition; tooling may implement it with a compiler or runtime.
For each reachable nominal type at a boundary, validation requires one complete
applicable recipe and rejects conflicting recipes ([`A1`](../profiles.md#a1),
[`A3`](../profiles.md#a3)).

The alternative is to put every runtime mechanism in the core. Profiles keep
those definitions separate, at the cost of additional dependencies and uneven
consumer support. A consumer identifies unsupported dependencies before claiming
complete validation. A syntax reader may preserve unsupported text without
calling it a validated authoritative model ([`A1`](../profiles.md#a1)).

## The synthetic fixture

The examples need a concrete interpretation so that their contracts can be
inspected. [`F1`](../profiles.md#f1) defines a synthetic fixture profile and ABI
catalogue for that purpose. Compare its synchronous symbol call in `view` with
its source-build getter in `read_count`: both have defined mechanisms. Merely
changing a fixture call to `execution(async)` needs additional semantics that
this synthetic profile does not supply ([`C3`](../contracts.md#c3),
[`F1`](../profiles.md#f1); mutation N30).

The fixture defines an abstract test environment: target `fixture64`, platform
`fixture` version `1`, and optionally `fixture-compiler` version `1`. Its
pointers, [handles](../glossary.md#handle) and object references are 64 bits.
Those sizes are facts about this test provider ([`F1`](../profiles.md#f1)).

The fixture also defines how a stored callback can retain its state. Its
representation supports [retention](../glossary.md#retention) with no separately
visible context argument. A registration call can finish synchronously while
the registered callback starts later. The callback's schedule states that
permission and its teardown boundary ([`F1`](../profiles.md#f1),
[`C6`](../contracts.md#c6)).

The synthetic digest tokens are `sha256:` followed by 64 `a` digits for the
profile and 64 `b` digits for the ABI. They are test resolution tokens, not
hashes of these Markdown files. Outside fixture mode, ordinary digest resolution
rejects them unless real manifests happen to hash to them; fixture mode cannot
publish production packages ([`L2`](../language.md#l2), [`F1`](../profiles.md#f1)).

Using a synthetic catalogue instead of a production provider isolates the
contract examples, at the cost of demonstrating no real platform interoperability.
The [conformance record](../conformance.md#verification-record) reports historical
static checks; it supplies no runnable native implementation.

## One contract, several views

A documentation reader and a machine consumer need different presentations of
the same facts. For the synthetic `view`, prose can say that the caller borrows
sixteen bytes while keeping the store alive. A machine view can instead expose
`owner: "store"` alongside length, transfer and invalidator fields. The
[two-view example](../conformance.md#two-views-of-one-contract) shows both and
keeps a reference to the complete declaration.

Each presentation is a [projection](../glossary.md#projection): it organizes
the contract for a particular reader or tool. A short lifetime paragraph can
focus on `owner($store)` while linking to the rest of `view`. The complete
description still includes which configurations offer the operation, all its
outcomes, and how to call it. AIL requires consumers to retain access to those
facts, whichever format they present ([`A5`](../profiles.md#a5)).

A target-language wrapper might impose an extra restriction because of its
own implementation. For example, it could serialize access more strictly than
the API requires. The consumer labels that as its own restriction and keeps
the actual API permission available to readers. This lets the same package
support different consumers without changing the contract they describe
([`A5`](../profiles.md#a5), [`C8`](../contracts.md#c8)).

Moving `view` before `destroy` in a document leaves the meaning unchanged.
Swapping two parameters changes which value each argument position supplies.
AIL's definition of model equality therefore ignores declaration order but
preserves parameter order. It also preserves the selected dependency pins and
the distinctions between outcomes ([`A5`](../profiles.md#a5)).

Comments and navigation links help authors work with a document even though
they are outside semantic equality. A tool reading and printing a document
for further editing preserves them too. The draft defines these preservation
obligations while leaving canonical byte serialization unspecified
([`A5`](../profiles.md#a5);
[round-trip obligations](../conformance.md#parser-validator-and-round-trip-obligations)).

One authority avoids separately maintained binding and prose contracts, at the
cost of retaining connections from each convenient view to the complete facts.
Validation remains consumer-independent. A binding generator may still refuse a
valid package when it cannot preserve the contract for its selected target,
environment and path; that limitation is distinct from invalid AIL
([`A5`](../profiles.md#a5)).

Next: [Design choices, limits and open questions](choices.md).
Then write a complete package in [Describing a small API](../tutorial/README.md).
Return to [How AIL states a contract](contracts.md) for semantic obligations,
or [the overview](../README.md) for the document map.
