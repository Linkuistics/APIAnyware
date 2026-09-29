# Design choices, limits and open questions

> **Purpose:** explanation — assess how AIL's choices express the API model and support a reader inspecting its contracts.
> **Reader:** language designers evaluating the notation after orientation and the concept explanations.
> **Before this:** [A model of API behaviour and binding obligations](model.md), [How AIL states a contract](contracts.md) and [Packages, environments and access paths](packages.md).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L1–L6`](../language.md#l1), [`C1–C8`](../contracts.md#c1) and [`A1–A5`](../profiles.md#a1) are canonical; this page is non-normative.

## How to read this page

Judge each language choice by how well it helps authors express the
[API model](model.md) and readers inspect its contracts. A reviewer should
be able to find what an API promises, relate that promise to the other obligations,
and see what the notation asks authors and tools to supply. The sections
below name the concepts each choice concerns and compare what it makes easy
or hard to express and inspect.

Start with [validity](model.md#validity) and
[release responsibility](model.md#responsibility): to use a returned view,
the reader needs to establish how long access lasts and who keeps the
underlying storage alive.

Suppose a library lends bytes from a store. The caller needs the storage to
remain usable while reading those bytes. This requirement comes from the
binding domain: any [binding](../glossary.md#binding) needs to respect it.
The API author then decides what the library promises. An immutable store
might keep the bytes usable until destruction; a mutable store might replace
them sooner.

AIL's design determines how an author writes that promise. The [clause](../glossary.md#clause)
[`give($result, borrow(owner($store)))`](../reference/clauses-outcomes.md#give) relates the returned pointer to the
store's lifetime. [`invalidated_by`](../reference/clauses-outcomes.md#invalidated_by) names operations that end access earlier.
Those spellings, and the decision to separate the two facts, are language
choices ([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

Fragment — locates that promise in the synthetic immutable store's `view`.
The complete [buffer package](../examples/buffers.ail) supplies `Store`, its
lifetime, package context, effects, pointer extent and access path. Its
profile, ABI catalogue and digest tokens are synthetic ([`F1`](../profiles.md#f1)).

<!-- ail-example: ../examples/concepts/choices.ail region=borrow -->
```ail
fn view(store: Store) -> ptr<u8> {
  input($store, borrow);
  valid($store, call);
  outcome viewed {
    when(returned, any);
    meaning(success);
    state($result, valid);
    give($result, borrow(owner($store)));
    invalidated_by($result, []);
  }
  // Retention, remaining effects, extent, contents and access omitted.
}
```

The signature names a `Store` parameter and a pointer-to-byte result.
`$store` addresses the input and `$result` the return value locally to `view`.
`outcome viewed` describes [how a call finishes](model.md#outcomes) and
contains the returned obligations; `give` supplies borrowing within the
owner's lifetime, and `invalidated_by($result, [])` records no
earlier [invalidator](../glossary.md#invalidation). The full function later
on this page shows the cost of stating all the other facts too ([`C1`](../contracts.md#c1),
[`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

