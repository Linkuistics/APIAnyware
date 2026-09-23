# Design choices, limits and open questions

> **Purpose:** explanation — distinguish binding constraints from AIL's choices and inspect their costs and limits.
> **Reader:** language designers evaluating the notation after orientation and the concept explanations.
> **Before this:** [How AIL states a contract](contracts.md) and [Packages, environments and access paths](packages.md).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L1–L6`](../language.md#l1), [`C1–C8`](../contracts.md#c1) and [`A1–A5`](../profiles.md#a1) are canonical; this page is non-normative.

## How to read this page

Suppose a library lends bytes from a store. The caller needs the storage to
remain usable while reading those bytes. This requirement comes from the
binding domain: any [binding](../glossary.md#binding) needs to respect it.
The API author then decides what the library promises. An immutable store
might keep the bytes usable until destruction; a mutable store might replace
them sooner.

AIL's design determines how an author writes that promise. The clause
`give($result, borrow(owner($store)))` relates the returned pointer to the
store's lifetime. `invalidated_by` names operations that end access earlier.
Those spellings, and the decision to separate the two facts, are language
choices ([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

The same distinction applies to a [callback](../glossary.md#callback). Its
saved values, or [captures](../glossary.md#callback-captures), stay usable while
an invocation can still need them. An API can promise that teardown waits for
all callback use to finish. AIL expresses that particular promise with
[`quiescence(@unsubscribe)`](../glossary.md#quiescence)
([`C6`](../contracts.md#c6)).

This page distinguishes the domain requirement, the API's promise and AIL's
way of stating it. The benefits and costs below assess the published design.
Alternatives show what a different language design could make easier or harder;
they leave draft 0.1's rules in place. The register at the end keeps the open
questions available for review, including the missing rationale for placing
ownership in clauses.

All conformance examples mentioned here use the synthetic fixture
[profile](../glossary.md#profile), a versioned semantic extension,
catalogue and
[digest tokens](../glossary.md#digest-pin) defined by [`F1`](../profiles.md#f1).
They describe invented APIs rather than actual platform contracts.

The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows what API authors and tools do with a description. This page asks what
AIL's choices require of those people and tools, and what alternatives would
change for them.

The following sections develop each choice through examples. This table is a
map to those discussions; each cost concerns work an author or tool must do.

| Draft 0.1 choice | Alternative discussed below | Cost to inspect |
|---|---|---|
| Dedicated syntax | Extend WIT or Swift interface syntax | New vocabulary, corpus and tooling |
| Publish a complete description of a chosen subset | Publish unresolved facts for consumers to interpret | Author investigates required facts before publishing |
| Write each applicable fact | Use defaults or shorthand | Author writes clauses even when the answer is `none` |
| Put ownership in clauses | Put ownership in types/signatures | Reader follows the body to find transfers; rationale remains Q3 |
| Use one outer clause syntax | Give each clause its own grammar production | Reader also needs the rule files to learn permitted clauses |
| List exact environments | Use version ranges | Author lists configurations and separates contracts that vary |
| Add versioned profiles | Put source-specific rules in the core or allow open annotations | Provider authors specify each extension; consumers need support for it |

## A dedicated syntax

The synthetic store gives its owner a [handle](../glossary.md#handle) to
destroy once. The synthetic counter uses reference counting: each holder of an
[owned](../glossary.md#owned) reference releases that reference, and final
release destroys the object. A format serving both APIs needs to express both
release disciplines. It also needs to describe how to call them: the store
uses linker symbols, while the counter getter offers message and source-call
alternatives
([`C2`](../contracts.md#c2), [`A2`](../profiles.md#a2);
[buffers](../examples/buffers.ail), [objects](../examples/objects.ail)).
Owned means one release obligation, not necessarily exclusive access: several
owned references can refer to the same reference-counted object.

AIL provides a common core for these contracts, with profiles for additional
semantics and references to [ABI](../glossary.md#abi) definitions for the
machine-level rules. One alternative is to extend an existing interface
language such as WIT. That would reuse a notation and some ownership concepts,
but the extension would need to give native lifetimes, dispatch and
representation precise meanings that fit the existing language.

Another alternative is to extend Swift interface syntax. That would keep the
description close to Swift declarations and familiar to Swift authors. Authors
describing other source languages, and tools consuming those descriptions,
would then need to work within the resulting Swift-shaped model. These are
trade-offs to assess; neither alternative is established to be impossible.

Dedicated syntax avoids inheriting all the meanings and assumptions of either notation.
Its cost is a new vocabulary, a conformance corpus and future tooling to learn
and maintain. Familiar braces and function arrows do not remove that cost:
`Store` already denotes a handle, while ownership is stated in separate
[clauses](../glossary.md#clause)
([`L4`](../language.md#l4)). Familiar syntax alone cannot supply the missing
contract.

<a id="complete-contracts-only"></a>

## Publishing a complete description

An author can publish a [package](../glossary.md#package) describing only an
immutable sixteen-byte store, as the synthetic buffer example does. The
stated API subset and release are its [surface](../glossary.md#surface).
The author supplies enough information to create, use and destroy that store.
An unrelated storage API can remain outside the chosen surface
([`L3`](../language.md#l3)).

The returned view still needs a lifetime. If its ownership clause is missing,
a reader cannot tell whether to release the bytes or how long to borrow them.
That gap lies inside the promised description. Publishing a smaller surface
and leaving a required fact unanswered are different authoring decisions
([`L3`](../language.md#l3), [`C5`](../contracts.md#c5)).

Starting from `view`, a tool follows the reference to `Store`, then the store's
reference to its destructor. It continues until it has every definition needed
to interpret and use the exported declarations. This full set is the
[dependency closure](../glossary.md#dependency-closure). The author supplies
the applicable facts throughout it, resolving uncertain or conflicting
evidence before publication ([`L2–L3`](../language.md#l2)).

[Validation](../glossary.md#validation) checks that those facts are present
and consistent. Implementation evidence establishes whether the library
actually honours them. In summary (non-normative), AIL accepts a complete
description of a declared subset; required facts recorded as `unknown`,
confidence scores or promises of later inference fail the publication rules
([`L3`](../language.md#l3), [`C8`](../contracts.md#c8)).

An alternative is a partial model that preserves unresolved candidates for
consumers to interpret. Each consumer would then decide how to handle a missing
fact or choose among competing candidates. AIL places that investigation with
the producer, before the transition to a published contract — its
[publication boundary](../glossary.md#publication-boundary). This gives consumers
settled answers to work from, but a producer can have most of an API described
and still need substantial investigation before publishing it.

A broad established permission is still a complete fact. The synthetic
subscription permits zero or more callback invocations; `many` is an unbounded
maximum, not a missing answer. Conversely, an uninvestigated callback count
cannot be disguised by that permission ([`C6`](../contracts.md#c6),
[contract introduction](../contracts.md)).

<a id="everything-explicit"></a>

## Stating the applicable facts

For the synthetic store, the author has established that the type adds no
executor restriction. `isolation(none)` records that fact. For the counter,
the author has established that use belongs on the main thread and writes
`isolation(main)`. Both clauses answer the same question about
[isolation](../glossary.md#isolation). Omitting a required clause leaves the
question unanswered ([`L3`](../language.md#l3), [`C2`](../contracts.md#c2)).

The same distinction applies to [retention](../glossary.md#retention).
`view` promises to store no reference for later use through
`retain($store, none)`. The synthetic subscription does keep its handler,
tying storage to the returned owner's lifetime, or
[region](../glossary.md#region). A reader sees an explicit answer in both
cases ([`C3`](../contracts.md#c3)).

The authoring cost is visible in this entire synthetic `view` declaration.

Fragment — shows all clauses of the synthetic `view` function. The complete
[buffer package](../examples/buffers.ail) supplies `Store`, its destructor,
the [environment](../glossary.md#environment), and the synthetic fixture
profile, catalogue and digest tokens.

<!-- ail-example: ../examples/buffers.ail lines=72-100 -->
```ail
  fn view(store: Store) -> ptr<u8> {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(allowed);
    mutation(none);
    variadic(false);
    input($store, borrow);
    retain($store, none);
    valid($store, call);
    extent($result, buffer(16, 16, elements));
    contents($result, binary);
    outcome viewed {
      when(returned, any);
      meaning(success);
      state($result, valid);
      give($result, borrow(owner($store)));
      invalidated_by($result, []);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_store_view");
      mapping(identity);
      compatibility(stable);
    }
  }
