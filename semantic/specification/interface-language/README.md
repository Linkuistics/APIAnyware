# API Interface Language

AIL is a proposed language for describing an existing API so that tools can help
programs in other languages use it correctly. For example, a library might
return a pointer to data that stays usable only while a particular object is
alive. A tool generating code to call that library needs to preserve that
relationship; a tool generating documentation needs to explain it to callers.
AIL gives both tools the same description to work from.

An [API binding](glossary.md#binding) is the code that makes an API available in
another language. The rules for using the API — what callers supply, what the
implementation promises, and who releases its resources — form its
[binding contract](glossary.md#binding-contract). AIL records that contract
alongside the API's declarations.

> **Purpose:** orientation — understand AIL's purpose and choose a reading route.
> **Reader:** language designers new to [API binding](glossary.md#binding); API authors and tool implementers.
> **Before this:** nothing.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [language](language.md), [contracts](contracts.md), [profiles](profiles.md) and [grammar](grammar.ebnf).

## Who this documentation serves

The primary reader knows language design and wants to judge AIL's notation,
concepts and authoring burden. API authors and tool implementers also need exact
rules. Useful feedback cites a rule or example, explains the difficulty, and
challenges the design where warranted.

<a id="the-problem-in-brief"></a>

## Who writes and uses an AIL description

An API author could write an AIL description from knowledge of the library.
An analysis tool could assemble one from declarations and other evidence, with
unresolved questions left for investigation before publication. Third-party
tools could produce descriptions too. AIL calls these people and tools
[*producers*](glossary.md#producer). Each producer writes a
[package](glossary.md#package): a named, versioned description of a stated part
of an API.

Consider a function that returns access to an object's bytes. The producer
records the function's parameters and result, which object keeps the bytes
alive, and which operations can make them unusable. A proposed validator would
check that the required facts are present and agree: for example, that the
named owner exists and has a suitable type. These checks are
[validation](glossary.md#validation). The same checks apply to a package
written by a person and one produced by an analysis tool.

Once the package meets those checks, other tools can use its description as
the API's stated contract. A binding generator uses the lifetime information
when arranging access to the bytes. A documentation renderer explains when a
caller can read them. An LLM tool can use those facts when helping a programmer
write a call sequence. AIL calls these tools [*consumers*](glossary.md#consumer).
They can present the information differently while retaining the same API facts.

This transition from assembling evidence to publishing a complete description
is the [*publication boundary*](glossary.md#publication-boundary). Validation
checks the description's completeness and consistency. Establishing that the
actual library behaves as described still requires evidence from its author,
review and implementation testing.
These are the proposed workflow and its limits (non-normative;
[`L2–L3`](language.md#l2), [`C1`](contracts.md#c1),
[`C8`](contracts.md#c8), [`A5`](profiles.md#a5)).

Some facts come from definitions shared by several packages. For example, a
tool needs rules for how arguments are passed to native code. A package names
a versioned [application binary interface (ABI)](glossary.md#abi) definition
for those machine-level rules.
It can also select a [profile](glossary.md#profile), a language extension that
defines additional types, clauses or ways to call an API. Each dependency has
an identifier, a version and a [digest pin](glossary.md#digest-pin) selecting
its exact bytes, so tools use the same definition. The map below shows these
dependencies alongside the proposed producers, validator and consumers
(non-normative; [`L2`](language.md#l2), [`A1`](profiles.md#a1)).

For a concrete introduction to the obligations those tools use, continue to
[Using an API across languages](explanation/unsaid.md).

![Producers submit to publication validation; the authoritative package pins profile and ABI entries and supplies the same contract to all consumers.](figures/g1-context.svg)

[Diagram source](figures/g1-context.puml) ·
[Figure vocabulary and regeneration](figures/style/vocabulary.txt)

## Paths through the documentation

Choose a starting page by the task you want to do. Each route supports a
different reading purpose.

| If you want to… | Start at… |
|---|---|
| Understand why the contract is needed | [Using an API across languages](explanation/unsaid.md) |
| Understand how clauses express obligations | [How AIL states a contract](explanation/contracts.md) |
| Understand package scope and how calls reach code | [Packages, environments and access paths](explanation/packages.md) |
| Assess alternatives, costs and limits | [Design choices, limits and open questions](explanation/choices.md) |
| Learn to read and write the notation | [Describing a small API](tutorial/README.md), with complete checkpoint packages |
| Review the design | [Conformance examples and pressure cases](conformance.md); the review guide *Reviewing AIL* is forthcoming |
| Look up a term or exact rule | [Glossary](glossary.md), then the canonical files below; the indexed *Reference* is forthcoming |

Continue from the domain page to [How AIL states a contract](explanation/contracts.md).
Then read [Packages, environments and access paths](explanation/packages.md)
and [Design choices, limits and open questions](explanation/choices.md).

## What is normative

The following files are normative **within this draft**:

- [Language and publication rules](language.md) (`L1`–`L6`), with the [EBNF grammar](grammar.ebnf).
- [Memory, effects and behavioural contracts](contracts.md) (`C1`–`C8`).
- [Profiles, access paths and ABI references](profiles.md) (`A1`–`A5`), including the [synthetic fixture catalogue](profiles.md#f1) (`F1`).

Rule identifiers are stable citation targets; wording can change during review.
Explanations and glossary entries help interpret those rules. When checking an
exact requirement, follow their citations back to the canonical files above.
The supporting material is:

- [Conformance requirements, mutations and review limits](conformance.md).
- Synthetic API examples: [buffers and output states](examples/buffers.ail),
  [callbacks and teardown](examples/callbacks.ail), and
  [objects and access alternatives](examples/objects.ail).
- [Mapping from the existing implementation](baseline.md), for maintainers.

These examples describe invented APIs. Their synthetic fixture
[profile](glossary.md#profile), catalogue and [digest tokens](glossary.md#digest-pin)
let readers inspect the language under stated test assumptions. Applying AIL
to a real operating-system API would also require real provider definitions and
evidence about that API. Development of native ABI providers, bindings and an
executable conformance suite remains future work. The
[verification record](conformance.md#verification-record) records historical
static checks and their limits; the current review is through the documents and
examples.

## Scope of draft 0.1

This is the first normative draft, dated 23 September 2026. The architecture is
approved; the detailed language is proposed for review. “API Interface Language”
and `.ail` are working names. AIL grew from APIAnyware's API-description work and
is not its implemented format.

The following is a non-normative scope summary. A package states which part and
release of an API it describes: its [surface](glossary.md#surface). It records
what the operations mean, how they are identified in their source language,
and how tools can reach their code or data through
[access paths](glossary.md#access-path). For example, a path might identify a
linker symbol or a call that a source compiler must build
([`L2–L4`](language.md#l2), [`A1–A2`](profiles.md#a1)).

Completeness applies to the chosen surface. Consider a watch API that lets a
program register for notifications when something changes. A package covering
that API could leave out an unrelated image API. It would still need to describe
the watch's returned values and [callback](glossary.md#callback) types, and whatever those declarations
depend on in turn. That full set is the
[dependency closure](glossary.md#dependency-closure). Producers resolve missing
facts and competing claims before publication; analysis notes and confidence
scores remain in their working materials ([`L2–L3`](language.md#l2)).

Some APIs deliberately hide their internal layout. An
[opaque resource](glossary.md#opaque-resource) describes this case through its
operations and lifetime rules. The producer can give a complete account of how
to use and destroy a watch while keeping its implementation private. A value
passed by value instead needs the [representation](glossary.md#representation)
information required to pass it correctly
([`L4`](language.md#l4), [`A3`](profiles.md#a3)).

The core describes named declarations and their scalar and aggregate types.
It records who releases values, how long access remains valid, when callbacks
can run and whether calls may overlap. It also describes properties,
relationships and reusable [patterns](glossary.md#pattern), such as a resource's
relationship to its destructor ([`L4–L6`](language.md#l4),
[`C1–C8`](contracts.md#c1)).

An operation's [outcomes](glossary.md#outcome) describe the cases a caller can
observe when it finishes, such as a null failure or a non-null success. AIL
limits the tests used to distinguish those cases so a validator can check that
they cover every possibility exactly once ([`C5`](contracts.md#c5)).
[Profiles](glossary.md#profile) add source-language and access semantics through
typed, versioned clauses. A tool claiming full validation needs to understand
every required extension and check its rules
([`L1`](language.md#l1), [`A1`](profiles.md#a1)).

Draft 0.1 names a finite set of exact deployment
[environments](glossary.md#environment), such as a particular target and
platform version. Version-range algebra, arbitrary dependent types, generic
constraint solving, bitfield layout, unions and complete Swift/Rust/Zig/CLR/Wayland
profiles remain beyond this draft's defined support. Describing an API that
needs one of these features requires a fully specified profile or a later
language version. Fully specified, profile-supported source-only access is
legitimate: a compiler can build a call even when direct symbol access is
unavailable ([`L3–L4`](language.md#l3), [`A1–A4`](profiles.md#a1);
[pressure cases](conformance.md#pressure-cases-outside-the-synthetic-profile)).

A smaller surface can make the work manageable when all of that surface's
dependencies and obligations can be described. Required facts about an included
declaration still need answers ([`L2–L3`](language.md#l2)).
[Design choices, limits and open questions](explanation/choices.md) explains the
trade-offs and the cases that call for more language or provider support.

## Design history

The [approved architecture](../../docs/design/2026-09-22-interface-language.md),
[initial language survey](../../docs/research/2026-09-22-interface-language-a.md)
and [specification-writing plan](../../docs/design/2026-09-22-interface-language-plan.md)
record the design basis. The
[documentation survey](../../docs/research/documentation-basis-a.md),
[documentation audit](../../docs/research/interface-language-documentation-audit.md)
and [documentation plan](../../docs/design/2026-09-23-interface-language-documentation-plan.md)
explain this reader-oriented presentation. Production libraries, parsers and
APIAnyware adoption belong to separate phases.

Next: [Using an API across languages](explanation/unsaid.md).
