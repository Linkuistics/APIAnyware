# Glossary

> **Purpose:** reference — find a domain term and avoid misleading familiar meanings.
> **Reader:** language designers new to API binding, and readers looking up AIL terms.
> **Before this:** nothing; [What a signature leaves unsaid](explanation/unsaid.md) introduces the domain.
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L1–L6`](language.md#l1), [`C1–C8`](contracts.md#c1) and [`A1–A5`](profiles.md#a1) are canonical; these entries are non-normative summaries.

Each entry gives a short definition, a defining location and the relevant rules.
Domain terms such as [FFI](#ffi) name the problem being described, rather than AIL syntax.
The alphabetical entries include terms needed to begin reading the rules.

## ABI

An application binary interface defines how values and calls cross a machine
boundary, including representation, layout, [calling conventions](#calling-convention) and runtime
requirements. Defined in [Reaching the code](explanation/unsaid.md#reaching-the-code);
rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).
A calling convention is only part of an ABI; a [package](#package) selects a tooling-owned
ABI definition rather than implementing one.

## ABI entry

An ABI entry is a tooling-owned, versioned definition of calling conventions
and representations selected through a pinned catalogue alias. Defined in
[Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries);
rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).
A language name or compiler version alone is not a compatibility guarantee.

## Access path

An access path describes how a consumer reaches a declaration's code or data in
specified [environments](#environment), with its ABI, access mechanism,
[mapping](#mapping) and compatibility
domain. Defined in [Reaching the code](explanation/packages.md#reaching-the-code);
rule: [`A2`](profiles.md#a2). A source name alone does not supply a path.

## Availability

Availability is the set of declared exact environments in which a declaration
is offered. Defined in [Where it holds](explanation/packages.md#where-it-holds);
rule: [`L3`](language.md#l3). It is not a runtime
capability test for an optional member ([`C3`](contracts.md#c3)).

## Binding

An API binding lets code in one language use an API offered in another while
preserving the API's obligations and observations. Defined in
[What a signature leaves unsaid](explanation/unsaid.md); relevant rule:
[`A5`](profiles.md#a5). A valid package does not establish that every target
language can express its contract.

## Binding contract

A binding contract states what callers owe and what an API promises, including
ownership, validity, [outcomes](#outcome), [callbacks](#callback) and
[concurrency](#concurrency). Defined in
[What a signature leaves unsaid](explanation/unsaid.md); rules:
[`C1–C6`](contracts.md#c1), [`A5`](profiles.md#a5).

## Borrow

A borrow grants access without transferring an ownership obligation, subject to
a stated validity [region](#region). Defined in
[Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value);
rules: [`C1`](contracts.md#c1), [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).
Do not infer Rust's exclusivity rules or static borrow checking.

## Borrow validity

Borrow validity describes how long borrowed access remains usable, bounded by
its region and any earlier [invalidation](#invalidation). Defined in
[How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view);
rules: [`C1`](contracts.md#c1), [`C5`](contracts.md#c5).
A non-null pointer can still be invalid.

## Buffer extent

Buffer extent states a pointer's initialized length, allocated capacity and
units, or that it addresses exactly one element. Defined in
[How many bytes exist, and what do they contain?](explanation/unsaid.md#how-many-bytes-exist-and-what-do-they-contain);
rule: [`C4`](contracts.md#c4). Capacity is not readable length.

## Callback

A callback is a callable value supplied to an API for that API to invoke under
a specified schedule. Defined in [A small API](explanation/unsaid.md#a-small-api)
and [callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state);
rules: [`C2–C3`](contracts.md#c2), [`C6`](contracts.md#c6).
The callback declaration describes an invocation; a registration's use-site
schedule describes when and how often invocations may happen.

## Callback captures

Callback captures are the state a callback needs when invoked, such as values
reachable through a context pointer. Defined in
[callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state);
rules: [`C2`](contracts.md#c2), [`C6`](contracts.md#c6).
This is the captured-environment sense of “closure”, not dependency closure.

## Caller and callee

The caller invokes an operation and the callee implements that invocation.
Defined in [A small API](explanation/unsaid.md#a-small-api);
rules: [`C3`](contracts.md#c3), [`C5–C6`](contracts.md#c5).
When an API invokes a callback, it becomes the caller for that invocation.

## Calling convention

A calling convention is the protocol for entering a callable and passing its
arguments and results within an [ABI](#abi) definition. Defined in
[Reaching the code](explanation/unsaid.md#reaching-the-code);
rules: [`A1–A2`](profiles.md#a1). Matching its name does not establish compatible
type layout or runtime requirements.

## Canonical identity

A declaration's canonical identity is its package name, package version and
declaration name. Defined in [Four identities](explanation/packages.md#four-identities);
rule: [`L2`](language.md#l2). A source name or access-path name does not replace
it, and overloads have distinct local declaration names.

## Cardinality

Cardinality states how many participants a pattern role accepts: exactly one,
zero or one, zero or more, or one or more. Defined in
[Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns);
rule: [`L6`](language.md#l6). Callback invocation count is a separate contract.

## Clause

A clause states a fact using the uniform `name(arguments);` form, whose vocabulary
and applicability come from the rule files. Defined in
[From signature to contract](explanation/contracts.md#from-signature-to-contract)
and [One clause syntax](explanation/choices.md#one-clause-syntax-with-a-closed-vocabulary-in-prose);
rules: [`L1`](language.md#l1), [`L5`](language.md#l5). Parsing that form alone
does not establish that the clause is recognized or used validly.

## Closure

The normative text uses “closure” for both a transitive dependency set and a
callback's captured environment. Defined here through
[dependency closure](#dependency-closure) and [callback captures](#callback-captures);
rules: [`L2–L3`](language.md#l2), [`C2`](contracts.md#c2).
These explanations always qualify the word to keep the two meanings separate.

## Compatibility domain

A compatibility domain states where an access path's representation can be used:
the ABI entry's guaranteed stable domain, a resolved artifact set, or a named
source-build recipe. Defined in [Reaching the code](explanation/packages.md#reaching-the-code);
rule: [`A4`](profiles.md#a4). “Stable” does not mean merely an unchanged
calling-convention name.

## Completion

A completion is a way an invocation finishes: returned, thrown, cancelled or
terminated. Defined and governed by [`C3`](contracts.md#c3), with outcome rules in
[`C5`](contracts.md#c5). Listing possible completions is not a promise that the
call eventually terminates.

## Concurrency

Concurrency describes whether independent calls or callback invocations may
overlap under the declared access constraints. Defined in
[Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where);
rules: [`C3`](contracts.md#c3), [`C6`](contracts.md#c6).
It is distinct from nested [re-entrancy](#re-entrancy) and from permission to enter on any thread.

## Consume

To consume an input is to transfer one [owned](#owned) obligation from caller to callee at
entry, on every outcome. Defined in
[Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value);
rule: [`C3`](contracts.md#c3). It is not a transfer conditional on success, and
it does not by itself mean mutation of live contents.

## Contents

A contents contract identifies pointer data as binary or as text with an encoding
and termination convention. Defined in
[How many bytes exist, and what do they contain?](explanation/unsaid.md#how-many-bytes-exist-and-what-do-they-contain);
rule: [`C4`](contracts.md#c4). A byte pointer is not automatically a C string.

## Copy

Copy [retention](#retention) creates an independent semantic copy according to a
[profile](#profile), a semantic extension rather than a preferences preset.
Defined by [`C3`](contracts.md#c3), with the familiar-meaning comparison in
[the domain explanation](explanation/unsaid.md#what-your-language-design-knowledge-covers-and-where-it-misleads).
It is neither copying pointer bits nor retaining another reference, and does
not mean Rust's `Copy` trait; the synthetic fixture profile does not support it
([`F1`](profiles.md#f1)).

## Dependency closure

The dependency closure is the transitive set of declarations and pinned
dependencies needed to interpret and use a package's declared surface.
Defined in [What a package claims](explanation/packages.md#what-a-package-claims);
rules: [`L2–L3`](language.md#l2). It is not a callback's captured environment.

## Digest pin

A digest pin selects exact dependency bytes alongside their identifier and
version. Defined in [What it depends on](explanation/packages.md#what-it-depends-on);
rule: [`L2`](language.md#l2).
The synthetic fixture's digest tokens are a testing exception, not hashes of
the Markdown or usable production pins ([`F1`](profiles.md#f1)).

## Discriminator

A discriminator is the valid result, output scalar pointee or thrown value
whose value separates outcomes for a completion. Defined in
[Every way a call can end](explanation/contracts.md#every-way-a-call-can-end);
rule: [`C5`](contracts.md#c5). Invalid output cannot serve as a discriminator.

## Environment

An environment is an exact target and platform configuration, optionally refined
by toolchain, runtime and feature values. Defined in
[Where it holds](explanation/packages.md#where-it-holds);
rule: [`L3`](language.md#l3). It is not a version range; an unlisted configuration is
outside the package's claims, not a claim of absence.

## Executor

An executor identifies where a call or callback is allowed to enter, such as the
main thread or a profile-defined execution context. Defined in
[Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where);
rules: [`C2–C3`](contracts.md#c2), [`C6`](contracts.md#c6).
Allowing any executor does not permit simultaneous calls.

## Exports

Exports are the public roots a package explicitly lists for its declared surface.
Defined in [What a package claims](explanation/packages.md#what-a-package-claims);
rule: [`L3`](language.md#l3). Private support declarations remain part of the
authoritative dependency closure even when they are not export roots.

## FFI

A foreign-function interface supplies the mechanism for calling and representing
values across a language boundary. Defined in
[What a signature leaves unsaid](explanation/unsaid.md); relevant rules:
[`A1–A3`](profiles.md#a1). Having that mechanism does not establish ownership,
lifetime or callback obligations.

## Handle

A handle is a value identifying an entity without exposing its internal layout.
Defined in [A small API](explanation/unsaid.md#a-small-api); AIL's opaque-resource
rule is [`L4`](language.md#l4), with lifetime rules in [`C2`](contracts.md#c2).
In AIL, a resource value is already a handle; a pointer to a resource is storage
containing that handle.

## Import

An import selects a package by name, version and digest and introduces an alias
for its declarations. Defined in
[What it depends on](explanation/packages.md#what-it-depends-on);
rule: [`L2`](language.md#l2). An alias change cannot resolve conflicting pins
for the same package name and version.

## Invalidation

Invalidation ends a borrow's usability before its region would otherwise end.
Defined in [How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view);
rules: [`C1`](contracts.md#c1), [`C5`](contracts.md#c5).
The owner can remain alive while a borrowed view becomes invalid.

## Isolation

Nominal isolation restricts use of a type's values to a declared executor where
required by its sharing contract. Defined and governed by [`C2`](contracts.md#c2);
see the [threading comparison](explanation/unsaid.md#which-calls-may-run-together-and-where).
Known absence of nominal isolation does not mean all operations allow entry
anywhere.

## Lifecycle

A lifecycle states a resource, object or interface's destruction or retain/release
discipline. Defined and governed by [`C2`](contracts.md#c2);
see the [ownership explanation](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Unique handles and reference-counted references carry different obligations.

## Mapping

An access mapping accounts for the semantic signature's lowering into an access
path, including auxiliary arguments and completion modes. Defined in
[Reaching the code](explanation/packages.md#reaching-the-code);
rule: [`A2`](profiles.md#a2).
Identity mapping still needs a faithful provider-defined lowering; it does not
mean “assume the signatures match”.

## Opaque resource

An opaque resource is a handle type whose layout is intentionally hidden, with specified
operations and lifetime obligations. Defined and governed by
[`L4`](language.md#l4), [`C2`](contracts.md#c2).
“Opaque” is a complete contract about hidden representation, not an excuse for
unrecorded pointer layout.

## Outcome

An outcome names one partition of a completion's possibilities, its meaning
and its output states and obligations. Defined in
[What can the caller read when a call fails?](explanation/unsaid.md#what-can-the-caller-read-when-a-call-fails);
rule: [`C5`](contracts.md#c5). Nullability alone does not make null a failure.

## Output state

An output state says whether a result, thrown value or writable pointee is
valid, invalid or, for eligible `inout` storage, unchanged from entry. Defined in
[Every way a call can end](explanation/contracts.md#every-way-a-call-can-end);
rules: [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).
A valid null result is observable; an invalid output cannot even be tested for null.

## Owned

An owned reference carries one obligation to destroy a resource or release a
reference according to its lifecycle. Defined in
[Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value);
rules: [`C2`](contracts.md#c2), [`C5`](contracts.md#c5).
Owned does not necessarily mean unique: several owned references can refer to
one reference-counted object.

## Ownership transfer

Ownership transfer moves a destruction or release obligation between caller and
callee. Defined in
[Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value);
rules: [`C3`](contracts.md#c3), [`C5`](contracts.md#c5).
Copying an address does not create another obligation or transfer the existing one.

## Package

A package is an authoritative description of a declared API surface, with named
declarations, exact environments and pinned dependencies. Defined in
[What a package claims](explanation/packages.md#what-a-package-claims);
rules: [`L2–L3`](language.md#l2). Completeness is relative to the declared subset, but
covers that subset's entire dependency closure and applicable obligations.

## Pattern

A pattern declares typed roles and laws that bind concrete participants into
reusable relationships. Defined in
[Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns);
rule: [`L6`](language.md#l6).
Its laws impose obligations; a pattern is not merely an informal recipe for
usual call order.

## Pattern instance

A pattern instance binds every role of a named pattern to concrete participants,
including empty bindings where the role permits them. Defined in
[Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns);
rule: [`L6`](language.md#l6). It applies the pattern's laws; it does not invent
another release discipline.

## Place

A place is a typed path from a callable [slot](#slot) to the value or storage a clause
addresses. Defined in
[Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about);
rules: [`C1`](contracts.md#c1), [`L5`](language.md#l5). Dereferencing one pointee and
selecting buffer elements are distinct paths with different extent requirements.

## Profile

A profile is a versioned, digest-pinned definition of additional source types,
clauses, access mechanisms or behavioural rules. Defined in
[Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries); rule:
[`A1`](profiles.md#a1). It is a semantic extension, not a performance measurement
or a preferences preset, and cannot weaken core requirements.

## Projection

A projection is a consumer's presentation or adaptation of the authoritative
contract. Defined in [One contract, several views](explanation/packages.md#one-contract-several-views);
rules: [`A2`](profiles.md#a2), [`A5`](profiles.md#a5).
A prose or machine view retains access to the facts; an operation that discards
observable distinctions needs a different declaration.

## Provider

A provider supplies a profile or ABI definition through a manifest and the
tooling support needed to interpret or realize it. Defined in
[Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries);
rules: [`A1`](profiles.md#a1), [`A3–A4`](profiles.md#a3).
A manifest reference does not imply that every consumer supports it.

## Quiescence

Quiescence is the state in which no callback invocation is running or can begin
for the registration being ended. Defined in
[callback teardown](explanation/unsaid.md#when-is-it-safe-to-discard-callback-state);
rule: [`C6`](contracts.md#c6). A request to cancel is not necessarily quiescence.

## Re-entrancy

Re-entrancy is entry into an operation on the same receiver or resource from
control nested beneath an already active call. Defined in
[Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where);
rules: [`C3`](contracts.md#c3), [`C6`](contracts.md#c6).
It is separate from independent overlapping calls.

## Reference leaf

A reference leaf is a pointer, resource, object, interface or callback value,
including one nested inside a by-value aggregate. Defined in
[Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about);
rules: [`C1`](contracts.md#c1), [`L4`](language.md#l4).
Aggregation does not erase the leaf's ownership or validity contract.

## Region

A region names a validity or retention lifetime: the current call, the loaded
API instance, or a particular owner's lifetime. Defined in
[How long can the caller use a view?](explanation/unsaid.md#how-long-can-the-caller-use-a-view);
rules: [`C1`](contracts.md#c1), [`C3`](contracts.md#c3).
AIL's static region ends with the loaded API instance, not necessarily with the
process; earlier invalidators can shorten borrow validity.

## Representation

A representation defines how a semantic type is realized at an access boundary,
including the layout or runtime operations needed to use it. Defined in
[Profiles and ABI entries](explanation/packages.md#profiles-and-abi-entries);
rule: [`A3`](profiles.md#a3). Semantic record fields alone do not establish
stable native offsets or alignment.

## Resolution set

A resolution set explicitly supplies the pinned dependencies and artifact
identities needed to interpret a package. Defined in
[What it depends on](explanation/packages.md#what-it-depends-on) and
[Reaching the code](explanation/packages.md#reaching-the-code);
rules: [`L2`](language.md#l2), [`A4`](profiles.md#a4).
Validation does not fetch missing dependencies implicitly.

## Retention

Retention describes callee storage beyond immediate use, distinguishing no
storage, a strong reference, a semantic copy, a zeroing weak reference or an
unretained reference. Defined and governed by [`C3`](contracts.md#c3);
see the [ownership explanation](explanation/unsaid.md#who-is-responsible-for-releasing-a-value).
Strong retention creates an independent obligation; it is not input consumption.

## Role

A role names a typed participant position in a pattern, with a declared
cardinality. Defined in
[Lifecycles and patterns](explanation/contracts.md#lifecycles-and-patterns);
rule: [`L6`](language.md#l6). A slot participant's identity includes its
operation, so equal parameter names do not imply equal participants.

## Shared

Shared is the nominal permission for references to cross executors, with
concurrency still governed per operation. Defined in
[Which calls may run together, and where?](explanation/unsaid.md#which-calls-may-run-together-and-where);
rule: [`C2`](contracts.md#c2). It does not promise safe concurrent mutation or
assert a source language's compiler conformance.

## Slot

A slot is a named parameter, result or declared thrown value of a callable to
which a contract can refer. Defined in
[Naming what a contract talks about](explanation/contracts.md#naming-what-a-contract-talks-about);
rules: [`C1`](contracts.md#c1), [`L2`](language.md#l2).
A place can select a field, pointee or buffer elements within a slot.

## Source identity

A source identity names a declaration according to a selected profile's exact
interpretation, separately from its canonical AIL identity and access paths.
Defined in [Four identities](explanation/packages.md#four-identities);
rules: [`L2`](language.md#l2), [`L5`](language.md#l5), [`A1–A2`](profiles.md#a1).
A source spelling alone does not imply a callable linker symbol.

## Surface

A surface is the API subset and release a package explicitly claims to specify.
Defined in [What a package claims](explanation/packages.md#what-a-package-claims);
rule: [`L3`](language.md#l3). Omitting an unrelated API is
different from omitting an obligation of an exported declaration.

## Validation

Validation checks that the declared scope satisfies all applicable core and
provider rules consistently and completely. Defined in
[Why the signature cannot be the contract](explanation/unsaid.md#why-the-signature-cannot-be-the-contract);
rules: [`L3`](language.md#l3), [`C8`](contracts.md#c8), [`A5`](profiles.md#a5).
It neither proves a binary honours the assertions nor proves binding feasibility
for a chosen target language.

Next: [How AIL states a contract](explanation/contracts.md) for paired AIL examples,
[Packages, environments and access paths](explanation/packages.md) for publication
and access, or [Design choices, limits and open questions](explanation/choices.md)
for the trade-offs. See [the canonical contract rules](contracts.md) for exact obligations.
Return to [the overview](README.md) for the document map.
