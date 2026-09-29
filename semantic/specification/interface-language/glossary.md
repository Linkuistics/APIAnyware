# Glossary

> **Purpose:** reference — understand a domain term and find the rules that use it.
> **Reader:** language designers new to API binding, and readers looking up AIL terms.
> **Before this:** nothing; [Using an API across languages](explanation/unsaid.md) introduces the domain.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L1–L6`](language.md#l1), [`C1–C8`](contracts.md#c1) and [`A1–A5`](profiles.md#a1) are canonical; these entries are non-normative summaries.

Each alphabetical entry explains a term, illustrates its use and links to a
fuller explanation and the relevant rules. The watch examples refer to the
invented API in [Using an API across languages](explanation/unsaid.md); other
small examples illustrate possible contracts. They are reading aids rather
than additional fixture definitions. Terms such as [FFI](#ffi) describe the
domain; terms such as [clause](#clause) also name parts of AIL's notation.

The [API model](explanation/model.md) connects the concepts these terms name.
The notation examples illustrate [Operations and their values](explanation/model.md#operations)
and [The published description](explanation/model.md#description).
They use the same invented geometry and canvas packages as
the [language-containment view and reading aids](language.md#l2). Read that view
from packages to their declarations, then to a function's parameters and result.
For the surrounding document syntax, see the
[package shell](language.md#l1). Each fragment below
names what it omits; none supplies a new complete API contract.

## ABI

An application binary interface specifies how values and calls cross a machine
boundary. Caller and callee need to agree on argument passing, value layout
and runtime requirements. For example, agreeing where a record argument goes
is useful only if both sides also agree where its fields are stored. A
[calling convention](#calling-convention) supplies the call protocol within
this larger definition. An AIL [package](#package) selects an ABI definition
supplied by tooling.

Model: [Reaching the code](explanation/model.md#access).

See [Reaching the code](explanation/unsaid.md#reaching-the-code).
Rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).

## ABI entry

An ABI entry is a named, versioned definition of calling conventions and
[representations](#representation) that a package can select from a
[provider's](#provider) catalogue. The package selects it by identifier,
version and [digest pin](#digest-pin); a tool uses it to determine how
to pass values and make calls in the selected environment. A compiler version
alone supplies too little information to establish those compatibility rules.

Model: [Reaching the code](explanation/model.md#access).

See [Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries).
Rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).

## Access path

An access path describes how a tool reaches a declaration's code or data.
For example, a function path might name a linker symbol, while a method path
might identify a runtime message. Each path states its applicable
[environments](#environment), ABI, mechanism, [mapping](#mapping) and
[compatibility domain](#compatibility-domain). The source name identifies the
source declaration; the access path supplies the additional facts needed to
reach its implementation.

Model: [Reaching the code](explanation/model.md#access).

See [Reaching the code](explanation/packages.md#reaching-the-code).
Rule: [`A2`](profiles.md#a2).

## Availability

Availability lists the exact declared environments in which an API declaration
is offered. A tool compares those configuration values when resolving a
reference. An optional interface member also requires a runtime capability
test on the particular receiver: being available on the platform and being
implemented by that receiver are separate conditions.

Model: [The published description](explanation/model.md#description).

See [Where it holds](explanation/packages.md#where-it-holds).
Rules: [`L3`](language.md#l3), [`C3`](contracts.md#c3).

## Binding

An API binding makes an API offered in one language usable from another.
It arranges calls and presents values while preserving the API's obligations
and observable results. For a borrowed byte view, that includes respecting how
long the bytes stay usable. A generator needs the capabilities to preserve
those obligations; a valid AIL description can still exceed what a particular
generator or target language supports.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [Using an API across languages](explanation/unsaid.md).
Relevant rule: [`A5`](profiles.md#a5).

## Binding contract

A binding contract states what callers provide and what the API implementation
promises. For a watch API, it might require the caller to keep callback state
alive and promise that closing the watch waits for callbacks to finish. The
contract includes ownership, validity, [outcomes](#outcome),
[callbacks](#callback) and [concurrency](#concurrency), alongside declarations.

Model: [A model of API behaviour and binding obligations](explanation/model.md).

See [Using an API across languages](explanation/unsaid.md).
Rules: [`C1–C6`](contracts.md#c1), [`A5`](profiles.md#a5).

## Borrow

A borrow grants access for a stated period while leaving the ownership
obligation with its existing holder. If `watch_view` borrows its watch argument,
the caller remains responsible for closing that watch. The validity
[region](#region) says how long the recipient may use the reference. AIL's term
describes the contract; it does not imply Rust's exclusivity rules or static
borrow checking.

Model: [Release responsibility](explanation/model.md#responsibility).

See [Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Rules: [`C1`](contracts.md#c1), [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).

## Borrow validity

Borrow validity describes how long borrowed access remains usable. A view's
bytes might remain usable until the watch is closed, or until an earlier
refresh replaces them. Its [region](#region) sets the lifetime bound and any
[invalidation](#invalidation) can end usability earlier. The pointer can still
hold a non-null address after that access has become invalid.

Model: [Validity](explanation/model.md#validity).

See [How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view).
Rules: [`C1`](contracts.md#c1), [`C5`](contracts.md#c5).

## Buffer extent

Buffer extent describes the storage reached through a pointer. It states
that the pointer addresses one element, or gives a buffer's initialized length,
allocated capacity and units. If capacity is eight bytes and length is three,
the caller can read three initialized bytes; the remaining capacity is
allocated space. The contents contract separately accounts for a text
terminator where one is required.

Model: [Storage](explanation/model.md#storage).

See [How many bytes exist, and what do they contain?](explanation/unsaid.md#how-many-bytes-exist-and-what-do-they-contain).
Rule: [`C4`](contracts.md#c4).

## Callable

Model: [Operations and their values](explanation/model.md#operations).

A callable declaration describes one invocation: named parameters, a result,
an optional thrown value and the conditions of the call. A function describes
an operation the program calls; a [callback](#callback) describes an invocation
the API makes through a supplied value.

In the following example, `example::canvas` defines a local resource type
named `Canvas`, an opaque handle for working with a canvas. It imports
`example::geometry` under the alias `Geometry`; that package defines `Point`,
a record with integer coordinates `x` and `y`. The function `position` accepts
a canvas handle and returns its position as a point.

Fragment — shows the `position` function in the invented canvas package. The
header, import, `Canvas` declaration, publication context and other callable
contracts are omitted. The [two-package example](language.md#l2) supplies the
declaration and import context.

<!-- ail-example: examples/rule-reading/glossary.ail region=callable -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    execution(sync);
    // Member, input, remaining effects, outcomes and access omitted.
  }
  // Header, Geometry import, Canvas and publication context omitted.
}
```