```

Counting each `name(...);` clause once, including nested blocks but excluding
constructors inside arguments, this declaration has 23 clauses: 14 directly in
the function body, five in the [outcome](../glossary.md#outcome) and four in the
[access path](../glossary.md#access-path). That count
excludes all surrounding package and dependency declarations. It measures this
example's written burden, not average authoring effort. The rules behind these
groups are [`L3`](../language.md#l3), [`L5`](../language.md#l5),
[`C3–C5`](../contracts.md#c3) and [`A2`](../profiles.md#a2).

The clause-count table makes the distribution visible without treating nested
argument constructors as extra clauses.

| Location in `view` | Clauses |
|---|---|
| Directly in the function body | 14 |
| In `outcome viewed` | 5 |
| In `access direct` | 4 |
| Total, excluding the surrounding package | 23 |

AIL chooses explicit applicable facts over inferring “ordinary” ownership,
threading or access from names. Defaults or shorthand could reduce repetition;
the cost of the current form is writing and reviewing clauses even for known
absence. Its benefit is that independent consumers see the same stated answers
([`L3`](../language.md#l3), [`C8`](../contracts.md#c8)).

Requiredness depends on the declaration and the clause. For example, a scalar
input carries no release obligation, so it needs no `input` transfer clause.
An input reference does need one. `doc` is optional human-readable explanation.
A profile may also define defaults for its own vocabulary, with their meaning
specified in its manifest. Core requirements still apply, and a profile default
cannot turn an unknown fact into an authoritative answer
([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`A1`](../profiles.md#a1)).

<a id="ownership-in-clauses-not-types"></a>

## Expressing ownership

Consider two operations taking a store. `view` lets the caller keep ownership;
`destroy` takes responsibility for destruction at entry. Draft 0.1 writes
`store: Store` in both signatures and distinguishes them with `input` clauses
in their bodies ([`C3`](../contracts.md#c3)).

An alternative notation could put `borrow` or `consume` next to the parameter
type. It could also put `borrow` in the result type, as illustrated below.
This example describes a hypothetical mutable store: `replace` can end an
earlier view, and `close` ends the store's lifetime. The committed buffer
fixture instead describes an immutable store.

Alternative notation — illustrates ownership in a signature for a hypothetical
mutable store. This is a design possibility, not draft 0.1 AIL or a complete
package. The surrounding API and its other contracts would still be needed.

```text
    fn read(store: borrow Store) -> borrow bytes {
        lifetime result within store;
        invalidated result by replace(store), close(store);
    }
