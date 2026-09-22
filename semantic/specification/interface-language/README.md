# API Interface Language — draft 0.1

Status: first normative draft, 23 September 2026. The architecture is approved;
this detailed language is proposed for review. “API Interface Language” and the
`.ail` extension are working names. This is not APIAnyware's implemented format.

An AIL package is an authoritative description of a declared API surface. Humans,
analysers and third-party producers have identical publication obligations.
Incomplete analysis, competing claims, confidence scores and unresolved facts
belong outside the package. An intentionally opaque type is a complete contract
about an opaque type, not a placeholder for missing analysis.

The package describes API meaning, source identities and available access paths.
It names versioned ABI definitions supplied by tooling; it does not define an ABI.
Bindings, documentation and LLM representations consume the same contract.

Read these documents in order:

1. [Language and publication rules](language.md), with [EBNF](grammar.ebnf).
2. [Memory, effects and behavioural contracts](contracts.md).
3. [Profiles, access paths and ABI references](profiles.md).
4. [Mapping from the existing implementation](baseline.md).
5. [Conformance requirements and examples](conformance.md).

The first three documents and the grammar are normative **within this draft**.
The baseline, examples and conformance mutations explain and exercise those rules.
Examples describe synthetic APIs, not the contracts of real operating-system APIs.
No parser, native ABI provider, binding implementation or executable conformance
suite is delivered here. Static checks and review limits are recorded in
[conformance](conformance.md#verification-record).

## Scope

The core specifies named declarations, scalar and aggregate types, explicit
ownership and validity, outcomes, callback schedules, concurrency, properties,
relationships and reusable patterns. A small closed predicate language makes
outcome coverage checkable. Profiles add source-language and access semantics
through typed, versioned clauses. There are no uninterpreted normative attributes.

Draft 0.1 uses a finite set of exact deployment environments. It does not yet
define version-range algebra, arbitrary dependent types, generic constraint
solving, bitfield layout, unions, or complete Swift/Rust/Zig/CLR/Wayland profiles.
An API needing such a feature cannot be published under the core alone. It needs
a fully specified profile or a later language version; a producer cannot erase
the feature and call the result complete. Source-only access is legitimate when
it is itself completely specified and supported by an appropriate profile.

These limits concern which complete APIs this draft can express. They do not
introduce a partial-specification mode. A package may deliberately describe a
named subset of a larger API, provided that subset and its entire semantic
dependency closure are specified.

## Design basis

The [approved architecture](../../docs/design/2026-09-22-interface-language.md)
and [initial survey](../../docs/research/2026-09-22-interface-language-a.md)
explain the alternatives and external precedents. The
[work plan](../../docs/design/2026-09-22-interface-language-plan.md) tracks this
specification phase. Production libraries, parsers and APIAnyware adoption follow
in separate phases.