`fn` introduces the function named `position`. In its parentheses,
`canvas: Canvas` gives the parameter name and its type; `-> Geometry::Point`
gives the result type from the package imported as `Geometry`. Type names
appear without `@`. The function's braces enclose clauses describing its
invocation. Here `execution(sync);` says that the invocation completes before
control returns to the caller. It makes no promise that the call eventually
finishes. The parameter and result are its [slots](#slot).

See [names, references and callable slots](language.md#reading-aid-non-normative-names-references-and-callable-slots),
including the callable railroad and the contrasting `Filter` callback.
Rules: [`L2`](language.md#l2), [`L5`](language.md#l5), [`C3`](contracts.md#c3).

## Callback

A callback is a callable value supplied for the API to invoke. A program might
pass `notice` when opening a watch so the library can report events. The
callback declaration describes one invocation: its arguments, results and
obligations. The schedule stated where the callback is registered describes
when invocations may start, how many may occur and when they have all finished.

Model: [Callbacks and their schedules](explanation/model.md#callbacks).

See [A small API](explanation/unsaid.md#a-small-api) and
[callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state).
Rules: [`C2–C3`](contracts.md#c2), [`C6`](contracts.md#c6).

## Callback captures

Callback captures are the saved state a callback needs when invoked. For
`notice`, the context pointer can lead to the program state that should receive
the event. That state needs to remain usable for every permitted invocation.
The normative text also uses “closure” for this captured environment;
[dependency closure](#dependency-closure) names a different relationship.

Model: [Callbacks and their schedules](explanation/model.md#callbacks).

See [callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state).
Rules: [`C2`](contracts.md#c2), [`C6`](contracts.md#c6).

## Caller and callee

The caller invokes an operation; the callee implements that invocation. When a
program calls `watch_open`, the program is the caller and the library function
is the callee. When the library invokes `notice`, the library becomes the
caller and the supplied function is the callee. Input and output obligations
are read from the perspective of the particular invocation.

Model: [Operations and their values](explanation/model.md#operations).

See [A small API](explanation/unsaid.md#a-small-api).
Rules: [`C3`](contracts.md#c3), [`C5–C6`](contracts.md#c5).

## Calling convention

A calling convention specifies the protocol for entering a callable and
passing its arguments and results, within an [ABI](#abi). It can determine
where the caller places an argument for the callee to receive it. The wider ABI
also defines representations and runtime requirements, so matching convention
names alone cannot establish compatibility.

Model: [Reaching the code](explanation/model.md#access).

See [Reaching the code](explanation/unsaid.md#reaching-the-code).
Rules: [`A1–A2`](profiles.md#a1).

## Canonical identity

Model: [The published description](explanation/model.md#description).

A declaration's canonical identity is its package name, package version and
local declaration name. Tools use that combination to identify the declaration
unambiguously, even when another package uses the same local name. Overloads
also have distinct local declaration names. Source spellings and access-path
names describe other aspects of the API and keep their own identities.

Fragment — locates `Point` in a named package. Publication clauses,
environments, availability and nominal contracts are omitted.

<!-- ail-example: examples/rule-reading/geometry.ail -->
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

For this record, the three identity values are
`(example::geometry, "1", Point)`: the package name before `version`, the
version string and the declaration name after `record`. The parentheses here
display an identity tuple in prose; they are not an AIL clause. A `Point`
declared in `example::canvas` would have a different identity. Importing this
record under the alias `Geometry` gives it a spelling in the importing package
while preserving its identity in `example::geometry`; see
[local and imported declarations](#local-and-imported-declaration).

See [the two-package language-containment view](language.md#l2) and
[Four identities](explanation/packages.md#four-identities).
Rule: [`L2`](language.md#l2).

## Cardinality

Cardinality states how many participants a [pattern role](#role) accepts:
exactly one, zero or one, zero or more, or one or more. A role for a unique
destructor, for example, can require one operation. Callback invocation count
answers a separate question about how often a registered callback runs.

Model: [Entities that outlive a call](explanation/model.md#entities).

See [Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns).
Rule: [`L6`](language.md#l6).

## Clause

Model: [Operations and their values](explanation/model.md#operations).

A clause states a fact using the form `name(arguments);`. For example, a
callable's `execution(sync);` clause says that the invocation completes before
control returns to the caller; it makes no promise that the call eventually
finishes. The rule files define each clause's arguments, meaning and permitted locations.
A parser recognizes the common shape; validation checks whether the named
clause is recognized and used correctly there.

Fragment — locates one clause inside `position`. The header, import, `Canvas`,
publication context and remaining callable contract are omitted.

<!-- ail-example: examples/rule-reading/glossary.ail region=callable -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    execution(sync);
    // Member, input, remaining effects, outcomes and access omitted.
  }
  // Header, Geometry import, Canvas and publication context omitted.
}
```

Here `execution` names the fact, `sync` is its argument, the parentheses
enclose that argument and the semicolon ends the clause. The enclosing
function says which invocation it describes. In contrast, a package-level
`exports` clause lists public declarations; the [package example](#package)
shows that containing scope. Follow the
[clause railroad](language.md#reading-aid-non-normative-clauses-contain-values)
to see how arguments fit inside the common syntax.

See [From signature to contract](explanation/contracts.md#from-signature-to-contract)
and [One clause syntax](explanation/choices.md#one-clause-syntax-with-a-closed-vocabulary-in-prose).
Rules: [`L1`](language.md#l1), [`L5`](language.md#l5), [`C3`](contracts.md#c3).

## Closure

The normative text uses “closure” in two senses. A package's
[dependency closure](#dependency-closure) includes everything reached by
following its dependencies. A callback's closure is its
[captured environment](#callback-captures), the saved state used during an
invocation. These explanations qualify the word so readers can tell which
relationship a passage describes.

Model: [The published description](explanation/model.md#description) and [Callbacks and their schedules](explanation/model.md#callbacks).

Rules: [`L2–L3`](language.md#l2), [`C2`](contracts.md#c2).

## Compatibility domain

A compatibility domain states the conditions under which an access path's
representations can be used together. A provider might guarantee compatibility
throughout an ABI entry's stable domain; another path might be tied to particular
built artifacts or a named source-build recipe. A stable calling-convention
name is only one fact within that larger guarantee.

Model: [Reaching the code](explanation/model.md#access).

See [Reaching the code](explanation/packages.md#reaching-the-code).
Rule: [`A4`](profiles.md#a4).

## Completion

A completion is a way an invocation finishes: returned, thrown, cancelled or
terminated. Within a returned completion, separate [outcomes](#outcome) can
distinguish a successful non-null result from a null failure. Listing completion
modes describes possible finishes; it supplies no promise that the call will
eventually finish.

Model: [How a call finishes](explanation/model.md#outcomes).

See the callable-effects definition in [`C3`](contracts.md#c3) and
[Every way a call can end](explanation/contracts.md#every-way-a-call-can-end).
Outcome rule: [`C5`](contracts.md#c5).

## Concurrency

Concurrency describes whether independent calls or callback invocations may
overlap under the declared access constraints. A watch might permit calls from
several threads but require callers to serialize access. Another API might
permit independent overlapping calls. Entry executor and nested
[re-entrancy](#re-entrancy) are separate conditions that callers also follow.

Model: [Where and when calls run](explanation/model.md#execution).

See [Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where).
Rules: [`C3`](contracts.md#c3), [`C6`](contracts.md#c6).

## Consume

To consume an input is to transfer one [owned](#owned) obligation from caller
to callee at entry, on every outcome. A unique watch destructor takes over the
caller's obligation and discharges it by destroying the watch. For a consuming
operation that can fail, the transfer still takes place at entry. Consumption
and mutation describe different facts: transfer concerns the obligation;
mutation concerns changes to live contents.

Model: [Release responsibility](explanation/model.md#responsibility).

See [Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Rule: [`C3`](contracts.md#c3).

## Consumer

A consumer is a tool that uses an AIL description. A binding generator uses
the stated lifetimes when generating access to borrowed values; a documentation
renderer explains those lifetimes to callers. Each consumer retains access to
the same API facts, while identifying any restrictions of its own output.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [Who writes and uses an AIL description](README.md#who-writes-and-uses-an-ail-description).
Rules: [`C8`](contracts.md#c8), [`A5`](profiles.md#a5).

## Contents

A contents contract says how to interpret pointer data: as binary, or as text
with a named encoding and termination convention. Three binary bytes may
include zero as data. Three code units of zero-terminated text are followed by
a separate zero terminator. The byte pointer's type alone leaves these choices
open, so the author supplies the applicable contract.

Model: [Storage](explanation/model.md#storage).

See [How many bytes exist, and what do they contain?](explanation/unsaid.md#how-many-bytes-exist-and-what-do-they-contain).
Rule: [`C4`](contracts.md#c4).

## Copy

Copy [retention](#retention) creates an independent semantic copy according to
a [profile](#profile). For example, a callee could store a copy of supplied
state for later use, with the profile defining the copy's meaning. Copying
pointer bits instead produces another copy of the same address; retaining
a reference keeps the same entity alive. AIL's term also differs from Rust's
`Copy` trait. The synthetic fixture profile does not support copy retention.

Model: [Release responsibility](explanation/model.md#responsibility).

See [Reading AIL's terms](explanation/unsaid.md#reading-ails-terms).
Rules: [`C3`](contracts.md#c3), [`F1`](profiles.md#f1).

## Declaration

Model: [The published description](explanation/model.md#description).

A declaration is a named description inside a package: for example, a record
type or a function. The declaration supplies the type's structure or the
operation's signature, together with clauses describing its contract.

Fragment — shows the `Point` record and its fields in the geometry package.
Publication clauses, environments, availability and nominal contracts are omitted.

<!-- ail-example: examples/rule-reading/geometry.ail -->
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

The outer braces contain the declaration named `Point`; its inner braces
contain fields named `x` and `y`. Each field has the core signed 32-bit integer
type `i32`. These fields are parts of `Point`, while a function such as
[`position`](#callable) is another declaration at package level. A
[member](#member) function also sits at package level and names its owning
type through a clause.

See [local and imported declarations](#local-and-imported-declaration),
[the language-containment view](language.md#l2) and
[What a package claims](explanation/packages.md#what-a-package-claims).
Rules: [`L2`](language.md#l2), [`L4–L5`](language.md#l4).

## Dependency closure

The dependency closure includes all declarations and pinned definitions needed
to interpret and use a package's declared surface. Starting with an exported
watch operation, a tool follows its types and referenced operations, then their
dependencies, until it has the complete set. Callback captures instead describe
saved program state used during an invocation.

Model: [The published description](explanation/model.md#description).

See [What a package claims](explanation/packages.md#what-a-package-claims).
Rules: [`L2–L3`](language.md#l2).

## Digest pin

A digest pin identifies exact dependency bytes alongside an identifier and
version. A tool computes the digest of the supplied package or provider manifest
and compares it with the pin, so two different contents cannot be accepted
merely because they claim the same name and version. The fixture examples use
synthetic test tokens under F1's exception; those tokens are not hashes of the
Markdown or usable production pins.

Model: [The published description](explanation/model.md#description).

See [What it depends on](explanation/packages.md#what-it-depends-on).
Rules: [`L2`](language.md#l2), [`F1`](profiles.md#f1).

## Discriminator

A discriminator is the value a caller can inspect to distinguish outcomes for
one completion. It can be the result, an output scalar pointee or a thrown
value, as the rules permit. If a function returns null on failure and a pointer
on success, its result is the discriminator. It has to be valid in every
outcome for that completion so the caller can perform the test.

Model: [How a call finishes](explanation/model.md#outcomes).

See [Every way a call can end](explanation/contracts.md#every-way-a-call-can-end).
Rule: [`C5`](contracts.md#c5).

## Environment

An environment names an exact target and platform configuration. It can also
specify exact toolchain, runtime and feature values. A declaration's availability
selects from these configurations. This lets tools determine where a package's
claims apply; an unlisted configuration remains outside those claims, without
asserting that the API is absent there. Version ranges require additional
language support.

Model: [The published description](explanation/model.md#description).

See [Where it holds](explanation/packages.md#where-it-holds).
Rule: [`L3`](language.md#l3).

## Executor

An executor identifies where a call or callback may enter, such as the main
thread or a profile-defined execution context. A main-thread requirement asks
the caller to arrange the call there. Permission to enter from any executor
still leaves [concurrency](#concurrency) to decide whether independent calls
may overlap.

Model: [Where and when calls run](explanation/model.md#execution).

See [Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where).
Rules: [`C2–C3`](contracts.md#c2), [`C6`](contracts.md#c6).

## Exports

Exports are the public declarations explicitly listed as roots of a package's
surface. Tools begin from those roots and follow the declarations they depend
on. A private support declaration reached that way remains part of the
contract the package needs to describe, even though users enter through the
public operation.

Model: [The published description](explanation/model.md#description).

See [What a package claims](explanation/packages.md#what-a-package-claims).
Rule: [`L3`](language.md#l3).

## FFI

A foreign-function interface provides mechanisms for making calls and
representing values across a language boundary. A binding can use it to invoke
a C function from another language. The binding also needs the API's ownership,
lifetime and callback rules to decide how to use the returned values safely.

Model: [Reaching the code](explanation/model.md#access).

See [Using an API across languages](explanation/unsaid.md).
Relevant rules: [`A1–A3`](profiles.md#a1).

## Handle

A handle identifies an entity while keeping its internal layout hidden. The
program passes a watch handle back to the library to view or close the watch.
In AIL a resource value already denotes such a handle; a pointer to a resource
denotes storage containing that handle. Those forms describe different values.

Model: [Entities that outlive a call](explanation/model.md#entities).

See [A small API](explanation/unsaid.md#a-small-api).
Rules: [`L4`](language.md#l4), [`C2`](contracts.md#c2).

## Import

An import selects another package by name, version and digest, and introduces
an alias used to refer to its declarations. A watch package could import a
shared event type under a short local alias. Throughout the dependencies,
the same package name and version must select the same digest; choosing a
second alias leaves that requirement unchanged.

The [local/imported example](#local-and-imported-declaration) shows the
`Geometry` alias in its containing package and explains the pin's placeholder.
Model: [The published description](explanation/model.md#description).

See [What it depends on](explanation/packages.md#what-it-depends-on).
Rule: [`L2`](language.md#l2).

## Invalidation

Invalidation ends a borrow's usability before its [region](#region) would
otherwise end. A refresh operation might replace a watch's bytes while keeping
the watch alive. AIL lists such operations for returned borrows; calling a
listed operation involving the owner invalidates the borrow at that operation's
entry. The caller then stops using the earlier view.

Model: [Validity](explanation/model.md#validity).

See [How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view).
Rules: [`C1`](contracts.md#c1), [`C5`](contracts.md#c5).

## Isolation

Nominal isolation is an executor restriction attached to a type. A confined
watch could require use on the main thread, including destruction and use
through free functions. An operation's executor requirement has to respect
that restriction unless a profile defines a legal exception. A type can also
state that it has no nominal isolation; individual operations still specify
their entry requirements. See the [located nominal example](contracts.md#c2)
for the clause that records this choice.

Model: [Where and when calls run](explanation/model.md#execution).

See the [threading explanation](explanation/unsaid.md#which-calls-may-run-together-and-where).
Definition and rule: [`C2`](contracts.md#c2).

## Lifecycle

A lifecycle describes how a resource, object or interface is kept alive and
released. A unique watch has one destruction obligation per owned handle. A
reference-counted object instead has one release obligation per owned reference;
retaining creates another reference and its obligation. Call contracts state
when those obligations move between caller and callee.

Model: [Entities that outlive a call](explanation/model.md#entities).

See the [ownership explanation](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Definition and rule: [`C2`](contracts.md#c2).

## Local and imported declaration

Model: [The published description](explanation/model.md#description).

Local and imported describe a declaration relative to the package being read.
`Point` is local in `example::geometry`, where its record definition appears
in the [declaration example](#declaration). From the canvas package below,
`Canvas` and `position` are local; `Point` belongs to the imported geometry
package. The import gives that package the local alias `Geometry`.

Fragment — shows the two packages' connection and a member function. The
all-zero digest is a **placeholder**, not the hash of the geometry fragment;
this is not a resolvable package. A complete package needs exact dependency
bytes and their digest, publication and environment clauses, nominal contracts,
and the function's remaining effects, outcomes and access paths.

<!-- ail-example: examples/rule-reading/canvas.ail region=model -->
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

The import names `example::geometry`, its version and digest, then introduces
`Geometry` after `as`. In the signature, `Canvas` selects the local type;
`Geometry::Point` selects `Point` through that alias. The `::` joins the alias
and declaration name. When a clause needs a declaration reference, it uses
`@Canvas` for the local resource or `@Geometry::Point` for the imported record.
The member clause above uses the first spelling; [Member](#member) explains
its association and receiver, and [Place](#place) explains the `$canvas` clauses.

Local here means declared in this package, rather than a variable inside a
function. Importing `Point` preserves its [canonical identity](#canonical-identity).

Use the language-containment view to distinguish where a declaration lives from the declarations
it refers to. Start with each package folder and its declaration boxes, then
follow the labelled arrows: the canvas package imports geometry as `Geometry`,
and `position` is associated with its sibling `Canvas` by `member`. Inside
`Point`, the entries are fields; inside a callable, they are parameters and
results. The view also includes `Filter` from the separate
[callback fragment](language.md#reading-aid-non-normative-names-references-and-callable-slots):
it accepts a `Geometry::Point` and returns a Boolean. Its slots belong to that
callback, while `position` has its own `canvas` parameter and Point result.
Both packages have version `"1"`; their other items and contracts are omitted,
and the example import digest remains a placeholder.

![The canvas package contains Canvas, position and Filter as sibling declarations. Its import arrow leads to the geometry package containing Point and its x and y fields. A member arrow associates position with Canvas. Each callable box contains its own parameter and result slots.](figures/g9-model.svg)

[Diagram source](figures/g9-model.puml) ·
[How tools use these API descriptions](README.md#who-writes-and-uses-an-ail-description)

See [the language-containment view and import/reference railroads](language.md#l2) and
[What it depends on](explanation/packages.md#what-it-depends-on).
Rule: [`L2`](language.md#l2).

## Mapping

A mapping specifies how a declaration's parameters, results and completion
modes are realized through an access path. For example, a callback mapping has
to account for an auxiliary native context argument when one exists. Each part
is accounted for exactly once. With an identity mapping, the consumer follows
the provider's rules for passing the declared arguments and results without
changing their meaning. The description needs evidence that the selected
providers support that mapping.

Model: [Reaching the code](explanation/model.md#access).

See [Reaching the code](explanation/packages.md#reaching-the-code).
Rule: [`A2`](profiles.md#a2).

## Member

Model: [Entities that outlive a call](explanation/model.md#entities).

A member is a top-level declaration associated with a nominal type by a
`member` clause. For an instance function, the caller supplies a value of that
type as an ordinary named parameter, designated as the receiver.

Fragment — shows `Canvas` and its `position` member as sibling declarations.
The header, `Geometry` import, publication context, nominal contracts and
remaining callable contracts are omitted; [the import example](#local-and-imported-declaration)
locates the result type.

<!-- ail-example: examples/rule-reading/glossary.ail region=member -->
```ail
package example::canvas version "1" {
  resource Canvas {
    // Lifetime and other nominal contracts omitted.
  }
  fn position(canvas: Canvas) -> Geometry::Point {
    member(@Canvas, instance);
    receiver($canvas);
    // Input, effects, outcomes and access omitted.
  }
  // Header, Geometry import and publication context omitted.
}
```

`member(@Canvas, instance)` associates `position` with the declaration named
`Canvas`. `receiver($canvas)` identifies its `canvas` parameter as the receiver.
The `@` names a declaration; the `$` addresses a value within this callable.
Both `position` and `Canvas` are declared directly inside `example::canvas`.
The `member` clause connects them, so a reader follows that clause to find
the function's owning type.
A static member uses the `static` member kind and designates no receiver.

See [the language-containment view](language.md#l2) and
[Four identities](explanation/packages.md#four-identities).
Rules: [`L2`](language.md#l2), [`L5`](language.md#l5).

## Opaque resource

An opaque resource is a handle type whose internal layout is deliberately
hidden. Its contract describes the operations available to callers and the
rules for keeping it alive and destroying it. A watch can therefore be fully
described through its operations even when only the library knows its layout.
A by-value record instead needs the representation facts required to pass it.

Model: [Entities that outlive a call](explanation/model.md#entities).

See the [scope explanation](README.md#scope-of-draft-01).
Definitions and rules: [`L4`](language.md#l4), [`C2`](contracts.md#c2), [`A3`](profiles.md#a3).

## Outcome

An outcome describes one distinguishable case of a call's completion: the
condition identifying it, its meaning and its output states and obligations.
A null failure and a non-null success can be two outcomes for a returned
completion. Another API can give null a successful “no value” meaning, so the
author records that meaning explicitly.

Model: [How a call finishes](explanation/model.md#outcomes).

See [What can the caller read when a call fails?](explanation/unsaid.md#what-can-the-caller-read-when-a-call-fails).
Rule: [`C5`](contracts.md#c5).

## Output state

An output state says whether a result, thrown value or writable pointee is
valid, invalid or, for eligible `inout` storage, unchanged from entry. If a
function writes zero to its length output on failure, the caller can read that
valid zero. If the output is invalid, the caller leaves it unread, including
for a null test. A valid null result is an observable value.

Model: [How a call finishes](explanation/model.md#outcomes).

See [Every way a call can end](explanation/contracts.md#every-way-a-call-can-end).
Rules: [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).

## Owned

An owned reference carries one obligation to destroy a resource or release a
reference according to its lifecycle. A caller receiving a new unique watch
becomes responsible for its destruction. For a reference-counted object,
several parties can each hold an owned reference and each owe one release.
Ownership therefore need not imply exclusive access.

Model: [Release responsibility](explanation/model.md#responsibility).

See [Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Rules: [`C2`](contracts.md#c2), [`C5`](contracts.md#c5).

## Ownership transfer

Ownership transfer moves a destruction or release obligation between caller
and callee. A successful creation can give the caller an owned watch; a
consuming destructor takes its obligation back. Copying the watch's address
merely produces another copy of that address. Transfer, retention and release
rules determine who is responsible for destroying the watch or releasing a
reference.

Model: [Release responsibility](explanation/model.md#responsibility).

See [Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Rules: [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).

## Package

Model: [The published description](explanation/model.md#description).

A package is a named, versioned description of a declared API surface. It
contains declarations, exact environments and pinned dependencies. A package
could cover only a library's watch operations, provided it fully describes
those operations and the declarations and definitions they depend on. The
chosen scope determines the work needed for a complete contract.

Fragment — shows the geometry package's shell, stated surface and export.
A complete package also supplies an environment, availability, deprecation,
sharing and isolation.

<!-- ail-example: examples/rule-reading/syntax.ail region=shell -->
```ail
language "0.1";
package example::geometry version "1" {
  surface("An invented point API, release 1.");
  exports([@Point]);
  record Point {
    field x: i32;
    field y: i32;
    // Environment, availability and nominal contracts omitted.
  }
}
```

The `language` header selects AIL version `"0.1"`; `version "1"` identifies
this API description independently. The outer braces enclose the package's
contents. `surface` states what it covers, and `exports([@Point]);` lists
`Point` as a public root: brackets enclose a list and `@Point` refers to the
record declaration inside this package. In a package describing watch
operations, the roots would instead name those operations and any other
declarations the producer exposes.

See [the package-shell railroad](language.md#l1) and
[What a package claims](explanation/packages.md#what-a-package-claims).
Rules: [`L2–L3`](language.md#l2).

## Pattern

A pattern describes a reusable relationship through typed [roles](#role) and
laws. For example, it can relate a resource type to the operation that destroys
it. A [pattern instance](#pattern-instance) fills those roles with concrete
declarations. The laws impose obligations checked against those declarations'
contracts, beyond describing a usual order of calls.

Model: [Entities that outlive a call](explanation/model.md#entities).

See [Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns).
Rule: [`L6`](language.md#l6).

## Pattern instance

A pattern instance applies a named pattern by binding every role to concrete
participants. A destruction pattern could bind its type role to `Watch` and
its operation role to the declared watch destructor. A role that permits no
participants still gets an explicit empty binding. The instance applies the
pattern's laws consistently with the resource's existing lifecycle.

Model: [Entities that outlive a call](explanation/model.md#entities).

See [Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns).
Rule: [`L6`](language.md#l6).

## Place

Model: [Operations and their values](explanation/model.md#operations).

A place identifies the value or storage a clause addresses, starting from a
callable [slot](#slot). Its `$` spelling is read inside that callable.

Fragment — shows the `canvas` parameter used by clauses in `position`.
The header, `Geometry` import, `Canvas`, publication context and remaining
callable contracts are omitted; [the two-package language-containment view](language.md#l2)
supplies the declaration context.

<!-- ail-example: examples/rule-reading/glossary.ail region=place -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    input($canvas, borrow);
    retain($canvas, none);
    valid($canvas, call);
    // Member, effects, outcomes and access omitted.
  }
  // Header, Geometry import, Canvas and publication context omitted.
}
```

Here `$canvas` addresses this function's parameter. The clauses say that the
caller lends the handle, the callee retains no reference and the caller keeps
it valid throughout the call. A reference to this slot from outside the
function is `@position::canvas`; it includes the declaration name to locate
the parameter.

A place can continue into a value. In this same function, `$result.x` selects
the `x` field of the returned `Point`, whose fields appear in the
[declaration example](#declaration). For pointer and buffer selections,
[C1's located examples](contracts.md#c1) show `.*` selecting a single pointee
and `[]` selecting elements, with the extent each form requires. The path lets
validation check the clause against the type at that location.

See [Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about).
Rules: [`C1`](contracts.md#c1), [`L5`](language.md#l5).

## Producer

A producer is a person or tool that writes an AIL package. An API author might
write from knowledge of the implementation; an analysis tool might gather
declarations and other evidence. Each producer resolves required facts and
conflicts before publishing a complete description under the same rules.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [Who writes and uses an AIL description](README.md#who-writes-and-uses-an-ail-description).
Rule: [`L3`](language.md#l3).

## Profile

A profile defines additional source types, clauses, access mechanisms or
behavioural rules. A profile for message dispatch, for example, could specify
how a selector identifies an object method and how a tool checks that path.
Packages select the profile by version and digest. Its rules extend the
language while preserving core requirements. This is a semantic extension;
“profile” here has a different meaning from performance measurement or a
preferences preset.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries).
Rule: [`A1`](profiles.md#a1).

## Projection

A projection is a consumer's presentation or adaptation of a contract. A
prose page and a typed object model can expose the same lifetime facts in
different forms while retaining access to them. If an adapted operation
instead discards a meaningful status distinction, it needs a distinct
declaration describing its observable behaviour.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [One contract, several views](explanation/packages.md#one-contract-several-views).
Rules: [`A2`](profiles.md#a2), [`A5`](profiles.md#a5).

## Provider

A provider supplies a profile or ABI definition through a manifest and the
tooling needed to interpret or realize it. The manifest describes the rules;
a compiler or runtime can supply the machinery to carry them out. Consumers
identify which providers they support. A documentation tool may describe a
source access path even when a binding generator lacks its required compiler.

Model: [Reaching the code](explanation/model.md#access).

See [Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries).
Rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).

## Publication boundary

The publication boundary is the transition from assembling evidence to
publishing a complete API description. For example, a producer settles who
owns a returned watch and how it is released before that operation's contract
is published. A validator checks the required facts for completeness and
consistency; the producer's evidence about the real implementation is a
separate responsibility.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [Who writes and uses an AIL description](README.md#who-writes-and-uses-an-ail-description).
Rules: [`L3`](language.md#l3), [`C8`](contracts.md#c8).

## Quiescence

Quiescence means that no callback invocation is running or can begin for the
registration being ended. If closing a watch promises quiescence at return,
the caller can then release state kept alive for those invocations. A request
to cancel can return while callbacks are still running; that protocol needs
a separate way to establish when teardown is complete.

Model: [Callbacks and their schedules](explanation/model.md#callbacks).

See [callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state).
Rule: [`C6`](contracts.md#c6).

## Re-entrancy

Re-entrancy occurs when an active call leads to a nested call on the same
receiver or resource before the first call finishes. For example, an operation on a watch
could invoke a callback that calls another operation on that same watch before
the outer call finishes. The contract says whether that nested entry is
permitted. Independent calls from separate control flows are governed by
[concurrency](#concurrency).

Model: [Where and when calls run](explanation/model.md#execution).

See [Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where).
Rules: [`C3`](contracts.md#c3), [`C6`](contracts.md#c6).

## Reference leaf

A reference leaf is a pointer, resource, object, interface or callback value,
including one nested in a by-value aggregate. If a record contains a watch
handle, validation follows the record's fields to that handle and checks its
ownership and validity obligations. Grouping the handle with other fields
preserves those obligations.

Model: [Operations and their values](explanation/model.md#operations).

See [Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about).
Rules: [`C1`](contracts.md#c1), [`L4`](language.md#l4).

## Region

A region names a lifetime used for validity or retention. It can be the current
call, the loaded API instance, or a particular owner's lifetime. A view tied to
a watch uses the watch's lifetime as its bound, subject to earlier invalidators.
AIL's `static` region lasts until the loaded API instance ends, which can be
earlier than process exit.

Model: [Validity](explanation/model.md#validity).

See [How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view).
Rules: [`C1`](contracts.md#c1), [`C3`](contracts.md#c3).

## Representation

A representation defines how a type's values are realized when passed through
an access path. For a record this can include size, alignment and field
offsets; for an opaque value it can include runtime operations for passing,
copying, moving and destroying it. The provider supplies the complete recipe.
Knowing the record's semantic fields alone leaves these native details to be
established.

Model: [Reaching the code](explanation/model.md#access).

See [Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries).
Rule: [`A3`](profiles.md#a3).

## Resolution set

A resolution set supplies the dependencies and artifact identities that tools
need to interpret a package. When an import names a package and digest, the
validator looks for matching contents in this explicitly supplied set.
Installation and trust decisions take place outside validation; validation
neither fetches missing dependencies nor executes provider code implicitly.

Model: [The published description](explanation/model.md#description).

See [What it depends on](explanation/packages.md#what-it-depends-on) and
[Reaching the code](explanation/packages.md#reaching-the-code).
Rules: [`L2`](language.md#l2), [`A4`](profiles.md#a4).

## Retention

Retention describes whether and how a callee stores an input beyond immediate
use. It may store nothing, acquire a strong reference, make a semantic copy,
store a zeroing weak reference, or store an unretained reference. Strong
retention creates an independent release obligation; consuming an input instead
takes over the caller's obligation. With unretained storage, the caller keeps
the referent alive for the whole stated storage region.

Model: [Release responsibility](explanation/model.md#responsibility).

See the [ownership explanation](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Definition and rule: [`C3`](contracts.md#c3).

## Role

A role is a named participant position in a pattern, with a type and
[cardinality](#cardinality). A role can ask for one resource type, for example,
or one operation to destroy it. When a role accepts a callable slot, that
slot's identity includes its operation, allowing two functions to use the same
parameter name without confusing their participants.

Model: [Entities that outlive a call](explanation/model.md#entities).

See [Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns).
Rule: [`L6`](language.md#l6).

## Shared

Shared is a type-level permission for references to cross [executors](#executor).
Different execution contexts may therefore hold references to the same entity. Each
operation's concurrency contract still controls overlapping calls and mutation.
The permission is also separate from a source compiler's conformance judgement,
such as Swift sendability.

Model: [Where and when calls run](explanation/model.md#execution).

See [Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where).
Rule: [`C2`](contracts.md#c2).

## Slot

Model: [Operations and their values](explanation/model.md#operations).

A slot is a callable's named parameter, result or declared thrown value. A
contract identifies the slot within its owning callable.

Fragment — shows the parameter and result of `position` in the canvas
package. The header, import, `Canvas`, publication context and other callable
contracts are omitted; [the import example](#local-and-imported-declaration)
locates `Geometry::Point`.

<!-- ail-example: examples/rule-reading/glossary.ail region=callable -->
```ail
package example::canvas version "1" {
  fn position(canvas: Canvas) -> Geometry::Point {
    execution(sync);
    // Member, input, remaining effects, outcomes and access omitted.
  }
  // Header, Geometry import, Canvas and publication context omitted.
}
```

`@position::canvas` selects the named parameter. `@position::result` selects
the result, whose type follows `->`. In these references, `::` joins the
callable name and slot name. The callback `Filter` in the
[callback example](language.md#reading-aid-non-normative-names-references-and-callable-slots)
has its own result, referenced as `@Filter::result`; each result belongs to
its own invocation. Inside `position`, `$canvas` and `$result` address those
values locally. A [place](#place) starts from a slot and can select a field,
pointee or buffer elements within it, letting a clause describe a specific
part of a larger value.

Compare the complete slot reference with the place used inside its callable.
The containing callable gives each `$result` its meaning, even though the
local spelling is the same.

| Slot reference in `example::canvas` | Place inside the named callable | Value addressed |
|---|---|---|
| `@position::canvas` | `$canvas` inside `position` | The `Canvas` parameter designated as receiver |
| `@position::result` | `$result` inside `position` | The returned `Geometry::Point` |
| `@Filter::point` | `$point` inside `Filter` | The callback's `Geometry::Point` parameter |
| `@Filter::result` | `$result` inside `Filter` | The callback's Boolean result |

See [Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about).
Rules: [`C1`](contracts.md#c1), [`L2`](language.md#l2).

## Source identity

A source identity identifies a declaration under a profile's exact
interpretation of its source language or metadata. It can record the original
name of an operation that has its own canonical AIL identity. The access path
separately explains how to reach its implementation: a source spelling may
identify something that needs a compiled call rather than a linker symbol.

Model: [The published description](explanation/model.md#description).

See [Four identities](explanation/packages.md#four-identities).
Rules: [`L2`](language.md#l2), [`L5`](language.md#l5), [`A1–A2`](profiles.md#a1).

## Surface

A surface is the API subset and release that a package claims to describe.
An author could choose a library's watch operations while leaving unrelated
image operations outside the package. The watch operations still require all
their applicable facts and dependencies. Stating a smaller scope determines
which API is covered while keeping the completeness requirement within it.

Model: [The published description](explanation/model.md#description).

See [What a package claims](explanation/packages.md#what-a-package-claims).
Rule: [`L3`](language.md#l3).

## Validation

Validation checks that a description satisfies all applicable core and provider
rules consistently and completely for its declared scope. A validator checks,
for example, that an owner-bounded borrow names a suitable owner and that outcomes
cover every possible discriminator value. Evidence that the library actually
behaves that way comes from separate review and testing. Whether a particular
generator can produce a binding is also a separate question.

Model: [Writers, checkers and users](explanation/model.md#agreement).

See [A shared description for API tools](explanation/unsaid.md#a-shared-description-for-api-tools).
Rules: [`L3`](language.md#l3), [`C1`](contracts.md#c1), [`C5`](contracts.md#c5),
[`C8`](contracts.md#c8), [`A5`](profiles.md#a5).

Next: [A model of API behaviour and binding obligations](explanation/model.md)
for the concepts together, [How AIL states a contract](explanation/contracts.md) for paired AIL examples,
[Packages, environments and access paths](explanation/packages.md) for publication
and access, or [Design choices, limits and open questions](explanation/choices.md)
for the trade-offs. See [the canonical contract rules](contracts.md) for exact obligations.
Return to [the overview](README.md) for the document map.