```

In the current example, `store: Store` and `ptr<u8>` describe types; `input`
states entry transfer and `give` states returned ownership or borrowing.
The pointer type constructors carry neither ownership nor extent
([`L4`](../language.md#l4), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

The parameter's `input` clause distinguishes [`consume`](../glossary.md#consume),
which transfers responsibility at entry including on failure, from
[`borrow`](../glossary.md#borrow), which leaves that responsibility in place.
Borrow describes permission to use the value; it implies no Rust-style static
checking ([`C3`](../contracts.md#c3)).

The clause form lets a reader follow transfer at entry and delivery on each
outcome separately. The signature form makes the broad ownership distinction
visible beside the type, while still needing somewhere to state the owner and
earlier [invalidators](../glossary.md#invalidation). Comparing these forms
requires examples with several outcomes as well as simple getters.

**No rationale for choosing clauses is recorded.** The design left ownership
placement for a decision based on an example corpus, and draft 0.1 uses clauses.
The costs above are observations about that form. They supply no missing
evidence about how the decision was made. [Q3](#q3) preserves that question.

## One clause syntax, with a closed vocabulary in prose

The synthetic `view` uses both `input($store, borrow);` and
`extent($result, buffer(16, 16, elements));`. They share a clause shape, but
their argument types and applicability come from different rules. Compare the
valid names with `fixture::invented(true);`: that spelling fits the generic
shape but names no defined fixture clause and is rejected
([`L1`](../language.md#l1), [`C3–C4`](../contracts.md#c3),
[`F1`](../profiles.md#f1); mutation N27).

The [grammar](../grammar.ebnf) defines `clause` as a name, parenthesized
arguments and a semicolon. Its `value` production handles nested constructors,
[places](../glossary.md#place), references and lists. The rule files enumerate
the accepted vocabulary and specify its argument types.
In summary (non-normative), parseability establishes neither a recognized clause
nor a valid use of it ([`L1`](../language.md#l1), [`L5`](../language.md#l5)).

Clause-specific grammar productions are an alternative. The uniform form gives
core and profile clauses one outer syntax, but costs discoverability: reading
the grammar does not reveal required clauses, their scopes or companions.
For example, `extent` lives in [`C4`](../contracts.md#c4), while
`callback_abi` is defined in [`A2`](../profiles.md#a2). A reader assembles both
syntax and meaning across the rules; an indexed reference can help lookup
without eliminating this split in the language's definition.

<a id="exact-environments"></a>

## Describing exact environments

The synthetic buffer author names target `fixture64` and platform `fixture`
version `1`. The object author adds `fixture-compiler` version `1`, needed for
the source-call route. A tool uses these values to decide which described
configuration it is examining ([`L3`](../language.md#l3),
[environment examples](packages.md#where-it-holds)).

Now consider a consumer running on platform version `2`. An exact claim for
version `1` supplies no answer about that configuration. A range such as
“version 1 and later” would claim coverage for it. The choice therefore affects
how much an author asserts about versions it has not listed
([`L3`](../language.md#l3)).

In summary (non-normative), draft 0.1 interprets environments as exact values,
not ranges. Unlisted configurations lie outside the claim. Changed signatures
or contracts require distinct declarations with disjoint [availability](../glossary.md#availability) or distinct
identities ([`L3`](../language.md#l3)).

Version-range algebra is the alternative. Exactness makes the claimed cases
explicit, but costs a potentially large matrix and repeated declarations when
contracts vary. These are consequences of the rule, not a recorded scaling
study. [Provider](../glossary.md#provider) interpretation still matters: an exact toolchain version alone
does not establish artifact compatibility ([`A1`](../profiles.md#a1),
[`A4`](../profiles.md#a4)).

## Profiles as the extension point

Suppose a caller wants to invoke two counter operations at the same time.
The core `concurrency(serial)` rule requires it to serialize independent calls
using the same receiver. A source-language tool may also need to know whether
the type satisfies a particular compiler conformance. The synthetic
`fixture::sendability(nonconforming)` records that separate answer.
A single “thread-safe” flag would leave the reader unable to distinguish
permission to overlap calls from a source conformance state
([`C2–C3`](../contracts.md#c2), [`F1`](../profiles.md#f1)).

Similarly, `execution(sync)` has a core meaning, while `execution(async)` needs
a profile defining suspension, scheduling and completion delivery. The latter
is recognized vocabulary but exceeds the synthetic fixture's capabilities
([`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

