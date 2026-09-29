# Reference

> **Purpose:** reference — find exact AIL forms, applicability and canonical rules.
> **Reader:** reviewers, API authors and tool implementers looking up a specific fact.
> **Before this:** [A model of API behaviour and binding obligations](../explanation/model.md) for the concepts; [grammar and notation](notation.md) for syntax.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [language](../language.md), [contracts](../contracts.md), [profiles](../profiles.md) and [grammar](../grammar.ebnf) are canonical. Reference entries are non-normative summaries.

## Find a form

Use [Types](types.md) for type expressions and their contract consequences.
Use [Declarations and blocks](declarations.md) for enclosing forms and the
[clause applicability table](declarations.md#applicability). Each entry connects
the form to the model, gives its operands and constraints, and links the rules
that determine its validity. [Entry conventions](notation.md#entry-conventions)
explain how to read the fields.

[Grammar and notation](notation.md) keeps the exact grammar beside its eleven
railroad views. It includes [local and imported references](notation.md#names),
[callable slots](notation.md#callable) and [places](notation.md#places).

The clause entries are forthcoming in `clauses-package.md` (package,
environment, common and nominal clauses), `clauses-callable.md` (effects,
inputs and storage), `clauses-outcomes.md` (outcomes and callback schedules),
and `clauses-access.md` (access, pattern bindings/laws and fixture clauses).
Their applicability and canonical rule destinations are available now in the
[table](declarations.md#applicability).

## Canonical sources

| Source | Determines |
|---|---|
| [Language rules](../language.md) | Text, identity, publication, types, declarations and patterns |
| [Contract rules](../contracts.md) | Values, memory, effects, outcomes and callback schedules |
| [Profile and access rules](../profiles.md) | Providers, access paths, representations, agreement and the synthetic fixture catalogue |
| [Grammar](../grammar.ebnf) | Syntactic forms; clause vocabulary and validity come from the rule prose |

The [conformance corpus](../conformance.md) supplies examples and rejection
mutations. The [existing-model inventory](../baseline.md) records a bounded
comparison with APIAnyware's earlier data model. Both support review; the
rules above determine the language contract. See [normative wording](notation.md#normative-wording)
for the distinction between rule text and explanatory summaries.

<a id="model-concepts"></a>

## Model-concept index

Start here with the fact you need to record. Forthcoming clause entries are
named as plain text; the applicability table links their rules.

| Model concept | Available entries and forthcoming clauses |
|---|---|
| [Operations and their values](../explanation/model.md#operations) | [`unit`](types.md#unit), [`bool`](types.md#bool), [`i8`](types.md#integers), [`f32`](types.md#floats), [`ptr`](types.md#pointers), [`nullable`](types.md#nullable), [`array`](types.md#array), [`complex`](types.md#complex), [`record`](declarations.md#record), [`field`](declarations.md#field), [`alias`](declarations.md#alias), [`enum`](declarations.md#enum), [`flags`](declarations.md#flags), [`case`](declarations.md#case), [`fn`](declarations.md#fn), [`type`](types.md#named-types), [`reference`](notation.md#names), [`place`](notation.md#places), [`integer`](notation.md#grammar-source-and-dialect); forthcoming: `values`, `variadic` |
| [How a call finishes](../explanation/model.md#outcomes) | [`outcome`](declarations.md#outcome); forthcoming: `completions`, `meaning`, `state`, `when` |
| [Entities that outlive a call](../explanation/model.md#entities) | [`resource`](declarations.md#resource), [`object`](declarations.md#object), [`interface`](declarations.md#interface), [`property`](declarations.md#property), [`constant`](declarations.md#constant), [`global`](declarations.md#global), [`pattern`](declarations.md#pattern), [`role`](declarations.md#role), [`instance`](declarations.md#instance); forthcoming: `accessors`, `base`, `bind`, `extends`, `extension`, `implements`, `law`, `literal`, `member`, `mutable`, `overrides`, `receiver`, `requirement`, `satisfies`, `storage`, `subject` |
| [Release responsibility](../explanation/model.md#responsibility) | forthcoming: `give`, `input`, `lifecycle`, `retain` |
| [Validity](../explanation/model.md#validity) | forthcoming: `invalidated_by`, `mutation`, `valid` |
| [Storage](../explanation/model.md#storage) | forthcoming: `aliasing`, `contents`, `direction`, `extent` |
| [Where and when calls run](../explanation/model.md#execution) | forthcoming: `concurrency`, `execution`, `executor`, `fixture::actor`, `fixture::sendability`, `isolation`, `reentrancy`, `sharing` |
| [Callbacks and their schedules](../explanation/model.md#callbacks) | [`callback`](declarations.md#callback), [`callback_use`](declarations.md#callback-use); forthcoming: `count`, `quiescence`, `requires`, `scope`, `timing` |
| [The published description](../explanation/model.md#description) | [`package`](declarations.md#package), [`import`](declarations.md#import), [`environment`](declarations.md#environment), [`clause`](notation.md#clause), [`name`](notation.md#names); forthcoming: `available`, `deprecated`, `doc`, `exports`, `feature`, `link`, `platform`, `runtime`, `source`, `surface`, `target`, `toolchain` |
| [Reaching the code](../explanation/model.md#access) | [`access`](declarations.md#access), [`profile`](types.md#profile-types); forthcoming: `abi`, `callback_abi`, `compatibility`, `mapping`, `representation`, `via` |
| [Writers, checkers and users](../explanation/model.md#agreement) | [`use`](declarations.md#use) |

<a id="rules"></a>

## Rule-identifier index

| Rule | Subject |
|---|---|
| [L1](../language.md#l1) | Text and syntax |
| [L2](../language.md#l2) | Identity and dependencies |
| [L3](../language.md#l3) | Publication and environments |
| [L4](../language.md#l4) | Type expressions |
| [L5](../language.md#l5) | Declarations and common clauses |
| [L6](../language.md#l6) | Patterns |
| [C1](../contracts.md#c1) | Slots and regions |
| [C2](../contracts.md#c2) | Nominal lifetime and concurrency |
| [C3](../contracts.md#c3) | Callable effects and input obligations |
| [C4](../contracts.md#c4) | Buffers and strings |
| [C5](../contracts.md#c5) | Outcomes and returned obligations |
| [C6](../contracts.md#c6) | Callback schedules and teardown |
| [C7](../contracts.md#c7) | Global storage |
| [C8](../contracts.md#c8) | Obligation checking |
| [A1](../profiles.md#a1) | Provider manifests |
| [A2](../profiles.md#a2) | Access paths |
| [A3](../profiles.md#a3) | Type representations and data access |
| [A4](../profiles.md#a4) | Representation and compatibility |
| [A5](../profiles.md#a5) | Consumer agreement |
| [F1](../profiles.md#f1) | Synthetic fixture catalogue |

<a id="mutations"></a>

## Mutation lookup

[N01–N33](../conformance.md#rejection-mutations) currently carry their source
example, individual mutation and expected rule directly in the conformance
corpus. The reference's mutation-to-rule index will appear with the remaining
clause entries. N11 checks truth against an implementation, which a syntax
validator alone cannot establish; N14's dynamic-size form creates a runtime
obligation ([conformance qualifications](../conformance.md#rejection-mutations)).

<a id="alphabetical-clauses"></a>

## Clause lookup

Use the [applicability table](declarations.md#applicability) to find a clause's
scope and canonical rule now. The alphabetical clause index will accompany the
completed clause entries.

For a guided introduction, follow [the tutorial](../tutorial/README.md).
For reasons and alternatives, use [design choices](../explanation/choices.md).
