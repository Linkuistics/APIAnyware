# Design choices, limits and open questions

> **Purpose:** explanation — distinguish binding constraints from AIL's choices and inspect their costs and limits.
> **Reader:** language designers evaluating the notation after orientation and the concept explanations.
> **Before this:** [How AIL states a contract](contracts.md) and [Packages, environments and access paths](packages.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L1–L6`](../language.md#l1), [`C1–C8`](../contracts.md#c1) and [`A1–A5`](../profiles.md#a1) are canonical; this page is non-normative.

## How to read this page

A binding that uses a view after its storage dies has violated a domain
constraint. Expressing the lifetime with `give($result, borrow(owner($store)))`
is a language choice. Likewise, a [callback](../glossary.md#callback) needs its
captures while an invocation can still run; expressing safe teardown through
`quiescence(@unsubscribe)` is AIL's chosen form
([`C1`](../contracts.md#c1), [`C5–C6`](../contracts.md#c5)).

This page keeps those two levels distinct. Where the
[design proposal](../../../docs/design/2026-09-22-interface-language.md) records
a reason, it is attributed. Other benefits and costs are an assessment of the
published rules, not a reconstruction of the authors' intent. Alternatives
describe possible designs; none changes draft 0.1. The register at the end
preserves open questions without answering them.

All conformance examples mentioned here use the synthetic fixture
[profile](../glossary.md#profile), catalogue and
[digest tokens](../glossary.md#digest-pin) defined by [`F1`](../profiles.md#f1).
They describe invented APIs rather than actual platform contracts.

## A dedicated syntax

Compare the synthetic store's uniquely owned handle with the synthetic counter's
reference-counted object and message/source access alternatives. A common format
needs to describe both lifetime disciplines and both ways of reaching code
([`C2`](../contracts.md#c2), [`A2`](../profiles.md#a2);
[buffers](../examples/buffers.ail), [objects](../examples/objects.ail)).

The [proposal's alternatives table](../../../docs/design/2026-09-22-interface-language.md#2-recommended-shape-and-alternatives)
chooses a common semantic core with explicit profiles and ABI references.
It considers extending WIT and extending Swift interface syntax. The recorded
cost for the WIT option is demonstrating that native lifetime, dispatch and
representation fit without conflicting meanings or opaque annotation bags.
The recorded cost for the Swift option is making other source languages and
independent consumers depend on Swift-shaped semantics. These are the proposal's
design assessments, not a finding that either extension is impossible.

Dedicated syntax avoids inheriting either notation's whole semantic frame.
Its cost is a new vocabulary, a conformance corpus and future tooling to learn
and maintain. Familiar braces and function arrows do not remove that cost:
`Store` already denotes a handle, while ownership lives in separate clauses
([`L4`](../language.md#l4)). Familiar syntax alone cannot supply the missing
contract.

## Complete contracts only

The synthetic buffer package is complete for an immutable sixteen-byte store;
it makes no claim to cover a general storage library. Deleting its returned
view's ownership clause would instead leave an obligation of that declared
surface missing ([`L3`](../language.md#l3), [`C5`](../contracts.md#c5)).

In summary (non-normative), a producer can publish a declared subset with its
whole [dependency closure](../glossary.md#dependency-closure), but cannot publish
required facts as `unknown`, confidence scores or promises of later inference.
The producer resolves conflicting evidence before publication. Validation checks
completeness and internal consistency; it cannot prove that an implementation
honours the assertions ([`L2–L3`](../language.md#l2), [`C8`](../contracts.md#c8)).

An alternative is a partial model that preserves unresolved candidates for
consumers to interpret. AIL's [publication boundary](../../../docs/design/2026-09-22-interface-language.md#3-publication-boundary)
places that work upstream. This spares consumers from deciding which guesses
count as facts, but costs the producer investigation and resolution before
publication. A mostly described API can remain unpublishable.

A broad established permission is still a complete fact. The synthetic
subscription permits zero or more callback invocations; `many` is an unbounded
maximum, not a missing answer. Conversely, an uninvestigated callback count
cannot be disguised by that permission ([`C6`](../contracts.md#c6),
[contract introduction](../contracts.md)).

## Everything explicit

A binding needs to distinguish known absence from a fact nobody checked. The
synthetic `Store` states `isolation(none)`; `Counter` states `isolation(main)`.
An omitted required isolation clause supplies neither answer. Likewise,
`retain($store, none)` in `view` promises no retention, whereas the synthetic
subscription explicitly retains its handler for an owner region
([`L3`](../language.md#l3), [`C2–C3`](../contracts.md#c2)).

The authoring cost is visible in this entire synthetic `view` declaration.

Fragment — omits the containing package, `Store` and its destructor, environment,
and synthetic fixture profile, catalogue and digest tokens; not a publishable
package.

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
the function body, five in the outcome and four in the access path. That count
excludes all surrounding package and dependency declarations. It measures this
example's written burden, not average authoring effort. The rules behind these
groups are [`L3`](../language.md#l3), [`L5`](../language.md#l5),
[`C3–C5`](../contracts.md#c3) and [`A2`](../profiles.md#a2).

AIL chooses explicit applicable facts over inferring “ordinary” ownership,
threading or access from names. Defaults or shorthand could reduce repetition;
the cost of the current form is writing and reviewing clauses even for known
absence. Its benefit is that independent consumers see the same stated answers
([`L3`](../language.md#l3), [`C8`](../contracts.md#c8)).

This does not mean every clause is required or that every default is forbidden.
For example, `doc` is optional, and a profile manifest specifies defaults if it
has any. Profiles cannot weaken a core requirement or turn an unknown fact
into an authoritative default ([`L5`](../language.md#l5), [`A1`](../profiles.md#a1)).

## Ownership in clauses, not types

The [historical design sketch](../../../docs/design/2026-09-22-interface-language.md#7-dedicated-syntax-direction)
placed some ownership information in signatures. Its `read` is useful to compare
with the synthetic draft 0.1 `view` above, but it is not the same declared API:
the sketch names `replace` as an earlier invalidator, while the frozen store
example is immutable.

Historical fragment — selected lines from the design proposal's syntax sketch;
omits the enclosing sketch and other declarations. This is not draft 0.1 syntax
and is not a publishable package.

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

Compare `destroy(store: Store)` with `view(store: Store)`: the parameter type
stays the same, while `input` changes from `consume` to `borrow`. A reviewer
has to read the body to see that difference. The alternative illustrated by
the sketch makes transfer visible in the signature, while owner relationships
and invalidation still need expression somewhere.

The proposal explicitly left ownership placement for a corpus-backed decision.
**No rationale for choosing clauses is recorded.** The longer body and the
distance between type and transfer are observable costs; neither is evidence
of why the authors chose this design. [Q3](#q3) preserves that missing rationale.

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
places, references and lists. The rule files close and type the vocabulary.
In summary (non-normative), parseability establishes neither a recognized clause
nor a valid use of it ([`L1`](../language.md#l1), [`L5`](../language.md#l5)).

Clause-specific grammar productions are an alternative. The uniform form gives
core and profile clauses one outer syntax, but costs discoverability: reading
the grammar does not reveal required clauses, their scopes or companions.
For example, `extent` lives in [`C4`](../contracts.md#c4), while
`callback_abi` is defined in [`A2`](../profiles.md#a2). A reader assembles both
syntax and meaning across the rules; an indexed reference can help lookup
without eliminating this split in the language's definition.

## Exact environments

The synthetic buffer package claims target `fixture64`, platform `fixture`
version `1`; the object package adds `fixture-compiler` version `1`. A package
claiming those values has said nothing about platform version `2`. Compare that
with an open-ended claim such as “version 1 and later”, which would include
configurations the exact list has not named ([`L3`](../language.md#l3),
[environment examples](packages.md#where-it-holds)).

In summary (non-normative), draft 0.1 interprets environments as exact values,
not ranges. Unlisted configurations lie outside the claim. Changed signatures
or contracts require distinct declarations with disjoint availability or distinct
identities ([`L3`](../language.md#l3)).

Version-range algebra is the alternative. Exactness makes the claimed cases
explicit, but costs a potentially large matrix and repeated declarations when
contracts vary. These are consequences of the rule, not a recorded scaling
study. Provider interpretation still matters: an exact toolchain version alone
does not establish artifact compatibility ([`A1`](../profiles.md#a1),
[`A4`](../profiles.md#a4)).

## Profiles as the extension point

The core can state that independent calls are serial. The synthetic
`fixture::sendability(nonconforming)` separately records a source conformance
state. Combining those facts into one “thread-safe” flag would lose a
distinction the draft preserves ([`C2–C3`](../contracts.md#c2),
[`F1`](../profiles.md#f1)).

Similarly, `execution(sync)` has a core meaning, while `execution(async)` needs
a profile defining suspension, scheduling and completion delivery. The latter
is recognized vocabulary but exceeds the synthetic fixture's capabilities
([`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).