In summary (non-normative), profiles add versioned, typed semantics and specify
their validation and representation requirements. They cannot weaken the core.
Unknown normative attributes are errors, not ignorable extension payloads
([`L1`](../language.md#l1), [`A1`](../profiles.md#a1)).

AIL puts those extra definitions in versioned profiles. An alternative is to
put one source ecosystem's semantics directly into the core. That could make
the common case simpler for that ecosystem while making others depend on its
concepts. Another alternative is to let authors attach open-ended annotations.
Adding a new annotation would be easy, but independent consumers would need
some other agreement about its meaning.

AIL's profile choice costs substantial specification work: provider authors
define the vocabulary, its obligations, and how tools check and represent it.
Consumers can consequently differ in which profiles they support. A consumer
reports a required profile it cannot interpret before claiming complete
validation. A binding consumer can also understand a valid contract while
lacking the machinery to implement it ([`A1`](../profiles.md#a1),
[`A5`](../profiles.md#a5)).

<a id="what-draft-01-cannot-express"></a>

## Extending coverage beyond draft 0.1

A bounded synthetic example can be complete while a similarly shaped real API
needs further semantics. For example, the synthetic subscription's unique-owner
destructor establishes quiescence; an API whose cancellation merely requests
shutdown needs named events and ordering. The latter cannot be presented as
`quiescence(@cancel)` unless cancellation return really is that boundary
([`C6`](../contracts.md#c6)).

The [pressure-case catalogue](../conformance.md#pressure-cases-outside-the-synthetic-profile)
identifies cases that need further work before adoption. Some need extensions
to the language or a profile. Others already have useful core forms and need
authoritative API facts and a real provider. The distinction matters when
judging what the synthetic examples demonstrate.

**Generic and asynchronous operations need additional rules.** The synthetic
getter identifies one concrete source call. A generic family also needs rules
for permitted type arguments, substitution and the identity of each concrete
instantiation. An asynchronous operation needs rules for suspension and result
delivery. Throwing operations need the thrown type and its machine-level
handling. The fixture supports non-throwing synchronous entry and has no
generic-family support. An operation with a value receiver also needs its
receiver representation and effects specified; the core already supplies
mutation and consumption rules for the cases to which they apply
([`L4`](../language.md#l4), [`C3`](../contracts.md#c3),
[`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Optional operations need a check on the receiver.** Knowing the platform
version can establish that an interface is available. Calling an optional
member also requires establishing that the particular object implements it.
A profile supplies the capability test. A negotiated wire protocol similarly
needs rules for the capabilities of the particular session or object, together
with a mechanism for sending the request ([`C3`](../contracts.md#c3),
[`A1–A2`](../profiles.md#a1)).

**Native and managed calls need faithful representations and mappings.** A
native call may require a particular build artifact or a complete source build
recipe so both sides agree on layout. A managed projection needs to account
for runtime dispatch and the values callers observe. If a convenience call
hides a meaningful success status, it becomes a different declaration.
A compiler name or a familiar method spelling leaves this work outstanding
([`A2–A4`](../profiles.md#a2)).

**Variadic and source-only operations need their own access rules.** A
variadic function needs a schema for extra arguments, their promotions and
termination. An inline function or macro may require source compilation or
expansion. A provider distinguishes those mechanisms, including a macro that
expands to no code, so a consumer knows what action actually performs the
operation ([`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

**Richer layouts and ordering laws need specified extensions.** Packed records
need complete layout recipes; unions and bitfields exceed the fixture's
capabilities. More elaborate relationships between operations need typed laws
with defined obligations and checks. Adding explanatory prose alone supplies
neither a representation recipe nor a new law
([`L4`](../language.md#l4), [`L6`](../language.md#l6),
[`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

**Several real-API problems already have core forms.** A simple error-output
API can use exhaustive outcomes to say when its output is readable. An opaque
handle can name its release protocol. A mutable borrow can list its earlier
invalidators. An open enum can retain unnamed values across the full width of
its underlying type. Each still needs accurate facts about the API and a
suitable real provider; the synthetic cases establish no production support
([`L4`](../language.md#l4), [`C2`](../contracts.md#c2),
[`C5`](../contracts.md#c5), [`F1`](../profiles.md#f1)).

The alternative is to accept approximations or silently lower unsupported forms
to familiar ones. Draft 0.1 instead requires the complete applicable semantics
or refusal. That preserves distinctions but costs usable coverage: the supplied
synthetic fixture cannot demonstrate production Swift, Rust, Zig, CLR, COM/WinRT
or Wayland binding ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).
Refusal for missing provider support and refusal because a chosen target cannot
preserve a valid contract are different results ([`A5`](../profiles.md#a5)).

## Open questions

These questions concern draft 0.1's rules and notation. Each remains open.
The preceding explanations make the current behaviour inspectable; deciding
whether to change that behaviour or its presentation is a separate design task.

### Q1

**Question:** Does the keyword convention stated in `language.md` cover the
other two rule files, and do the authors want uniform keyword presentation?
**Where:** the opening of [language rules](../language.md) and the mixture of
uppercase keywords and ordinary lowercase requirements in
[contracts](../contracts.md) and [profiles](../profiles.md).
**Why it matters:** reviewers need consistent signals of normative force.
The mixture presents requirements in different styles. Lowercase wording
still states requirements in ordinary English; this question concerns
consistency of presentation and leaves their normative force in place.

### Q2

**Question:** Is using “closure” for both dependencies and callback captures
an acceptable vocabulary overlap?
**Where:** [`L2–L3`](../language.md#l2) and [`C2`](../contracts.md#c2).
**Why it matters:** binding authors use both concepts. These explanations
qualify [dependency closure](../glossary.md#dependency-closure) and
[callback captures](../glossary.md#callback-captures) without changing the
normative vocabulary.

### Q3

**Question:** What corpus evidence decided ownership placement in clauses,
and what did the type-based alternative cost?
**Where:** the [ownership comparison](#expressing-ownership),
[`L4`](../language.md#l4), [`C3`](../contracts.md#c3) and [`C5`](../contracts.md#c5).
**Why it matters:** it is a prominent readability and authoring choice, but
no rationale is recorded. The comparison above does not fill that gap.

### Q4

**Question:** Is the double spelling for [slots](../glossary.md#slot), with an overloaded `::`,
the intended trade-off?
**Where:** local `$result` or `$handler` in [`C1`](../contracts.md#c1), external
`@operation::result` or `@subscribe::handler` and imported `@Alias::name` in
[`L2`](../language.md#l2).
**Why it matters:** readers move between local obligations, pattern participants
and imported declarations; similar notation carries different relationships.

### Q5

**Question:** Is the split between entry validity and returned borrow validity
discoverable enough?
**Where:** `valid($store, call)` and `give($result, borrow(owner($store)))`
in [`view`](../examples/buffers.ail), governed by [`C1`](../contracts.md#c1),
[`C3`](../contracts.md#c3) and [`C5`](../contracts.md#c5).
**Why it matters:** keeping the store alive while using its returned view follows
from the output region. Reading the input clause alone misses that obligation.

### Q6

**Question:** Are section-level rule identifiers precise enough for diagnostics
and review comments, or are paragraph-level identifiers needed?
**Where:** the [mutation table](../conformance.md#rejection-mutations), including
mutations that cite the several distinct obligations in [`C3`](../contracts.md#c3).
**Why it matters:** a stable identifier helps locate a rule, but a broad section
can leave the reader searching for the exact rejecting condition.

Next: [Describing a small API](../tutorial/README.md) guides you through writing
and reading complete checkpoint packages. The guide *Reviewing AIL* is forthcoming.
For more examples, inspect the [conformance packages](../conformance.md#positive-specifications)
with their expected interpretations.
Return to [packages and access paths](packages.md) or [the overview](../README.md).
