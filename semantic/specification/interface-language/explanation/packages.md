# Packages, environments and access paths

> **Purpose:** explanation — connect a [package](../glossary.md#package), its dependencies and access paths to the API model.
> **Reader:** language designers who have met [binding](../glossary.md#binding) obligations and AIL's contract [clauses](../glossary.md#clause).
> **Before this:** [A model of API behaviour and binding obligations](model.md) and [How AIL states a contract](contracts.md).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L2–L5`](../language.md#l2) and [`A1–A5`](../profiles.md#a1) are canonical; this page gives non-normative explanations.

In [The published description](model.md#description), the author
establishes which part and release of an API the account covers. Recall the
watch API: a description of `watch_view` also needs the watch type, its release
operation and the other definitions its contract refers to. The description
identifies those [declarations](../glossary.md#declaration), selects its
dependencies and states the exact configurations in which its claims hold
([`L2–L3`](../language.md#l2)).

[Reaching the code](model.md#access) adds the route from each operation to
its implementation. A tool calling `watch_view` needs both that route and
the machine-level rules for passing its values. The agreement among
[writers, checkers and users](model.md#agreement) keeps these facts connected:
the author supplies them, a checker assesses completeness and consistency,
and consumers retain them in the views they present
([`A1–A5`](../profiles.md#a1)).

This page shows how AIL records those description-layer facts. It starts
with the package that gathers them, then follows identity, scope,
environments, dependencies and access. By the end, you should be able to
trace the definitions a tool needs and distinguish a change of presentation
or calling mechanism from a change to the API contract.

The examples below describe invented APIs using
the synthetic fixture [profile](../glossary.md#profile), a versioned language
extension. The profile, [ABI](../glossary.md#abi) catalogue and [digest tokens](../glossary.md#digest-pin)
come from [`F1`](../profiles.md#f1). Names resembling Objective-C or Swift
illustrate possible mechanisms within this fixture; production support for
those languages remains future work.

The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows how a package reaches the tools that use it. This page looks inside the
package, then follows how a tool identifies and reaches an API operation.

## Packages contain declarations

To read [the published description](model.md#description), a tool needs to
locate each declaration and follow its references. AIL's language-containment
view supplies that organization: packages contain declarations, imports
connect packages, and callables own their slots. The geometry/canvas example
below shows how this text structure serves the description concept.

The invented geometry API describes a point. Its `language` header selects
AIL's version; `package` gives the API description its own name and version.
`Point` records the coordinates as two signed 32-bit integer fields. Those
fields describe [operations and their values](model.md#operations); the
package gives their declaration an identity that another description can
refer to ([`L1–L2`](../language.md#l1), [`L4`](../language.md#l4)).

Fragment — shows a package shell and record. Publication clauses, environments,
availability and nominal contracts are omitted.

<!-- ail-example: ../examples/rule-reading/geometry.ail -->
```ail
// Fragment: field structure only; no complete publication contract.
language "0.1";
package example::geometry version "1" {
  record Point {
    field x: i32;
    field y: i32;
    // Publication, environments and nominal contracts omitted.
  }
}
```

`Point` is [local](../glossary.md#local-and-imported-declaration) to
`example::geometry`: that package contains its definition.
A second package, `example::canvas`, needs points to describe a canvas's
position. It [imports](../glossary.md#import) geometry under the alias
`Geometry`. When reading the canvas package, `Geometry::Point` therefore names an imported type
([`L2`](../language.md#l2)).

The language-containment diagram details
[the published description](model.md#description): use it to locate each
declaration and callable slot within its package.
A [slot](../glossary.md#slot) names a parameter, result or declared
thrown value in a [callable's](../glossary.md#callable) signature.
`Canvas` illustrates [entities that outlive a call](model.md#entities): it is
an [opaque resource](../glossary.md#opaque-resource), a
[handle](../glossary.md#handle) with its own lifetime contract.
`position` receives that handle and returns a point. The diagram also shows
`Filter`, a [callback](../glossary.md#callback) that receives a point and
returns a Boolean; its
[declaration example](../language.md#reading-aid-non-normative-names-references-and-callable-slots)
uses the same import ([`L2`](../language.md#l2), [`L4`](../language.md#l4)).

![The canvas package contains Canvas, position and Filter; the geometry package contains Point. An import names geometry as Geometry. position and Canvas are sibling declarations joined by a member relation. Each callable contains its own parameter and result slots.](../figures/g9-model.svg)

**Reading key:** folders group declarations by package and version. Boxes
contain fields or signature slots. Labelled arrows connect packages through
imports and functions to their nominal owners through
[`member`](../glossary.md#member).
`position` and `Canvas` share the package folder; the member arrow
associates them. Follow the result type through `Geometry` to `Point`.
[Containment diagram source](../figures/g9-model.puml).

Fragment — shows the canvas import and member. The zero digest is a placeholder,
not the geometry document's hash. A complete package needs actual dependency
bytes and their digest, publication and environment clauses, the resource's
lifetime and other contracts, and the function's remaining effects, outcomes
and access paths.

<!-- ail-example: ../examples/rule-reading/canvas.ail region=model -->
```ail
language "0.1";
package example::canvas version "1" {
  import example::geometry version "1"
    digest "sha256:0000000000000000000000000000000000000000000000000000000000000000"
    as Geometry;
  resource Canvas {
    // Lifetime and other nominal contracts omitted.
  }
  fn position(canvas: Canvas) -> Geometry::Point {
    member(@Canvas, instance);
    receiver($canvas);
    input($canvas, borrow);
    retain($canvas, none);
    valid($canvas, call);
    // Effects, outcomes, access and publication context omitted.
  }
}
```

The `member` clause associates the package-level function `position` with
the local declaration `Canvas`; `@Canvas` selects that declaration as a clause
argument. `receiver($canvas)` chooses the ordinary parameter named `canvas`
as the instance receiver. Its [release responsibility](model.md#responsibility)
stays with the caller: `input` borrows it and `retain` promises no retention.
`valid` states its [validity](model.md#validity): the caller keeps it usable
for the call
([`L5`](../language.md#l5), [`C3`](../contracts.md#c3)).

Inside `position`, `$canvas` addresses its parameter value. From elsewhere in
the package, `@position::canvas` identifies that parameter slot and
`@position::result` identifies its result slot, whose type is `Geometry::Point`.
Each spelling has a containing context ([`L2`](../language.md#l2), [`C1`](../contracts.md#c1)):

| Spelling in the canvas package | Referent |
|---|---|
| `@Canvas`, `@position` | Local declarations |
| `@Geometry::Point` | The declaration in the imported geometry package |
| `@position::canvas`, `@position::result` | Parameter and result slots of `position` |
| `$canvas`, `$result` inside `position` | Values addressed locally by that function's clauses |
| `Canvas`, `Geometry::Point` in the signature | Types, written without `@` |

`@Geometry::Point` follows an import to a declaration; `@position::result`
follows a local callable to its result slot. Resolving the containing name
establishes which relationship applies. The similar spelling leaves that
work to the reader and to name resolution ([`L2`](../language.md#l2)).
For the exact forms, see the grammar reference's
[names and references](../reference/notation.md#names) and
[package shell](../reference/notation.md#shell).

## Four identities

The model separates [the published description](model.md#description) from
[reaching the code](model.md#access). To follow a contract through another
package or calling mechanism, identify which name denotes the declaration
and which selects its implementation or supporting definitions.

The canvas member's [canonical declaration identity](../glossary.md#canonical-identity) is
`(example::canvas, "1", position)`. The imported record's identity is
`(example::geometry, "1", Point)`. Renaming the alias `Geometry` to `Geo`
changes the canvas package's spelling for `Point`, while the record keeps its
defining package, version and declaration name ([`L2`](../language.md#l2)).

A binding generator also needs a way to reach code implementing `position`.
In this constructed extension of the example, the source declaration is named
`Canvas.position`, and a linker symbol named `canvas_position` exposes the call.
AIL gives those names different jobs ([`L5`](../language.md#l5),
[`A2`](../profiles.md#a2)).

Fragment — locates source and access names on the same canvas function.
The synthetic fixture profile and ABI catalogue interpret the displayed call.
A complete package would supply their pins, the `test` environment, imports,
`Canvas`, member and receiver clauses, and the remaining contracts. This is
not an additional complete conformance example.

<!-- ail-example: ../examples/rule-reading/canvas.ail region=spellings -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    source(fixture, "Canvas.position");
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "canvas_position");
      mapping(identity);
      compatibility(stable);
    }
    // Member, receiver and callable contracts omitted.
  }
  // Header, imports, providers, environment and Canvas omitted.
}
```

`source(fixture, "Canvas.position")` records the source declaration's name.
`access direct in [test]` names one way to call it in environment `test`.
Inside that block, [`via`](../reference/clauses-access.md#via) gives the profile's mechanism (`symbol`) and the
linker identity (`canvas_position`). [`abi`](../reference/clauses-access.md#abi) selects
[calling convention](../glossary.md#calling-convention) `c` within the
[ABI entry](../glossary.md#abi-entry) named `native`.
The aliases `fixture` and `native` select versioned
definitions, introduced under [dependencies](#what-it-depends-on).
[Reaching the code](#reaching-the-code) explains the four access clauses and
compares two paths for another API ([`A1–A2`](../profiles.md#a1)).

The four identities answer different questions:

| Identity | Question | Example |
|---|---|---|
| Semantic declaration | Which contract is this? | `(example::canvas, "1", position)` |
| [Source declaration](../glossary.md#source-identity) | Which source declaration does it describe? | `source(fixture, "Canvas.position")` |
| [Access path](../glossary.md#access-path) | Which named route reaches its code? | `direct`, using symbol `canvas_position` |
| [ABI](../glossary.md#abi) or profile selection | Which definitions interpret the names and call? | `native` selects the fixture ABI; `fixture` selects the fixture profile |

A source name identifies a declaration under a profile's rules. An access
path supplies the mechanism for reaching its implementation. A different
linker symbol could implement the same contract; it would be another access
identity, while the package/version/declaration tuple stays the same
([`L2`](../language.md#l2), [`A2`](../profiles.md#a2)).

AIL chooses explicit names over inferring identity and dispatch from source
spelling. The cost is more names to author and relate. The complete synthetic
[object example](../examples/objects.ail) illustrates the benefit with two
paths to one counter getter. Its names resembling Swift and Objective-C remain
synthetic; they establish no production support ([`F1`](../profiles.md#f1)).

## What a package claims

For [the published description](model.md#description), the reader's task is
to establish what the author claims to have described completely. The store
example makes that boundary visible: its byte-view operation needs the
store's lifetime API even when unrelated library features are left out.

An API author can begin with a small, usable part of a library. The synthetic
buffer package describes an immutable sixteen-byte store: creating it, viewing
or copying its bytes, and destroying it. The object package covers another
API: a reference-counted counter and its property. Each package's
[surface](../glossary.md#surface) says which subset and release the author
claims to describe ([`L3`](../language.md#l3)).

Fragment — shows the claimed surface and public declarations. The complete
[buffer package](../examples/buffers.ail) supplies those declarations, its
[environment](../glossary.md#environment), and the synthetic fixture profile,
catalogue and digest tokens.

<!-- ail-example: ../examples/concepts/packages.ail region=buffers-3 -->
```ail
package example::buffers version "1" {
  surface("A synthetic immutable sixteen-byte store and its complete lifetime API.");
  exports([@Store, @create, @destroy, @view, @copy_bytes, @store_lifetime]);
  // Header and remaining package context omitted.
}
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

This detail of [the published description](model.md#description) follows
a tool's reading from the public declarations to the further definitions
they need. A reference can lead to a private
declaration; the tool still uses its contract, while the declaration stays
private. The environment records the exact configuration where the contracts
apply. The dependency
selections tell the tool which package documents and definition manifests to
read; tooling supplies these before validation.

This is a schematic package structure. The committed fixtures define their
types locally, and the buffer fixture exports `destroy` itself. Boxes inside
the folder belong to the package; the labelled arrows connect facts about
them. Individual declaration clauses are outside this view.

![Start with the declarations listed in exports and follow their references to the definitions they need. Private support keeps its contract authority and stays private. Environments say where the contracts apply. Dependency selections identify other documents and manifests to read.](../figures/g2-package.svg)

[Package structure source](../figures/g2-package.puml) ·
[How tools use a published package](../README.md#who-writes-and-uses-an-ail-description)

## Where it holds

To apply [the published description](model.md#description), a reader needs
to match its claims to a configuration. Environments record that part of the
model; availability connects each declaration to the configurations it covers.

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

<!-- ail-example: ../examples/concepts/packages.ail region=buffers-7 -->
```ail
package example::buffers version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  resource Store {
    available([test]);
    // Other nominal contracts omitted.
  }
  // Header and remaining package context omitted.
}
```

Fragment — shows the object API's configuration, including its compiler. The
complete [object package](../examples/objects.ail) supplies its declarations
and synthetic fixture dependencies.

<!-- ail-example: ../examples/concepts/packages.ail region=objects-7 -->
```ail
package example::objects version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
    toolchain("fixture-compiler", "1");
  }
  object Counter {
    available([test]);
    // Other nominal contracts omitted.
  }
  // Header and remaining package context omitted.
}
```

Both authors used the local name `test`, but the second configuration includes
a toolchain value that the first omits. A tool comparing environments across
imports compares those configuration values. Sharing a local name is
insufficient to establish a match ([`L3`](../language.md#l3)).

Compare the configuration values behind the shared local name `test`; the
object package adds a compiler selection.

| Configuration entry | `example::buffers` | `example::objects` |
|---|---|---|
| Local environment name | `test` | `test` |
| Target | `fixture64` | `fixture64` |
| Platform and version | `fixture`, `1` | `fixture`, `1` |
| Toolchain and version | Omitted | `fixture-compiler`, `1` |

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

Dependencies connect [the published description](model.md#description) to
the definitions needed to interpret it. To inspect a contract across packages,
follow those selections to their exact contents. The profile and ABI selections
also supply the definitions used for [reaching the code](model.md#access).

Suppose an author puts the store declarations in one package and wants another
package to use them. The second package can [import](../glossary.md#import)
the first, selecting its package name, version and exact contents. The canvas
example uses the same arrangement for points:
`import example::geometry ... as Geometry` gives it the spelling
`Geometry::Point`. The store and counter conformance packages instead define
their types locally ([`L2`](../language.md#l2)).

The examples do share definitions for their extensions and machine-level
calling rules. `use profile` selects the fixture profile under the alias
`fixture`; `use abi` selects the ABI entry under `native`. These selections
give a tool the rules it needs to interpret clauses and prepare calls
([`L2`](../language.md#l2), [`A1`](../profiles.md#a1)).

Fragment — locates both provider selections inside the buffer package.
The complete [buffer package](../examples/buffers.ail) supplies the environment,
declarations and publication clauses. The repeated `a` and `b` digits are
F1's synthetic test tokens, distinct from the canvas import's zero placeholder.

<!-- ail-example: ../examples/concepts/packages.ail region=providers -->
```ail
package example::buffers version "1" {
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  // Header, environment, declarations and publication clauses omitted.
}
```

Later clauses use `fixture` and `native` to refer to the selected external
definitions. Each selection fixes an identifier, version and digest.
`use profile` and `use abi` select different kinds of
provider; `import` instead selects another API package
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

The pin table identifies which document a tool reads for each kind of
dependency and which bytes its digest fixes.

| Dependency | Identity selected | Bytes fixed by its digest |
|---|---|---|
| Imported package | Package name and version | Package document |
| Profile selection | Profile identifier and version | Profile provider manifest |
| ABI selection | ABI identifier and version | ABI provider manifest |

Two importing packages can use `Geometry` and `Geo` for the same geometry package
and select the same bytes. Their local spelling differs while their dependency
agrees. If they instead select different digests for that same package name
and version, a [consumer](../glossary.md#consumer) would receive two competing definitions of one
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

The model's [reaching the code](model.md#access) concept connects a declared
operation to a way of invoking it. To assess an access path, follow what the
consumer does and check that the path preserves the operation's contract.
The synthetic counter getter offers two routes for this comparison.

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

<!-- ail-example: ../examples/concepts/packages.ail region=objects-44 -->
```ail
package example::objects version "1" {
  fn read_count(receiver: Counter) -> u64 {
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
    // Input, effects and outcome omitted.
  }
  // Header and remaining package context omitted.
}
```

Read the first block as instructions to the consumer about the call. [`abi`](../reference/clauses-access.md#abi)
selects the `object-message` [calling convention](../glossary.md#calling-convention)
within the `native` [ABI entry](../glossary.md#abi-entry). [`via`](../reference/clauses-access.md#via) selects the
fixture's message mechanism and the selector `currentCount`. The [`mapping`](../reference/clauses-access.md#mapping)
clause connects the AIL signature to that mechanism. The [`compatibility`](../reference/clauses-access.md#compatibility)
clause states where the chosen [representations](../glossary.md#representation)
can be used together
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

This detail of [reaching the code](model.md#access) compares what a tool
does to call the same getter.
On the left it sends a message; on the right it compiles a source call.
Following either branch reaches the same `native` ABI entry, where the tool
reads the rules for that branch's calling convention. Both branches also use
the `fixture` profile to interpret their chosen mechanism. Their identity
mappings preserve the getter, including the conversion of its explicit
receiver to a message target on the left.

The message branch uses the fixture's stable compatibility guarantee. The
source branch uses the `fixture-build` recipe; separately built binaries need
their own guarantee. Both paths apply in `test`: target `fixture64`, platform
`fixture` version `1`, and toolchain `fixture-compiler` version `1`. The two
catalogues use the synthetic digest tokens introduced in
[What it depends on](#what-it-depends-on). Arrows connect
choices to definitions a tool reads. Path selection follows the consumer's
explicit choice or configuration policy; the picture gives neither branch
priority. Native calling algorithms are outside this view.

![Two ways to call synthetic read_count: send currentCount to the counter, or compile Outer.Counter.currentCount.get. Each preserves the whole getter contract. Both paths read one ABI entry, selecting different calling conventions, and use the fixture profile's mechanism definitions.](../figures/g3-access.svg)

[Access structure source](../figures/g3-access.puml) ·
[Package context](#what-a-package-claims) ·
[How tools use a published package](../README.md#who-writes-and-uses-an-ail-description)

For the exact block form, see
[access paths in the grammar reference](../reference/notation.md#access).
[`A2`](../profiles.md#a2) supplies the four required clauses and their
applicability rules.

Data access connects [entities that outlive a call](model.md#entities) and
their [storage](model.md#storage) to the implementation. To read a value,
the consumer needs an equally concrete action. The synthetic `fixed_bytes`
names an array: a consumer obtains the address of that array's storage.
`pointer_value` names a variable containing a pointer: a consumer reads the
pointer stored there. Both deliver `ptr<u8>`, but the consumer performs a
different action at the symbol in each case
([`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1);
[object example](../examples/objects.ail)).

Fragment — locates the two mechanisms on their data declarations. The complete
[object package](../examples/objects.ail) supplies static-borrow, extent,
contents and other output clauses, the three remaining clauses in each access
block, and the package context with synthetic providers.

<!-- ail-example: ../examples/concepts/packages.ail region=data-access -->
```ail
constant fixed_bytes: ptr<u8> {
  access direct in [test] {
    via(fixture, "address", "fixture_fixed_bytes");
    // ABI, mapping and compatibility omitted.
  }
  // Output and other constant clauses omitted.
}
global pointer_value: ptr<u8> {
  mutable(false);
  access direct in [test] {
    via(fixture, "load", "fixture_pointer_value");
    // ABI, mapping and compatibility omitted.
  }
  // Output and other global clauses omitted.
}
```

`constant` names a value; `global` names storage, even with `mutable(false)`.
Here both types are pointers to bytes. `address` obtains the array storage's
address, while `load` reads the pointer value held at its symbol. The chosen
mechanism tells the consumer which action supplies the value
([`L5`](../language.md#l5), [`C7`](../contracts.md#c7), [`A3`](../profiles.md#a3)).

Compare the action at each symbol: the same result type can come from taking
an address or loading a stored pointer.

| Synthetic declaration | Access obtains | Result type |
|---|---|---|
| `fixed_bytes` | The address of array storage | `ptr<u8>` |
| `pointer_value` | The pointer loaded from a variable | `ptr<u8>` |

## Profiles and ABI entries

For [reaching the code](model.md#access), a tool needs shared definitions of
the calling mechanism and value representations. The agreement among
[writers, checkers and users](model.md#agreement) extends to those definitions:
provider manifests specify the meanings a consumer needs to support.

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
complete validation. A syntax reader may preserve unsupported text while
leaving validation to a tool that understands the selected definitions
([`A1`](../profiles.md#a1)).

## The synthetic fixture

The agreement among [writers, checkers and users](model.md#agreement)
depends on interpreting the same definitions. Here, the reader's task is to
assess the examples under their declared test definitions and recognize the
limits of what those examples demonstrate about [reaching the code](model.md#access).

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

The model's [writers, checkers and users](model.md#agreement) share an
account of the API even when they use different presentations. To compare
those presentations, trace an obligation back to its declaration and check
which facts remain available.

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

Using one description lets binding generators and documentation tools work
from the same API facts. Each tool then keeps its presentation connected to
that complete description. Validation checks the description against the
language rules, regardless of which tool will use it. A binding generator may
still be unable to preserve a valid contract for its selected target,
environment and path. In that case it refuses to generate a binding; the
package remains valid AIL
([`A5`](../profiles.md#a5)).

Next: [Design choices, limits and open questions](choices.md).
Then write a complete package in [Describing a small API](../tutorial/README.md).
Return to [How AIL states a contract](contracts.md) for semantic obligations,
or [the overview](../README.md) for the document map.
