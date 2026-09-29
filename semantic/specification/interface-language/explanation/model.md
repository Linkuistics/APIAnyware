# A model of API behaviour and binding obligations

> **Purpose:** explanation — connect the facts an API description records before learning how AIL writes them.
> **Reader:** language designers new to API binding, including readers arriving at a single concept.
> **Before this:** [Using an API across languages](unsaid.md) introduces the watch API and its possible contracts.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [language](../language.md), [contracts](../contracts.md) and [profiles](../profiles.md) are canonical; each concept below cites its rules.

## What the model is for

A program using a library needs to know what it can call, what each call
requires and what the library promises in return. An
[API binding](../glossary.md#binding) carries those agreements into another
language. A tool generating that binding needs the agreements in a form it
can inspect. This model gathers the relevant entities and relationships into
one account; AIL is a proposed notation for recording them.

Recall the invented watch API. A program supplies a notification function and
some context when it calls `watch_open`. A successful open gives it a watch
[handle](../glossary.md#handle). It can pass that handle to `watch_view` to
obtain bytes and their length, and to `watch_close` to end the watch. The domain page considers
different possible promises about these operations. Those alternatives remain
separate here: the header is an illustration, not a complete implemented API
or one of the synthetic AIL fixture packages.

The **call layer** describes what happens when the program uses the API:
values pass between [caller and callee](../glossary.md#caller-and-callee), some
entities remain alive afterwards, and each party has duties concerning those
values. The **description layer**
states which API those facts cover, how a tool reaches its implementation and
what writers, checkers and users of the description agree on.

This page explains what the draft's rules describe. It is non-normative;
the linked rules determine exact requirements. The
[design discussion](choices.md) records choices, limits and open questions
for review.

## The model at a glance

<!-- G11 slot: API-model overview. The orientation node brief holds the art handoff. -->

Start with an **operation**, such as `watch_view`. Its parameters identify
values the caller supplies; its result and writable output storage identify
what the caller can receive. Each [outcome](../glossary.md#outcome) connects an
observable finish to its meaning and the outputs the caller can read.

Some of those values identify **entities that outlive a call**. The watch
handle identifies a live watch. Its release rules say how that lifetime ends;
each call's contract says who holds the **release responsibility**. In a
contract that lends watch-owned bytes, the view's **validity** depends on the
watch remaining alive and on any earlier operation that invalidates the view.
The **storage** contract separately describes the bytes' bounds and contents.

Calls also have rules for **where and when they run**. These govern where a
call can start and whether calls can overlap or nest. When `watch_open`
registers `notice`, a [callback](../glossary.md#callback) schedule relates
possible invocations to that registration. It bounds use of the saved context and identifies when
callback activity has ended.

The **published description** gathers these [declarations](../glossary.md#declaration)
and contracts for a stated part and release of the API, with its dependencies
and supported configurations. [Access paths](../glossary.md#access-path)
connect the described operations to code, using selected definitions of
machine representations and calling rules.
Finally, **writers, checkers and users** carry the same facts from the API
author's account through [validation](../glossary.md#validation) to bindings
and documentation. Checking the description and establishing the implementation's behaviour are separate
pieces of that work.

<a id="operations"></a>

## Operations and their values

An operation gives the caller something it can ask the API to do. Its
signature names the inputs and the result, and gives each a type. In the
[watch header](unsaid.md#a-small-api), `watch_view` accepts a watch handle and
the address of a length variable. It returns a pointer to bytes. The length
variable is another output, written through the address supplied by the caller.

A contract attaches each fact to the value or storage it concerns. The caller
keeps the length variable's address usable during the call. The library's
contract separately says whether it writes a readable count there. A larger
value may contain fields that carry their own obligations. Naming the precise part lets a checker associate a
fact with the right type and lets a binding arrange the right action.

The model accommodates scalar values, structured values and references to
other values or entities. A returned record can carry data directly; a
returned pointer instead leads to storage whose bounds and lifetime need
answers. A callback invocation has its own inputs and outputs, with the
library acting as caller. These distinctions establish what the later
contracts talk about (non-normative; [`L4`](../language.md#l4),
[`L5`](../language.md#l5), [`C1`](../contracts.md#c1)).

Notation and practice: [From signature to contract](contracts.md#from-signature-to-contract) · [tutorial 1](../tutorial/01-lifetime.md).

<a id="outcomes"></a>

## How a call finishes

A call's [outcomes](../glossary.md#outcome) describe the cases the caller can
distinguish when it finishes. Each case connects an observation to its meaning
and to the [state of the outputs](../glossary.md#output-state). If `watch_view`
returns null on failure, that null result identifies the failure case. The contract also says whether
the library has written a readable count into the length variable.

Compare a failure that writes zero there with one that leaves it
uninitialized. The same returned null calls for different handling of the
length output. The [failure example](unsaid.md#what-can-the-caller-read-when-a-call-fails)
shows why reading that output without its contract is unsafe. Knowing the
outcome lets a binding expose the actual failure signal and read only the
outputs promised for that case.

APIs can distinguish cases by a null result, an integer status or another
supported observation. A null result can also mean a successful absence of
data. Returning and throwing are different ways to finish, each with its own
outcomes. The draft requires the cases for each declared way of finishing to
cover every possibility exactly once. That completeness concerns observable
finishes; it supplies no guarantee that the call eventually finishes
(non-normative; [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

Notation and practice: [Every way a call can end](contracts.md#every-way-a-call-can-end) · [tutorial 3](../tutorial/03-storage.md).

<a id="entities"></a>

## Entities that outlive a call

A [handle](../glossary.md#handle) lets several calls refer to the same entity.
After a successful `watch_open`, the program can use the returned handle in
later calls on that watch. The watch's identity and lifetime connect those
calls. Its [lifecycle](../glossary.md#lifecycle) describes how it is kept alive
and released, even though its internal layout remains hidden.

A unique watch has one destruction obligation per owned handle. An API using
reference counting instead lets parties hold separate owned references to
one entity; releasing the final reference ends its lifetime. Knowing which
arrangement applies lets a binding choose when and how to release what it
holds. The [release example](unsaid.md#who-is-responsible-for-releasing-a-value)
shows the leaks and double destruction that a mistaken choice can cause.

The description also records relationships between entities and operations.
An operation can be associated with a type as a [member](../glossary.md#member),
and a property can connect a readable or writable value to its accessor operations. Shared
storage and constant values have their own descriptions. Where a reusable
relationship imposes an ordering or release obligation, the model records its
participants and that obligation explicitly. It distinguishes a required
call sequence from a sequence that is merely convenient (non-normative;
[`L4–L6`](../language.md#l4), [`C2`](../contracts.md#c2),
[`C7`](../contracts.md#c7)).

Notation and practice: [Lifecycles and patterns](contracts.md#lifecycles-and-patterns) · [tutorial 1](../tutorial/01-lifetime.md).

<a id="responsibility"></a>

## Release responsibility

For a value referring to a live entity, the caller needs to know who owes its
release. In the owned-watch case, successful `watch_open` gives that duty to
the caller. A `watch_view` that uses the watch for the call leaves the duty
with the caller. A [consuming](../glossary.md#consume) `watch_close` takes it
over at entry and destroys the watch. These are the three separate cases in the
[ownership example](unsaid.md#who-is-responsible-for-releasing-a-value).

An [owned](../glossary.md#owned) reference carries one release obligation.
A [borrow](../glossary.md#borrow) permits use while leaving that obligation
with its existing holder. This describes the agreement between parties;
exclusivity and static enforcement need their own justification. In
particular, several parties can each owe a release of their reference to a
reference-counted entity.

The model separates transfer from [retention](../glossary.md#retention).
A consuming call takes the caller's obligation. A callee that strongly retains
an input acquires another obligation. A callee that stores an unretained
reference relies on the caller to keep the referent alive for the stated
period. These facts let a binding arrange cleanup without mistaking an
address copy for a new owned reference.

Input [ownership transfer](../glossary.md#ownership-transfer) happens at entry,
including when the operation later fails. Returned obligations depend on the
outcome: a non-null owned result gives the caller one release obligation;
null gives none. The callee discharges a consumed
obligation unless it explicitly returns that obligation as an owned output
(non-normative; [`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3),
[`C5`](../contracts.md#c5)).

Notation and practice: [Who owns what](contracts.md#who-owns-what) · [tutorial 1](../tutorial/01-lifetime.md).

<a id="validity"></a>

## Validity

[Borrow validity](../glossary.md#borrow-validity) tells the recipient how long
borrowed access remains usable. If `watch_view` lends the watch's bytes, the
watch can supply the lifetime that bounds the view. A binding can then keep
access to a live watch for as long as it allows the program to read the view.

An operation can end that access earlier. In the domain page's
[refresh case](unsaid.md#how-long-can-the-caller-use-a-view), a later
`watch_view` replaces the bytes while the watch stays alive. The earlier view
becomes invalid when that refreshing operation begins. Under the alternative
contract with no earlier invalidator, the view remains usable until the watch
is destroyed. The caller needs both the lifetime bound and the earlier events
to know when to stop reading.

Different uses need different bounds. An input used only during an invocation
can be valid for that call. A view delivered to the caller needs a lifetime
that survives delivery, such as its owner's lifetime or the loaded API
instance's lifetime. The loaded API instance can end before the process exits.
These bounds describe permitted use of the referent; the pointer's bits can
remain unchanged after use becomes invalid (non-normative;
[`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3),
[`C5`](../contracts.md#c5)).

Notation and practice: [How long a borrow lasts](contracts.md#how-long-a-borrow-lasts) · [tutorial 2](../tutorial/02-lending.md).

<a id="storage"></a>

## Storage

A pointer gives access to storage. Its contract describes how much room
exists, which elements are initialized, what those elements mean and who
may read or write them. For `watch_view`, the returned pointer and length
together identify the readable bytes. The length variable itself is separate
storage that the caller provides for the library to write.

The [buffer example](unsaid.md#how-many-bytes-exist-and-what-do-they-contain)
compares binary data with zero-terminated text. Three binary bytes fit in
three bytes of storage. Three text code units with a final zero need room
for that extra code unit. [Buffer extent](../glossary.md#buffer-extent) records
the initialized payload length and allocated capacity.
[Contents](../glossary.md#contents) supply the interpretation and any
termination convention. Together they let a binding choose a bounded read
and the appropriate text conversion.

The description can concern one element or a buffer, and can permit reading,
writing or both. It also states whether pointer storage can overlap other
memory accessed by the call. That permission still leaves callers responsible
for observing the concurrency rules. A buffer whose bound is discovered only
by scanning for a terminator needs an extension defining that contract;
the core describes explicit bounds (non-normative;
[`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4)).

Notation and practice: [Buffers and strings](contracts.md#buffers-and-strings) · [tutorial 3](../tutorial/03-storage.md).

<a id="execution"></a>

## Where and when calls run

An operation's execution rules let the caller arrange a permitted call.
One watch API might allow entry from any thread while requiring callers to
serialize access. Another might require the main thread. The
[threading example](unsaid.md#which-calls-may-run-together-and-where)
explains why a lock alone does not meet the second requirement.

The entry [executor](../glossary.md#executor) identifies where the call may
start. [Concurrency](../glossary.md#concurrency) governs independent overlap.
[Re-entrancy](../glossary.md#re-entrancy) governs a nested call on the same
entity before an earlier call finishes. If an active watch operation invokes
`notice`, and `notice` calls `watch_view` on that watch, the second call needs
permission for that nested entry. These separate facts let a binding arrange
scheduling without introducing a forbidden overlap or a teardown deadlock.

Types also constrain where references may travel and be used. Some permit
references to cross executors, while others confine use to a named executor,
including release. Permission to move a reference supplies no permission for
concurrent mutation. Finally, the call may complete before control returns,
or use an extension that defines suspension and completion delivery. A
description needs each of these facts to connect the entity's restrictions
with the operation's behaviour (non-normative;
[`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3)).

Notation and practice: [Threads and sharing](contracts.md#threads-and-sharing) · [tutorial 4](../tutorial/04-callbacks.md).

<a id="callbacks"></a>

## Callbacks and their schedules

A [callback](../glossary.md#callback) is a function value supplied for the
API to invoke. In the watch example, the program supplies `notice` and a
`context` pointer when opening a watch. One notification invocation receives
that context and an event number. Its own call contract describes those
values. The registration's schedule describes when such invocations may occur.

Compare a registration that finishes all invocations before returning with
one that stores the callback for later notifications. The first lets the
caller use temporary context storage. For the second, the caller keeps the
saved state alive after `watch_open` returns.
The [callback teardown example](unsaid.md#when-is-it-safe-to-discard-callback-state)
shows why releasing that state too early leaves an invocation using a dangling
pointer.

The schedule records permitted start times and counts, the execution rules
for invocations and the event that establishes
[quiescence](../glossary.md#quiescence): no invocation remains running or can
start. In the core, use ends within the registration call or through destruction
of a returned unique owner. When the watch is that owner, its destructor
establishes quiescence before returning. The caller can then release state
kept alive for those invocations. The caller invokes a blocking destructor
from outside those callbacks unless an extension defines a protocol that
avoids deadlock.

A schedule might require one invocation or allow any number, including zero.
Those counts apply if the registration's scope eventually ends: at return
from the registration call or at destruction of its returned owner. The counts
promise no deadline or eventual end. Cancellation with a later acknowledgement
needs an extension that identifies the events and their ordering. This lets a binding distinguish
a stop request from the point where callback state is safe to release
(non-normative; [`C2`](../contracts.md#c2), [`C6`](../contracts.md#c6)).

Notation and practice: [Callbacks](contracts.md#callbacks) · [tutorial 4](../tutorial/04-callbacks.md).

<a id="description"></a>

## The published description

A [package](../glossary.md#package) gathers the API account under a name and
version. It states the subset and release it describes, called its
[surface](../glossary.md#surface). A description of the watch operations
could leave unrelated image operations outside that surface. It still needs
the watch and notification types and everything their contracts refer to,
as the [shared-description example](unsaid.md#a-shared-description-for-api-tools)
explains.

Each declaration has an identity within the named, versioned package.
References connect it to local declarations or to declarations in explicitly
selected packages. The package also selects shared
[profile](../glossary.md#profile) and [ABI](../glossary.md#abi) definitions.
Selecting exact dependency contents lets tools agree on the same definitions even when
several releases exist. Following all those dependencies yields the
[dependency closure](../glossary.md#dependency-closure) needed to interpret
the chosen surface.

The description also states the exact configurations in which its claims
hold. Each declaration's [availability](../glossary.md#availability) says
where it is offered within that set. A configuration outside the set remains
outside the claims. A changed signature or contract needs a distinct
declaration, with disjoint availability or a distinct identity. Advisory
deprecation can guide a caller's choice while availability determines where
the declaration is offered.

This scope lets a checker distinguish a deliberately small description from
one missing required facts. A [producer](../glossary.md#producer) settles those
facts before publication; uncertainty in the producer's investigation remains work to resolve
(non-normative; [`L1–L3`](../language.md#l1), [`L5`](../language.md#l5)).

Notation and practice: [What a package claims](packages.md#what-a-package-claims) · [tutorial 1](../tutorial/01-lifetime.md).

<a id="access"></a>

## Reaching the code

An [access path](../glossary.md#access-path) connects an operation or data
declaration to its implementation. To call `watch_view`, a binding might use
a named linker symbol. Another API might require a runtime message or a call
built by a source compiler. The domain page's
[access explanation](unsaid.md#reaching-the-code) shows why knowing the source
name leaves this question open.

The path also selects an [ABI](../glossary.md#abi): the machine-level rules
for passing values, representing them and using runtime facilities. A
[mapping](../glossary.md#mapping) accounts for how the declaration reaches
that boundary. For the watch header, it would need to account for both
`notice` and its context argument. This header has no complete mapping here;
the synthetic callback fixture describes a different representation.

A path's [compatibility domain](../glossary.md#compatibility-domain) states when
the selected [representations](../glossary.md#representation) can be used
together. One [provider](../glossary.md#provider) might guarantee compatibility
across a stated binary domain. Another path might be tied to particular built artifacts
or to a fully specified source-build recipe. A caller needs that agreement
for value layout as well as argument passing.

Several paths can implement one operation's entire contract. A
[consumer](../glossary.md#consumer) then selects a supported path explicitly.
If an adaptation discards an observable
status distinction, it needs its own operation description. These facts let
a generator decide how to reach the code while preserving what callers can
observe (non-normative; [`A1–A4`](../profiles.md#a1),
[`F1`](../profiles.md#f1)).

Notation and practice: [Reaching the code](packages.md#reaching-the-code) · [tutorial 5](../tutorial/05-access-and-change.md).

<a id="agreement"></a>

## Writers, checkers and users

The [publication workflow](../README.md#who-writes-and-uses-an-ail-description)
connects people and tools through the description. A
[producer](../glossary.md#producer) writes it: an API author could supply
knowledge of the implementation, or an analysis tool could assemble evidence
for review. Both supply the same required facts. A proposed validator checks
that those facts are complete and consistent under the selected rules.

For example, a checker can establish that a returned view names a suitable
owner and gives the required lifetime facts. Establishing that the library
actually preserves the bytes for that lifetime requires evidence from its
author, review and implementation testing. The
[shared-description example](unsaid.md#a-shared-description-for-api-tools)
keeps those responsibilities visible.

[Consumers](../glossary.md#consumer) use the checked account. A documentation
renderer explains the view's lifetime; a binding generator arranges access;
an LLM tool can expose the same facts for programming assistance. Their
presentations retain access to the same contracts. When a generator cannot
preserve a valid contract, it reports that limitation as a constraint of its
own output.

Extensions also participate in this agreement. A
[profile](../glossary.md#profile) defines additional meanings and checking
rules while preserving the core requirements. A full checker needs to
understand every required extension. A tool that preserves unfamiliar text
can pass it to another consumer; validating that text also requires
understanding the extension's rules. This separation lets a reviewer assess the
description's validity, its evidence and a consumer's capabilities as distinct
questions (non-normative; [`L1`](../language.md#l1),
[`L3`](../language.md#l3), [`C8`](../contracts.md#c8),
[`A1`](../profiles.md#a1), [`A5`](../profiles.md#a5)).

Notation and practice: [One contract, several views](packages.md#one-contract-several-views) · [tutorial checking](../tutorial/README.md#how-to-check-your-work).

## From the model to AIL

The rest of the learning route connects AIL notation to these concepts.
Use this map to choose the concept you want to express, then follow its
introduction or tutorial exercise. The spellings below are lookup cues;
the linked introductions place them in examples. Judge each choice by how
well it helps describe and use the API; [Design choices, limits and open
questions](choices.md) develops that assessment.

| Model concept | What AIL writes | Where the notation is introduced and exercised | Canonical rules |
|---|---|---|---|
| [Operations and their values](#operations) | `fn`, callable signatures; `record` and `field`, `alias`, `enum`, `flags`, scalars and pointers; parameter, result and thrown-value slots; `@operation::slot` and places such as `$p`, `.*`, `[]`, `.field` | [From signature to contract](contracts.md#from-signature-to-contract), [Naming what a contract talks about](contracts.md#naming-what-a-contract-talks-about); [tutorial 1](../tutorial/01-lifetime.md) | [`L4`](../language.md#l4), [`L5`](../language.md#l5), [`C1`](../contracts.md#c1) |
| [How a call finishes](#outcomes) | `completions`, `outcome`, `when`, `null`, `nonnull`, `equal`, `range`, `meaning`, `state` | [Every way a call can end](contracts.md#every-way-a-call-can-end); [tutorial 1](../tutorial/01-lifetime.md), [tutorial 3](../tutorial/03-storage.md) | [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5) |
| [Entities that outlive a call](#entities) | `resource`, `object`, `interface`, `global`, `constant`, `property`; `lifecycle`, `member`, `receiver`; `pattern`, `role`, `instance`, `law` | [Lifecycles and patterns](contracts.md#lifecycles-and-patterns), [member example](packages.md#packages-contain-declarations); [tutorial 1](../tutorial/01-lifetime.md) | [`L4–L6`](../language.md#l4), [`C2`](../contracts.md#c2), [`C7`](../contracts.md#c7) |
| [Release responsibility](#responsibility) | `input` with `borrow` or `consume`, `retain`, `give` with `owned` or `borrow` | [Who owns what](contracts.md#who-owns-what); [tutorial 1](../tutorial/01-lifetime.md), [tutorial 2](../tutorial/02-lending.md), [tutorial 5's change](../tutorial/05-access-and-change.md#guided-change-an-owned-snapshot) | [`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5) |
| [Validity](#validity) | `valid`, regions `call`, `static`, `owner`, `invalidated_by`, `mutation` | [How long a borrow lasts](contracts.md#how-long-a-borrow-lasts); [tutorial 2](../tutorial/02-lending.md) | [`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5) |
| [Storage](#storage) | `extent` with `one` or `buffer`, `contents`, `direction`, `aliasing` | [Buffers and strings](contracts.md#buffers-and-strings); [tutorial 3](../tutorial/03-storage.md) | [`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4) |
| [Where and when calls run](#execution) | `execution`, `executor`, `concurrency`, `reentrancy`, `sharing`, `isolation` | [Threads and sharing](contracts.md#threads-and-sharing); [tutorial 4](../tutorial/04-callbacks.md) | [`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3) |
| [Callbacks and their schedules](#callbacks) | `callback` declarations and use blocks, `timing`, `count`, `scope`, `quiescence`, `outside_callback` | [Callbacks](contracts.md#callbacks); [tutorial 4](../tutorial/04-callbacks.md) | [`C2`](../contracts.md#c2), [`C6`](../contracts.md#c6) |
| [The published description](#description) | `language`, `package`, `surface`, `exports`, `import`, `digest`, `as`; declaration identity; `environment`, `available`, `deprecated` | [Packages contain declarations](packages.md#packages-contain-declarations), [What a package claims](packages.md#what-a-package-claims), [Where it holds](packages.md#where-it-holds), [What it depends on](packages.md#what-it-depends-on); [tutorial 1](../tutorial/01-lifetime.md) | [`L1–L3`](../language.md#l1), [`L5`](../language.md#l5) |
| [Reaching the code](#access) | `use abi`, `use profile`, `access`, `in`, `abi`, `via`, `mapping`, `compatibility`, `representation`, `callback_abi` | [Reaching the code](packages.md#reaching-the-code), [Profiles and ABI entries](packages.md#profiles-and-abi-entries); [tutorial 5](../tutorial/05-access-and-change.md) | [`A1–A4`](../profiles.md#a1), [`F1`](../profiles.md#f1) |
| [Writers, checkers and users](#agreement) | Agreement across the description and required profiles; no single construct | [One contract, several views](packages.md#one-contract-several-views), [Extending the language with profiles](contracts.md#extending-the-language-with-profiles); [tutorial checking](../tutorial/README.md#how-to-check-your-work) | [`L1`](../language.md#l1), [`L3`](../language.md#l3), [`C8`](../contracts.md#c8), [`A1`](../profiles.md#a1), [`A5`](../profiles.md#a5) |

## Where next

Continue to [How AIL states a contract](contracts.md) to see notation for
these obligations. To work through an example, try
[Describing a small API](../tutorial/README.md), which uses a separate invented
card API and complete synthetic checkpoint packages.

For a direct notation entry, use [the package shell](../language.md#l1)
and [names and references](../language.md#l2). The latter's G9 diagram is
the **language-containment view**: it locates declarations in packages and
parameters and results in callables. It shows how AIL organizes the text
used to record the API model explained here.

Return to [the overview](../README.md) for all reading paths or
[the glossary](../glossary.md) for a term.