The same distinction applies to [callbacks and their schedules](model.md#callbacks).
A [callback](../glossary.md#callback)'s
saved values, or [captures](../glossary.md#callback-captures), stay usable while
an invocation can still need them. An API can promise that teardown waits for
all callback use to finish. AIL expresses that particular promise with
[`quiescence(@unsubscribe)`](../glossary.md#quiescence)
([`C6`](../contracts.md#c6)).

Fragment — locates the callback schedule inside the synthetic registration
operation. The complete [callback package](../examples/callbacks.ail) supplies
`Handler`, `Subscription`, its destructor `unsubscribe`, and the remaining
contracts, including retention in the same owner region.

<!-- ail-example: ../examples/concepts/choices.ail region=callback -->
```ail
fn subscribe(handler: Handler) -> Subscription {
  input($handler, borrow);
  retain($handler, strong(owner($result)));
  valid($handler, call);
  callback $handler {
    timing(after_return);
    count(0, many);
    scope(owner($result));
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    quiescence(@unsubscribe);
  }
  // Effects, outcome and access omitted.
}
```

`callback $handler` locates the schedule on `subscribe`'s parameter.
`@unsubscribe` names a separate declaration: the destructor that ends all
callback use before returning. [`scope(owner($result))`](../reference/clauses-outcomes.md#scope) ties the schedule to
the returned subscription. The `retain` clause keeps a strong reference to
the handler for that same owner region. [`count(0, many)`](../reference/clauses-outcomes.md#count) states a known permission for zero
or more invocations, conditional on eventual scope end; it supplies no promise
that a notification will arrive ([`C6`](../contracts.md#c6)).

This page distinguishes the domain requirement, the API's promise and AIL's
way of stating it. The benefits and costs below assess the published design.
Alternatives show what a different language design could make easier or harder;
they leave draft 0.1's rules in place. The register at the end keeps the open
questions available for review, including the missing rationale for placing
ownership in clauses.

Use this comparison to keep the three decisions separate when assessing a
borrowed view.

| Level | What it establishes for the view |
|---|---|
| Binding domain | The caller needs usable storage for as long as it reads the bytes. |
| API contract | The library promises how long storage stays usable: until store destruction, or until an earlier replacement. |
| AIL notation | The author writes the owner lifetime in `give` and earlier cutoffs in `invalidated_by`. |

All conformance examples mentioned here use the synthetic fixture's
[profile](../glossary.md#profile), ABI catalogue and
[digest tokens](../glossary.md#digest-pin) defined by [`F1`](../profiles.md#f1).
The profile defines a versioned semantic extension. The examples describe
invented APIs rather than actual platform contracts.

The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows what API authors and tools do with a description. This page asks what
AIL's choices require of those people and tools, and what alternatives would
change for them.

The following sections develop each choice through examples. This table is a
map to those discussions; each cost concerns work an author or tool must do.

| Draft 0.1 choice | Alternative discussed below | Cost to inspect |
|---|---|---|
| Dedicated syntax | Extend an interface language such as WIT, or adopt a source language's syntax | New vocabulary, corpus and tooling |
| Publish a complete description of a chosen subset | Publish unresolved facts for consumers to interpret | Author investigates required facts before publishing |
| Write each applicable fact | Use defaults or shorthand | Author writes clauses even when the answer is `none` |
| Put ownership in clauses | Put ownership in types/signatures | Reader follows the body to find transfers; rationale remains Q3 |
| Use one outer clause syntax | Give each clause its own grammar production | Reader also needs the rule files to learn permitted clauses |
| List exact environments | Use version ranges | Author lists configurations and separates contracts that vary |
| Add versioned profiles | Put source-specific rules in the core or allow open annotations | Provider authors specify each extension; consumers need support for it |

## A dedicated syntax

The language has to connect [operations and their values](model.md#operations)
to [entities that outlive a call](model.md#entities),
[release responsibility](model.md#responsibility) and
[reaching the code](model.md#access). To assess a dedicated syntax, consider
whether a reader can follow those relationships across APIs with different
lifetime and calling mechanisms.

The [intended scope](../README.md#apis-and-languages-in-scope) spans source
languages and platforms, with an emphasis on libraries with typed contracts.
The comparison therefore asks how each notation serves that common model
and the tools using it. Programs calling the described APIs can use different
languages again, including interpreted and dynamically typed languages.

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

Another alternative is to adopt a source language's declaration syntax and
extend it with the missing contract facts. That would keep descriptions close
to declarations in that language and familiar to its authors. The comparison
needs to distinguish reusable notation from the language's assumptions about
types, lifetimes and calls. Authors and tools would need to express the other
APIs' contracts faithfully wherever those assumptions differ. This is a test
for any candidate source language; no one language defines the common model.
These are trade-offs to assess; neither alternative is established to be
impossible.

Dedicated syntax avoids inheriting all the meanings and assumptions of either notation.
Its cost is a new vocabulary, a conformance corpus and future tooling to learn
and maintain. Familiar braces and function arrows do not remove that cost:
`Store` already denotes a handle, while ownership is stated in separate
[clauses](../glossary.md#clause)
([`L4`](../language.md#l4)). Familiar syntax alone cannot supply the missing
contract.

<a id="complete-contracts-only"></a>

## Publishing a complete description

This choice concerns [the published description](model.md#description) and
the agreement among [writers, checkers and users](model.md#agreement).
The reader needs settled facts for the API subset being assessed. Requiring
completeness lets consumers follow those facts through dependencies; it also
requires authors to resolve every applicable uncertainty before publishing.

An author can publish a [package](../glossary.md#package) describing only an
immutable sixteen-byte store, as the synthetic buffer example does. The
stated API subset and release are its [surface](../glossary.md#surface).
The author supplies enough information to create, use and destroy that store.
An unrelated storage API can remain outside the chosen surface
([`L3`](../language.md#l3)).

Fragment — locates publication claims and a lifetime dependency at package
level. The complete [buffer package](../examples/buffers.ail) supplies the
exported declarations and their contracts, environment and synthetic providers.

<!-- ail-example: ../examples/concepts/choices.ail region=publication -->
```ail
package example::buffers version "1" {
  surface("A synthetic immutable sixteen-byte store and its complete lifetime API.");
  exports([@Store, @create, @destroy, @view, @copy_bytes, @store_lifetime]);
  resource Store {
    lifecycle(unique, @destroy);
    // Other nominal contracts omitted.
  }
  // Header, dependencies, environment and remaining declarations omitted.
}
```

`surface` states the subset; `exports` lists public starting declarations.
Each `@` reference selects a declaration in this package. Following
`lifecycle(unique, @destroy)` leads from the resource to its destructor.
This fragment omits the `destroy` declaration, while the complete
package includes it ([`L2–L3`](../language.md#l2), [`C2`](../contracts.md#c2)).

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
consumers to interpret. Each [consumer](../glossary.md#consumer) would then decide how to handle a missing
fact or choose among competing candidates. AIL places that investigation with
the [producer](../glossary.md#producer), before the transition to a published contract — its
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

The agreement among [writers, checkers and users](model.md#agreement)
depends on recognizing an established fact, including known absence. To
assess explicit clauses, compare what they let a reader verify with the
repetition they require from an author. The first examples concern
[where and when calls run](model.md#execution).

For the synthetic store, the author has established that the type adds no
restriction on which [executor](../glossary.md#executor) may use it.
`isolation(none)` records that fact. For the counter,
the author has established that use belongs on the main thread and writes
`isolation(main)`. Both clauses answer the same question about
[isolation](../glossary.md#isolation). Omitting a required clause leaves the
question unanswered ([`L3`](../language.md#l3), [`C2`](../contracts.md#c2)).

Fragment — locates the two isolation facts on their nominal declarations.
The complete [buffer](../examples/buffers.ail) and [object](../examples/objects.ail)
packages supply their other contracts and synthetic dependencies.

<!-- ail-example: ../examples/concepts/choices.ail region=isolation -->
```ail
resource Store {
  sharing(transferable);
  isolation(none);
  // Lifetime and other nominal contracts omitted.
}
object Counter {
  sharing(confined);
  isolation(main);
  // Lifetime and other nominal contracts omitted.
}
```

The store's `sharing(transferable)` permits moving sole ownership between
executors. The counter's `sharing(confined)` restricts use to its declared
executor, here `main`; the operation contracts also respect that restriction
([`C2–C3`](../contracts.md#c2)).

The same distinction applies to [retention](../glossary.md#retention).
`view` promises to store no reference for later use through
`retain($store, none)`. The synthetic subscription does keep its handler,
tying storage to the returned owner's lifetime, or
[region](../glossary.md#region). A reader sees an explicit answer in both
cases ([`C3`](../contracts.md#c3)).

The authoring cost is visible in this entire synthetic `view` declaration.
Its facts connect [operations and their values](model.md#operations),
[how a call finishes](model.md#outcomes),
[release responsibility](model.md#responsibility), [validity](model.md#validity)
and [storage](model.md#storage). Availability locates the operation in
[the published description](model.md#description); its access path records
[reaching the code](model.md#access). Read the groups together to see what
a signature alone would leave open.

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

For [release responsibility](model.md#responsibility), the reader needs to
find who takes or receives a release duty. Returned borrowing also connects
that answer to [validity](model.md#validity) and
[how a call finishes](model.md#outcomes). This choice concerns where those
facts appear: beside the types in a signature, or in clauses that can refer
to an input, an owner and an individual outcome.

Consider two operations taking a store. `view` lets the caller keep ownership;
`destroy` takes responsibility for destruction at entry. Draft 0.1 writes
`store: Store` in both signatures and distinguishes them with `input` clauses
in their bodies ([`C3`](../contracts.md#c3)).

Fragment — locates consumption in the synthetic store's destructor.
The complete [buffer package](../examples/buffers.ail) supplies the remaining
contracts; compare the `input($store, borrow)` clause in `view` above.

<!-- ail-example: ../examples/concepts/choices.ail region=consume -->
```ail
fn destroy(store: Store) -> unit {
  input($store, consume);
  retain($store, none);
  // Effects, successful outcome and access omitted.
}
```

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
states entry transfer and [`give`](../reference/clauses-outcomes.md#give) states returned ownership or borrowing.
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

The comparison shows where a reader looks for each ownership fact. The
alternative illustrates a possible notation, with the mutable-store limits
stated above.

| Fact to find | Draft 0.1 clauses | Illustrated signature alternative |
|---|---|---|
| Entry borrowing | `input($store, borrow)` in the body | `borrow Store` beside the parameter |
| Returned borrowing | `give($result, borrow(owner($store)))` in an outcome | `borrow bytes` beside the result |
| Owner lifetime | `owner($store)` within `give` | `lifetime result within store` in the body |
| Earlier invalidation | [`invalidated_by`](../reference/clauses-outcomes.md#invalidated_by) in an outcome | `replace(store)` in the body's `invalidated result by ...` statement |

**No rationale for choosing clauses is recorded.** The design left ownership
placement for a decision based on an example corpus, and draft 0.1 uses clauses.
The costs above are observations about that form. They supply no missing
evidence about how the decision was made. [Q3](#q3) preserves that question.

## One clause syntax, with a closed vocabulary in prose

This choice affects how [writers, checkers and users](model.md#agreement)
find and interpret facts across the model. A reader inspecting
[release responsibility](model.md#responsibility) or [storage](model.md#storage)
meets the same outer clause form, while the relevant rules determine which
facts it can express. Assess the ease of recognizing a clause alongside the
work of discovering its permitted arguments and scope.

The synthetic `view` uses both `input($store, borrow);` and
`extent($result, buffer(16, 16, elements));`. They share a clause shape, but
their argument types and applicability come from different rules. Compare the
valid names with `fixture::invented(true);`: that spelling fits the generic
shape but names no defined fixture clause and is rejected
([`L1`](../language.md#l1), [`C3–C4`](../contracts.md#c3),
[`F1`](../profiles.md#f1); mutation N27).

The [clause grammar](../reference/notation.md#clause) admits the common form
used by core and profile clauses. The rule files enumerate the accepted
vocabulary and specify its argument types.
In summary (non-normative), a parser can recognize the common clause shape.
A validator also checks that the clause name is defined and that its arguments
and location satisfy the rules ([`L1`](../language.md#l1), [`L5`](../language.md#l5)).

In the complete `view` above, `input($store, borrow)` leaves release
responsibility with the caller. `extent($result, buffer(16, 16, elements))`
states how much returned storage is initialized and allocated. Both address
callable-local [places](../glossary.md#place), but the rules give those
arguments different jobs. A familiar clause shape helps locate a fact;
understanding its meaning still requires the relevant contract rule.

Clause-specific grammar productions are an alternative. The uniform form gives
core and profile clauses one outer syntax, but costs discoverability: reading
the grammar does not reveal required clauses, their scopes or companions.
For example, `extent` lives in [`C4`](../contracts.md#c4), while
[`callback_abi`](../reference/clauses-access.md#callback_abi) is defined in [`A2`](../profiles.md#a2). A reader assembles both
syntax and meaning across the rules; an indexed reference can help lookup
without eliminating this split in the language's definition.
The later design question in [Q7](#q7) also asks whether distinct syntactic
forms could make each kind of obligation easier to recognize from its notation.

<a id="exact-environments"></a>

## Describing exact environments

For [the published description](model.md#description), a reader needs to
establish where the claims hold. Listing exact environments makes each
covered configuration inspectable. The comparison with version ranges below
shows what this choice requires authors to enumerate and which claims it
leaves outside the description.

The synthetic buffer author names target `fixture64` and platform `fixture`
version `1`. The object author adds `fixture-compiler` version `1`, needed for
the source-call route. A tool uses these values to decide which described
configuration it is examining ([`L3`](../language.md#l3),
[environment examples](packages.md#where-it-holds)).

Fragment — locates one exact environment and its use on a declaration.
The complete [buffer package](../examples/buffers.ail) supplies publication,
providers, the function's contract and the other declarations.

<!-- ail-example: ../examples/concepts/choices.ail region=environment -->
```ail
package example::buffers version "1" {
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  fn view(store: Store) -> ptr<u8> {
    available([test]);
    // Other callable contracts omitted.
  }
  // Header, dependencies, publication and remaining declarations omitted.
}
```

`available([test])` connects `view` to the configuration named `test`. The
[provider](../glossary.md#provider) interprets the exact target and platform values ([`L3`](../language.md#l3)).

Now consider a consumer running on platform version `2`. An exact claim for
version `1` supplies no answer about that configuration. A range such as
“version 1 and later” would claim coverage for it. The choice therefore affects
how much an author asserts about versions they have not listed
([`L3`](../language.md#l3)).

Compare what each form would claim for those two platform versions. The range
is an alternative design, while the exact claim is draft 0.1's form.

| Coverage statement | Platform version `1` | Platform version `2` |
|---|---|---|
| Exact version `1` | Within the claim | Outside the claim |
| Alternative range “version 1 and later” | Within the claim | Within the claim |

In summary (non-normative), draft 0.1 interprets environments as exact values,
not ranges. Unlisted configurations lie outside the claim. Changed signatures
or contracts require distinct declarations with disjoint [availability](../glossary.md#availability) or distinct
identities ([`L3`](../language.md#l3)).

An alternative would let authors describe and combine version ranges.
Exactness makes the claimed cases explicit. Its cost is the work of listing
each configuration and repeating declarations where contracts vary. The rule
establishes that work; how it scales to a large API remains unmeasured.
[Provider](../glossary.md#provider) interpretation still matters: a compiler
version identifies only part of what tools need to determine whether separately
built artifacts work together ([`A1`](../profiles.md#a1),
[`A4`](../profiles.md#a4)).

## Profiles as the extension point

Profiles extend the agreement among
[writers, checkers and users](model.md#agreement). To assess this choice,
follow what a consumer needs to understand an added fact. The examples
concern [where and when calls run](model.md#execution): core call permissions
and source-specific conformance or suspension rules answer different questions.

Suppose a caller wants to invoke two counter operations at the same time.
The core `concurrency(serial)` rule requires it to serialize independent calls
using the same receiver. A source-language tool may also need to know whether
the type satisfies a particular compiler conformance. The synthetic
[`fixture::sendability(nonconforming)`](../reference/clauses-access.md#fixture-sendability) records that separate answer.
A single “thread-safe” flag would leave the reader unable to distinguish
permission to overlap calls from a source conformance state
([`C2–C3`](../contracts.md#c2), [`F1`](../profiles.md#f1)).

Fragment — locates the profile fact on the synthetic object and the core
concurrency fact on its member function. The complete
[object package](../examples/objects.ail) supplies the `fixture` selection,
other nominal contracts, function effects, outcomes and access paths.

<!-- ail-example: ../examples/concepts/choices.ail region=profile -->
```ail
package example::objects version "1" {
  object Counter {
    fixture::sendability(nonconforming);
    // Other nominal contracts omitted.
  }
  fn read_count(receiver: Counter) -> u64 {
    member(@Counter, instance);
    receiver($receiver);
    concurrency(serial);
    // Input, remaining effects, outcome and access omitted.
  }
  // Header, provider pins, environment and publication context omitted.
}
```

`fixture::sendability` selects vocabulary from the named profile.
`member(@Counter, instance)` associates the package-level function with
`Counter`, and `receiver($receiver)` chooses its ordinary named parameter.
The conformance fact belongs to the object; concurrency governs calls using
that receiver ([`L5`](../language.md#l5), [`C2–C3`](../contracts.md#c2),
[`F1`](../profiles.md#f1)).

Similarly, `execution(sync)` has a core meaning, while `execution(async)` needs
a profile defining suspension, scheduling and completion delivery. The latter
is recognized vocabulary but exceeds the synthetic fixture's capabilities
([`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

Fragment — compares execution clauses inside two callable bodies. `view`
is from the synthetic [buffer package](../examples/buffers.ail). The constructed
`fetch` needs a different profile with asynchronous semantics; a complete
package would also supply its input, output, access and other contracts.

<!-- ail-example: ../examples/concepts/choices.ail region=execution -->
```ail
fn view(store: Store) -> ptr<u8> {
  execution(sync);
  completions([returned]);
  // Other callable contracts omitted.
}
fn fetch(store: Store) -> ptr<u8> {
  execution(async);
  completions([returned]);
  // Requires an asynchronous profile and the remaining callable contracts.
}
```

Both list a returned completion; the profile for `fetch` would define how
that completion reaches the caller after suspension. This fragment asserts
no delivery or termination guarantee ([`C3`](../contracts.md#c3)).

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

The coverage question tests the agreement among
[writers, checkers and users](model.md#agreement): an author needs to express
the API's actual distinctions, and a consumer needs to preserve them.
For each case below, separate facts the core can already state
from meanings that need a specified extension. This makes the cost of the
current boundary visible without treating a synthetic example as evidence
for a real provider.

A bounded synthetic example can be complete while a similarly shaped real API
needs further semantics. For [callbacks and their schedules](model.md#callbacks),
the synthetic subscription's unique-owner
destructor establishes quiescence; an API whose cancellation merely requests
shutdown needs named events and ordering. The latter cannot be presented as
[`quiescence(@cancel)`](../reference/clauses-outcomes.md#quiescence) unless cancellation return really is that boundary
([`C6`](../contracts.md#c6)).

The [pressure-case catalogue](../conformance.md#pressure-cases-outside-the-synthetic-profile)
identifies cases that need further work before adoption. Some need extensions
to the language or a profile. Others already have useful core forms and need
authoritative API facts and a real provider. The distinction matters when
judging what the synthetic examples demonstrate.

**Generic and asynchronous operations need additional rules.** These connect
[operations and their values](model.md#operations),
[how a call finishes](model.md#outcomes) and
[where and when calls run](model.md#execution). The synthetic
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

**Optional operations need a check on the receiver.** The distinction is
between the configurations in [the published description](model.md#description)
and the capabilities of [entities that outlive a call](model.md#entities).
Knowing the platform version can establish that an interface is available. Calling an optional
member also requires establishing that the particular object implements it.
A profile supplies the capability test. A negotiated wire protocol similarly
needs rules for the capabilities of the particular session or object, together
with a mechanism for sending the request ([`C3`](../contracts.md#c3),
[`A1–A2`](../profiles.md#a1)).

**Native and managed calls need faithful representations and mappings.** For
[reaching the code](model.md#access), a
native call may require a particular build artifact or a complete source build
recipe so both sides agree on layout. A managed projection needs to account
for runtime dispatch and the values callers observe. If a convenience call
hides a meaningful success status, it becomes a different declaration.
A compiler name or a familiar method spelling leaves this work outstanding
([`A2–A4`](../profiles.md#a2)).

**Variadic and source-only operations need their own access rules.**
[Operations and their values](model.md#operations) need a defined route for
[reaching the code](model.md#access). A
variadic function needs a schema for extra arguments, their promotions and
termination. An inline function or macro may require source compilation or
expansion. A provider distinguishes those mechanisms, including a macro that
expands to no code, so a consumer knows what action actually performs the
operation ([`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

**Richer layouts and ordering laws need specified extensions.**
[Storage](model.md#storage) and [entities that outlive a call](model.md#entities)
need precise representation and relationship rules. Packed records
need complete layout recipes; unions and bitfields exceed the fixture's
capabilities. More elaborate relationships between operations need typed laws
with defined obligations and checks. Adding explanatory prose alone supplies
neither a representation recipe nor a new law
([`L4`](../language.md#l4), [`L6`](../language.md#l6),
[`A3`](../profiles.md#a3), [`F1`](../profiles.md#f1)).

**Several real-API problems already have core forms.** A simple error-output
API can use exhaustive outcomes to describe [how a call finishes](model.md#outcomes)
and when its output is readable. An author can name a release protocol for
[entities that outlive a call](model.md#entities), represented by opaque handles,
establishing
[release responsibility](model.md#responsibility). A mutable borrow can state
its [validity](model.md#validity) by listing earlier invalidators. Among
[operations and their values](model.md#operations), an open enum can retain
unnamed values across the full width of
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
**Where:** `valid($store, call)` and [`give($result, borrow(owner($store)))`](../reference/clauses-outcomes.md#give)
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

### Q7

**Question:** Could clause-specific syntactic forms communicate the different
obligations and relationships more clearly than the uniform function-call-like
`name(arguments);` form?
**Where:** the [clause comparison](#one-clause-syntax-with-a-closed-vocabulary-in-prose),
the [clause grammar](../reference/notation.md#clause), and the ownership,
validity, storage and callback examples above.
**Why it matters:** words, ordering and enclosing structure can help readers
anticipate a clause's meaning. A later design exploration should compare that
benefit with learning several forms and extending them through profiles,
using the same API contracts in each notation. This is a question for later
language design; draft 0.1 retains its current grammar and semantics.

Next: [Describing a small API](../tutorial/README.md) guides you through writing
and reading complete checkpoint packages. Then use [Reviewing AIL](../review/README.md)
to assess the design and record feedback. For more examples, follow the
[conformance walkthroughs](../review/walkthroughs.md).
Return to [packages and access paths](packages.md) or [the overview](../README.md).
