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

[Package, environment and declaration clauses](clauses-package.md) covers
publication, exact configurations, common clauses, members and nominal contracts.
[Callable effects and input clauses](clauses-callable.md) covers effects, input
obligations, buffers and strings. [Outcome and callback schedule clauses](clauses-outcomes.md)
covers output states, ownership and registration schedules.
[Access, pattern and fixture clauses](clauses-access.md) covers provider paths,
role bindings, laws and synthetic source facts.
Their applicability and canonical rule destinations are available in the
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

Start here with the fact you need to record. Each entry links to its canonical
rule and to the explanation of the concept it expresses.

| Model concept | Entries and clause destinations |
|---|---|
| [Operations and their values](../explanation/model.md#operations) | [`unit`](types.md#unit), [`bool`](types.md#bool), [`i8`](types.md#integers), [`f32`](types.md#floats), [`ptr`](types.md#pointers), [`nullable`](types.md#nullable), [`array`](types.md#array), [`complex`](types.md#complex), [`record`](declarations.md#record), [`field`](declarations.md#field), [`alias`](declarations.md#alias), [`enum`](declarations.md#enum), [`flags`](declarations.md#flags), [`case`](declarations.md#case), [`fn`](declarations.md#fn), [`type`](types.md#named-types), [`reference`](notation.md#names), [`place`](notation.md#places), [`integer`](notation.md#grammar-source-and-dialect); clauses: [`values`](clauses-package.md#values), [`variadic`](clauses-callable.md#variadic) |
| [How a call finishes](../explanation/model.md#outcomes) | [`outcome`](declarations.md#outcome); clauses: [`completions`](clauses-callable.md#completions), [`meaning`](clauses-outcomes.md#meaning), [`state`](clauses-outcomes.md#state), [`when`](clauses-outcomes.md#when) |
| [Entities that outlive a call](../explanation/model.md#entities) | [`resource`](declarations.md#resource), [`object`](declarations.md#object), [`interface`](declarations.md#interface), [`property`](declarations.md#property), [`constant`](declarations.md#constant), [`global`](declarations.md#global), [`pattern`](declarations.md#pattern), [`role`](declarations.md#role), [`instance`](declarations.md#instance); clauses: [`accessors`](clauses-package.md#accessors), [`base`](clauses-package.md#base), [`bind`](clauses-access.md#bind), [`extends`](clauses-package.md#extends), [`extension`](clauses-package.md#extension), [`implements`](clauses-package.md#implements), [`law`](clauses-access.md#law), [`literal`](clauses-package.md#literal), [`member`](clauses-package.md#member), [`mutable`](clauses-package.md#mutable), [`overrides`](clauses-package.md#overrides), [`receiver`](clauses-package.md#receiver), [`requirement`](clauses-package.md#requirement), [`satisfies`](clauses-package.md#satisfies), [`storage`](clauses-package.md#storage), [`subject`](clauses-access.md#subject) |
| [Release responsibility](../explanation/model.md#responsibility) | [`give`](clauses-outcomes.md#give), [`input`](clauses-callable.md#input), [`lifecycle`](clauses-package.md#lifecycle), [`retain`](clauses-callable.md#retain) |
| [Validity](../explanation/model.md#validity) | [`invalidated_by`](clauses-outcomes.md#invalidated_by), [`mutation`](clauses-callable.md#mutation), [`valid`](clauses-callable.md#valid) |
| [Storage](../explanation/model.md#storage) | [`aliasing`](clauses-callable.md#aliasing), [`contents`](clauses-callable.md#contents), [`direction`](clauses-callable.md#direction), [`extent`](clauses-callable.md#extent) |
| [Where and when calls run](../explanation/model.md#execution) | [`concurrency`](clauses-callable.md#concurrency), [`execution`](clauses-callable.md#execution), [`executor`](clauses-callable.md#executor), [`fixture::actor`](clauses-access.md#fixture-actor), [`fixture::sendability`](clauses-access.md#fixture-sendability), [`isolation`](clauses-package.md#isolation), [`reentrancy`](clauses-callable.md#reentrancy), [`sharing`](clauses-package.md#sharing) |
| [Callbacks and their schedules](../explanation/model.md#callbacks) | [`callback`](declarations.md#callback), [`callback_use`](declarations.md#callback-use); clauses: [`count`](clauses-outcomes.md#count), [`quiescence`](clauses-outcomes.md#quiescence), [`requires`](clauses-callable.md#requires), [`scope`](clauses-outcomes.md#scope), [`timing`](clauses-outcomes.md#timing) |
| [The published description](../explanation/model.md#description) | [`package`](declarations.md#package), [`import`](declarations.md#import), [`environment`](declarations.md#environment), [`clause`](notation.md#clause), [`name`](notation.md#names); clauses: [`available`](clauses-package.md#available), [`deprecated`](clauses-package.md#deprecated), [`doc`](clauses-package.md#doc), [`exports`](clauses-package.md#exports), [`feature`](clauses-package.md#feature), [`link`](clauses-package.md#link), [`platform`](clauses-package.md#platform), [`runtime`](clauses-package.md#runtime), [`source`](clauses-package.md#source), [`surface`](clauses-package.md#surface), [`target`](clauses-package.md#target), [`toolchain`](clauses-package.md#toolchain) |
| [Reaching the code](../explanation/model.md#access) | [`access`](declarations.md#access), [`profile`](types.md#profile-types); clauses: [`abi`](clauses-access.md#abi), [`callback_abi`](clauses-access.md#callback_abi), [`compatibility`](clauses-access.md#compatibility), [`mapping`](clauses-access.md#mapping), [`representation`](clauses-access.md#representation), [`via`](clauses-access.md#via) |
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

The [conformance corpus](../conformance.md#rejection-mutations) gives the exact
mutation and starting example for each ID. These non-normative lookup summaries
link to the controlling rules and the relevant entry. N11 checks implementation
truth; N14's dynamic-size form creates runtime obligations.

| Mutation | Rule and reason | Entry |
|---|---|---|
| <a id="n01"></a>N01 | [L3](../language.md#l3)/[L4](../language.md#l4): unresolved type, no unknown contract type. | [named-types](types.md#named-types) |
| <a id="n02"></a>N02 | [C5](../contracts.md#c5): valid reference output lacks ownership. | [give](clauses-outcomes.md#give) |
| <a id="n03"></a>N03 | [L2](../language.md#l2): duplicate parameter name. | [fn](declarations.md#fn) |
| <a id="n04"></a>N04 | [L2](../language.md#l2)/[L4](../language.md#l4): reserved core type name. | [names](notation.md#names) |
| <a id="n05"></a>N05 | [C5](../contracts.md#c5): uncovered nullable discriminator. | [when](clauses-outcomes.md#when) |
| <a id="n06"></a>N06 | [C5](../contracts.md#c5): overlap and missing null case. | [when](clauses-outcomes.md#when) |
| <a id="n07"></a>N07 | [C1](../contracts.md#c1)/[C5](../contracts.md#c5): escaped borrow expires at delivery. | [give](clauses-outcomes.md#give) |
| <a id="n08"></a>N08 | [C1](../contracts.md#c1)/[L2](../language.md#l2): unresolved place. | [places](notation.md#places) |
| <a id="n09"></a>N09 | [C2](../contracts.md#c2): no release protocol for owned handles. | [lifecycle](clauses-package.md#lifecycle) |
| <a id="n10"></a>N10 | [C2](../contracts.md#c2): destructor signature/consumption mismatch. | [lifecycle](clauses-package.md#lifecycle) |
| <a id="n11"></a>N11 | Authoring/implementation contract contradiction; prose cannot negate `state(valid)`. A syntax validator alone cannot detect a lying implementation; an implementation conformance test must. | [state](clauses-outcomes.md#state) |
| <a id="n12"></a>N12 | [C5](../contracts.md#c5): invalid, non-scalar discriminator; also does not share the successful outcome's discriminator. | [when](clauses-outcomes.md#when) |
| <a id="n13"></a>N13 | [C4](../contracts.md#c4): output requires writable pointer. | [direction](clauses-callable.md#direction) |
| <a id="n14"></a>N14 | [C4](../contracts.md#c4): extent inequality. | [extent](clauses-callable.md#extent) |
| <a id="n15"></a>N15 | [C6](../contracts.md#c6): impossible schedule/scope. | [scope](clauses-outcomes.md#scope) |
| <a id="n16"></a>N16 | [C6](../contracts.md#c6): no complete teardown guarantee. | [quiescence](clauses-outcomes.md#quiescence) |
| <a id="n17"></a>N17 | [C6](../contracts.md#c6): impossible bounds. | [count](clauses-outcomes.md#count) |
| <a id="n18"></a>N18 | [C6](../contracts.md#c6): blocking quiescence lacks deadlock exclusion or supported reentrant protocol. | [requires](clauses-callable.md#requires) |
| <a id="n19"></a>N19 | [C2](../contracts.md#c2): missing confinement executor. | [sharing](clauses-package.md#sharing) |
| <a id="n20"></a>N20 | [L5](../language.md#l5): duplicate keyed clause; separate slots are allowed. | [input](clauses-callable.md#input) |
| <a id="n21"></a>N21 | [L6](../language.md#l6): wrong participant kind. | [bind](clauses-access.md#bind) |
| <a id="n22"></a>N22 | [L6](../language.md#l6): incomplete binding, including optional/many roles. | [bind](clauses-access.md#bind) |
| <a id="n23"></a>N23 | [L2](../language.md#l2)/[A2](../profiles.md#a2): unresolved ABI alias. | [abi](clauses-access.md#abi) |
| <a id="n24"></a>N24 | [L3](../language.md#l3)/[A2](../profiles.md#a2): unresolved configuration. | [access](declarations.md#access) |
| <a id="n25"></a>N25 | [A2](../profiles.md#a2): declaration availability has no callable path. | [access](declarations.md#access) |
| <a id="n26"></a>N26 | [A4](../profiles.md#a4): compiler name is not resolved build identity. | [compatibility](clauses-access.md#compatibility) |
| <a id="n27"></a>N27 | [L1](../language.md#l1)/[A1](../profiles.md#a1): unknown normative vocabulary. | [clause](notation.md#clause) |
| <a id="n28"></a>N28 | [L2](../language.md#l2): conflicting identity in resolution closure. | [import](declarations.md#import) |
| <a id="n29"></a>N29 | [L2](../language.md#l2): conflicting provider identity. | [use](declarations.md#use) |
| <a id="n30"></a>N30 | [C3](../contracts.md#c3)/[F1](../profiles.md#f1): unsupported required semantics; not an unknown fact. | [execution](clauses-callable.md#execution) |
| <a id="n31"></a>N31 | [C1](../contracts.md#c1)/[C5](../contracts.md#c5): aggregate shape does not satisfy recursive ownership. | [give](clauses-outcomes.md#give) |
| <a id="n32"></a>N32 | [C1](../contracts.md#c1): writable pointee borrows must also survive delivery. | [give](clauses-outcomes.md#give) |
| <a id="n33"></a>N33 | [L2](../language.md#l2): outcome identity collision. | [outcome](declarations.md#outcome) |

N11 is an authoring/implementation contradiction, not a parser rejection.
[C5](../contracts.md#c5) defines valid output and [C8](../contracts.md#c8) limits
what local checking can establish. N14 is statically rejected when contradictory
constants make the extent unsatisfiable; dynamic bounds remain caller/callee
obligations under [C4](../contracts.md#c4).

<a id="alphabetical-clauses"></a>

## Clause lookup

Each clause name links to its entry. Use the
[applicability table](declarations.md#applicability) to start from its enclosing
declaration or block. Shared spellings have one entry covering their scopes;
value constructors are described with their owning clause.

| Clause | Entry group |
|---|---|
| [`abi`](clauses-access.md#abi) | Access, patterns and fixture |
| [`accessors`](clauses-package.md#accessors) | Package, environment and declaration |
| [`aliasing`](clauses-callable.md#aliasing) | Callable effects and inputs |
| [`available`](clauses-package.md#available) | Package, environment and declaration |
| [`base`](clauses-package.md#base) | Package, environment and declaration |
| [`bind`](clauses-access.md#bind) | Access, patterns and fixture |
| [`callback_abi`](clauses-access.md#callback_abi) | Access, patterns and fixture |
| [`compatibility`](clauses-access.md#compatibility) | Access, patterns and fixture |
| [`completions`](clauses-callable.md#completions) | Callable effects and inputs |
| [`concurrency`](clauses-callable.md#concurrency) | Callable effects and inputs |
| [`contents`](clauses-callable.md#contents) | Callable effects and inputs |
| [`count`](clauses-outcomes.md#count) | Outcomes and callback schedules |
| [`deprecated`](clauses-package.md#deprecated) | Package, environment and declaration |
| [`direction`](clauses-callable.md#direction) | Callable effects and inputs |
| [`doc`](clauses-package.md#doc) | Package, environment and declaration |
| [`execution`](clauses-callable.md#execution) | Callable effects and inputs |
| [`executor`](clauses-callable.md#executor) | Callable effects and inputs |
| [`exports`](clauses-package.md#exports) | Package, environment and declaration |
| [`extends`](clauses-package.md#extends) | Package, environment and declaration |
| [`extension`](clauses-package.md#extension) | Package, environment and declaration |
| [`extent`](clauses-callable.md#extent) | Callable effects and inputs |
| [`feature`](clauses-package.md#feature) | Package, environment and declaration |
| [`fixture::actor`](clauses-access.md#fixture-actor) | Access, patterns and fixture |
| [`fixture::sendability`](clauses-access.md#fixture-sendability) | Access, patterns and fixture |
| [`give`](clauses-outcomes.md#give) | Outcomes and callback schedules |
| [`implements`](clauses-package.md#implements) | Package, environment and declaration |
| [`input`](clauses-callable.md#input) | Callable effects and inputs |
| [`invalidated_by`](clauses-outcomes.md#invalidated_by) | Outcomes and callback schedules |
| [`isolation`](clauses-package.md#isolation) | Package, environment and declaration |
| [`law`](clauses-access.md#law) | Access, patterns and fixture |
| [`lifecycle`](clauses-package.md#lifecycle) | Package, environment and declaration |
| [`link`](clauses-package.md#link) | Package, environment and declaration |
| [`literal`](clauses-package.md#literal) | Package, environment and declaration |
| [`mapping`](clauses-access.md#mapping) | Access, patterns and fixture |
| [`meaning`](clauses-outcomes.md#meaning) | Outcomes and callback schedules |
| [`member`](clauses-package.md#member) | Package, environment and declaration |
| [`mutable`](clauses-package.md#mutable) | Package, environment and declaration |
| [`mutation`](clauses-callable.md#mutation) | Callable effects and inputs |
| [`overrides`](clauses-package.md#overrides) | Package, environment and declaration |
| [`platform`](clauses-package.md#platform) | Package, environment and declaration |
| [`quiescence`](clauses-outcomes.md#quiescence) | Outcomes and callback schedules |
| [`receiver`](clauses-package.md#receiver) | Package, environment and declaration |
| [`reentrancy`](clauses-callable.md#reentrancy) | Callable effects and inputs |
| [`representation`](clauses-access.md#representation) | Access, patterns and fixture |
| [`requirement`](clauses-package.md#requirement) | Package, environment and declaration |
| [`requires`](clauses-callable.md#requires) | Callable effects and inputs |
| [`retain`](clauses-callable.md#retain) | Callable effects and inputs |
| [`runtime`](clauses-package.md#runtime) | Package, environment and declaration |
| [`satisfies`](clauses-package.md#satisfies) | Package, environment and declaration |
| [`scope`](clauses-outcomes.md#scope) | Outcomes and callback schedules |
| [`sharing`](clauses-package.md#sharing) | Package, environment and declaration |
| [`source`](clauses-package.md#source) | Package, environment and declaration |
| [`state`](clauses-outcomes.md#state) | Outcomes and callback schedules |
| [`storage`](clauses-package.md#storage) | Package, environment and declaration |
| [`subject`](clauses-access.md#subject) | Access, patterns and fixture |
| [`surface`](clauses-package.md#surface) | Package, environment and declaration |
| [`target`](clauses-package.md#target) | Package, environment and declaration |
| [`timing`](clauses-outcomes.md#timing) | Outcomes and callback schedules |
| [`toolchain`](clauses-package.md#toolchain) | Package, environment and declaration |
| [`valid`](clauses-callable.md#valid) | Callable effects and inputs |
| [`values`](clauses-package.md#values) | Package, environment and declaration |
| [`variadic`](clauses-callable.md#variadic) | Callable effects and inputs |
| [`via`](clauses-access.md#via) | Access, patterns and fixture |
| [`when`](clauses-outcomes.md#when) | Outcomes and callback schedules |

For a guided introduction, follow [the tutorial](../tutorial/README.md).
For reasons and alternatives, use [design choices](../explanation/choices.md).