In summary (non-normative), profiles add versioned, typed semantics and specify
their validation and representation requirements. They cannot weaken the core.
Unknown normative attributes are errors, not ignorable extension payloads
([`L1`](../language.md#l1), [`A1`](../profiles.md#a1)).

The [proposal](../../../docs/design/2026-09-22-interface-language.md#2-recommended-shape-and-alternatives)
chooses this common-core boundary over making the whole language follow one
source ecosystem. An open annotation bag would be another extension mechanism,
with less vocabulary work but no shared interpretation for those annotations.
AIL's cost is substantial provider specification and uneven consumer support.
A consumer that cannot interpret a required dependency cannot claim complete
validation; a binding consumer may separately lack the ability to implement a
valid contract ([`A1`](../profiles.md#a1), [`A5`](../profiles.md#a5)).

## What draft 0.1 cannot express

A bounded synthetic example can be complete while a similarly shaped real API
needs further semantics. For example, the synthetic subscription's unique-owner
destructor establishes quiescence; an API whose cancellation merely requests
shutdown needs named events and ordering. The latter cannot be presented as
`quiescence(@cancel)` unless cancellation return really is that boundary
([`C6`](../contracts.md#c6)).

Likewise, the synthetic getter has a specified source-build path, while a generic
family needs parameter constraints, substitution and instantiation identity.
Naming a compiler does not provide those contracts. The
[pressure-case catalogue](../conformance.md#pressure-cases-outside-the-synthetic-profile)
identifies the following limits. It is an adoption checklist, not a claim that
every item lacks a core representation:

| Pressure case | What remains to be supplied |
|---|---|
| Generic families; async, throwing or value-receiver operations | Complete source types and constraints, suspension/delivery, exception lowering and receiver effects; additional profile support ([`L4`](../language.md#l4), [`C3`](../contracts.md#c3), [`A1`](../profiles.md#a1)) |
| Optional members; negotiated protocol operations | Receiver/session capability rules and runtime or wire mechanisms, separately from platform availability ([`C3`](../contracts.md#c3), [`A1–A2`](../profiles.md#a1)) |
| Native ABI access; managed projections | Representation, artifact or source recipe and faithful mapping; losing observable status creates a different declaration ([`A2–A4`](../profiles.md#a2)) |
| Variadics, inline calls and macros | Argument schema or source mechanism that distinguishes missing, expanded and erased code ([`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)) |
| Callback destroy notification or acknowledged cancellation | Events and quiescence ordering beyond unique-owner teardown ([`C6`](../contracts.md#c6)) |
| Packed records, unions, bitfields; richer pattern laws | Supported representation schemas and typed law forms; free-form prose cannot supply them ([`L4`](../language.md#l4), [`L6`](../language.md#l6), [`A3`](../profiles.md#a3)) |
| Error-out partitions, opaque-handle lifetimes, mutable-borrow invalidation and open or wide enum values | Authoritative API facts and a suitable real provider. Core rules already express important parts; omitting invalidators, guessing release or truncating values still breaks the contract ([`L4`](../language.md#l4), [`C2`](../contracts.md#c2), [`C5`](../contracts.md#c5)) |

The alternative is to accept approximations or silently lower unsupported forms
to familiar ones. Draft 0.1 instead requires the complete applicable semantics
or refusal. That preserves distinctions but costs usable coverage: the supplied
synthetic fixture cannot demonstrate production Swift, Rust, Zig, CLR, COM/WinRT
or Wayland binding ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).
Refusal for missing provider support and refusal because a chosen target cannot
preserve a valid contract are different results ([`A5`](../profiles.md#a5)).

## Open questions

These questions originate in the [audit's register](../../../docs/research/interface-language-documentation-audit.md#4-possible-language-issues-surfaced-for-review).
They remain open. Describing a rule accurately does not settle whether its
design or presentation should change.

### Q1

**Question:** Does the keyword convention stated in `language.md` cover the
other two rule files, and do the authors want uniform keyword presentation?
**Where:** the opening of [language rules](../language.md) and the mixture of
uppercase keywords and ordinary lowercase requirements in
[contracts](../contracts.md) and [profiles](../profiles.md); audit F10.
**Why it matters:** reviewers need consistent signals of normative force.
The audit found a presentation inconsistency, not a rule whose force was
uncertain because of case. Lowercase wording still states requirements in
ordinary English; the question does not demote those requirements.

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
**Where:** the [proposal's open syntax decision](../../../docs/design/2026-09-22-interface-language.md#7-dedicated-syntax-direction),
[`L4`](../language.md#l4), [`C3`](../contracts.md#c3) and [`C5`](../contracts.md#c5).
**Why it matters:** it is a prominent readability and authoring choice, but
no rationale is recorded. The comparison above does not fill that gap.

### Q4

**Question:** Is the double spelling for slots, with an overloaded `::`,
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

Next: inspect the [conformance examples](../conformance.md#positive-specifications)
with their expected interpretations. The tutorial *Describing a small API* and
the guide *Reviewing AIL* are forthcoming.
Return to [packages and access paths](packages.md) or [the overview](../README.md).
