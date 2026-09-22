# Memory, effects and behavioural contracts

Normative draft 0.1. These contracts describe permitted observations and obligations,
not an analysis engine's confidence. A broad, authoritative permission such as
zero-or-more invocations is valid; a producer MUST NOT use it to conceal a fact
that it has not established. All clauses below are closed, typed vocabulary.

## C1. Slots and regions

`$p` names a parameter of the enclosing callable; `$result` and `$exception`
name its result and declared thrown value. `.*` dereferences a pointer, `.field`
selects a record field, and `[]` selects every element of an array or declared
buffer. A path MUST type-check. `[]` contracts apply uniformly to all elements;
heterogeneous policies need a different representation/profile. Aliases are
expanded before applicability checks. Callback declarations have their own slots.
For pointer storage, `.*` requires `extent(one)` and `[]` requires a buffer extent;
they cannot be alternate overlapping spellings for the same storage. Buffer
element contracts cover the declared initialized length, not unused capacity.

A **reference leaf** is a pointer, resource, object, interface or callback value,
including one inside a by-value aggregate. Each leaf requires applicable ownership
and validity contracts. Traversing a pointer is not automatic: its pointee is
governed by direction, extent and any explicitly addressed nested references.
Null carries no ownership obligation. `nullable` permits null; it does not imply
failure, termination or optional invocation.

The region constructors are `call`, `static` and `owner($slot)`. `call` lasts from
entry through completion of this invocation, including synchronous callbacks.
`static` lasts for the loaded API instance's lifetime; its provider must define
shutdown. `owner` lasts until the referenced owner is destroyed or its final
reference released. The owner must be a non-null object or resource slot valid
on the relevant outcome. Cyclic lifetime dependencies are invalid. Result
borrows, thrown references, aggregate output leaves and writable pointee borrows
cannot use `call`: every escaping borrow's region must survive delivery to its
recipient. A shorter mutation lifetime is expressed by
`invalidated_by`, not by pretending an owner dies.

## C2. Nominal lifetime and concurrency

Resources, objects and interfaces require `lifecycle`. Nominal declarations
(records, resources, objects, interfaces, enums, flags, aliases and callbacks)
require `sharing` and `isolation`. For callbacks these govern the closure value
and all captured state, independently of invocation executor/concurrency.
A closure can satisfy a callback type only if its captures permit every use that
type allows. The callback representation provider supplies its retain/release
operations. Aliases
must agree with the expanded type; enums/flags normally use `value` and `none`.

| Clause | Complete meaning |
|---|---|
| `lifecycle(unique, @destroy)` | Resource only. Each owned handle has exactly one destruction obligation. Destructor has one non-null resource parameter, consumes it at entry, returns unit and has only a successful returned outcome. Its destruction invalidates dependent borrows before it returns. |
| `lifecycle(refcounted, runtime(profile, "retain"), runtime(profile, "release"))` | Resource/object/interface. Each owned reference is a separate release obligation; retain creates another. Provider specifies exact runtime primitives, destruction and finalization. |
| `sharing(value\|transferable\|shared\|confined)` | `value`: freely copyable scalar/value aggregate without reference obligations; `transferable`: sole ownership may move across executors, no concurrent access; `shared`: references may cross executors, concurrency still governed per operation; `confined`: use restricted to declared executor. |
| `isolation(none\|main\|executor(profile, "identity"))` | Nominal isolation. `confined` requires a non-`none` executor. Members must respect isolation, or a profile must explicitly justify a permitted exception. |

A record with reference leaves cannot claim `sharing(value)`. Neither
`sharing(shared)` nor Swift sendability implies concurrent mutation is safe.
Swift conformance status is a separate profile fact. Core `isolation(none)` is
known absence of nominal isolation, not a claim that all methods run anywhere.
Confinement covers retain/release, destruction and use through free functions as
well as member calls. An operation using a confined reference must require its
executor, unless a profile defines a specific legal transfer protocol.

## C3. Callable effects and input obligations

Every `fn` and `callback` MUST state `execution`, `completions`, `executor`,
`concurrency`, `reentrancy`, `mutation` and `variadic`. Core callable types and
declarations share the same rules. A callback declaration describes one callback
invocation; a callback-use block describes when the API invokes that callable.

| Clause | Scope, values and requirements |
|---|---|
| `execution(sync\|async)` | `sync` completes before control returns to caller. `async` requires a profile defining suspension, scheduling and completion delivery; core alone cannot lower it. |
| `completions([returned, thrown, cancelled, terminated])` | Nonempty subset, no duplicates. `thrown` is present iff signature has `throws T`. Cancellation/termination require a profile defining delivery/observation and cleanup. This describes possible completion modes, not a liveness guarantee; a call may fail to terminate. |
| `executor(any\|main\|executor(profile, "identity"))` | Where entry is allowed. `any` permits any thread/executor, without permitting simultaneous calls. Isolation constrains member entry as above. |
| `concurrency(serial\|parallel)` | `serial`: callers must not overlap independent calls using the same mutable storage or receiver/resource. Nested re-entry is governed separately by `reentrancy` and is excluded from this prohibition when allowed. `parallel`: independent overlap is permitted subject to declared buffer rules. Neither setting permits races through unrelated raw aliases. |
| `reentrancy(allowed\|forbidden)` | Whether control nested under an active API call may enter this operation on the same receiver/resource before that earlier call completes, including through synchronous callbacks. Independent of overlap between unrelated control flows. |
| `mutation(none\|receiver\|arguments\|receiver_and_arguments)` | Which externally visible input state may change. Writing out parameters counts as arguments. Does not describe private implementation state or reference-count increments. |
| `variadic(false)` | The complete core non-variadic contract. `true` requires a profile specifying argument schema, promotions and termination. |
| `input($slot, borrow\|consume)` | Required for each input reference leaf. `consume` transfers one owned obligation at entry on every outcome; `borrow` transfers none. Copyable scalar/value input is passed by value without this clause. |
| `retain($slot, none\|strong(region)\|copy(region)\|weak(region)\|unretained(region))` | Required for every input reference leaf, independently of `input`. Describes callee storage beyond immediate use. `strong` creates an independent ownership obligation; `copy` creates an independent semantic copy under a profile; `weak` stores a zeroing weak reference; `unretained` stores a non-owning, non-zeroing reference. `none` promises no retention. Unique resources cannot be strongly retained or copied without an explicit clone profile. |
| `valid($slot, region)` | Required for an input borrowed reference leaf: caller guarantees validity for that region. Consumed inputs must be valid at entry; their callee-side lifetime follows lifecycle/retention. For unretained storage the caller must keep referent alive for the full storage region. |
| `direction($pointer, in\|out\|inout)` | Required for pointer parameters. Applies to pointee storage: readable on entry, writable output, or both. Pointer itself must remain valid for the call. An `out` pointer's prior pointee contents are not read. |
| `aliasing($pointer, disjoint\|may_alias)` | Required for pointer parameters. `disjoint` prohibits overlap with other accessed memory for this call. `may_alias` requires access provider support and does not legalize concurrent data races. |
| `requires(capability(@optionalMember, $receiver))` | Repeatable precondition. A profile-defined runtime test must establish that this receiver implements an optional interface member; platform availability cannot discharge it. |
| `requires(outside_callback(@operation::parameter))` | Repeatable precondition. This call must not occur from within an invocation of the specified callback use; needed for some blocking teardown contracts. |

`input(consume)` and `retain(strong)` are different events: transfer at entry and
creation of another reference. A consumed obligation not returned on an outcome
belongs to the callee, which must discharge it according to lifecycle. A consumed
receiver need not imply mutation, and mutation need not imply consumption.
`mutation` classifies changes to live contents; consuming/destroying a value and
ending its borrows are specified by transfer/lifecycle, not an additional mutation.
Property `storage` must agree with actual setter retention and getter ownership;
`weak` requires zeroing and hence nullable reads after referent death.

Input contracts also apply to reference leaves read from `in`/`inout` pointee
storage. They do not apply to an `out` pointee's uninitialized contents. For
`inout` reference replacement, the old value's borrow/consumption and new value's
ownership must both be explicit. `state(unchanged)` is forbidden for a subtree
whose input obligations were consumed; returning the same reference then needs
`state(valid)` and `give(owned)` so ownership is visibly transferred back.

A retention region naming an output owner is prospective: it takes effect only
on outcomes returning that owner non-null and valid. Other outcomes permit only
call-scoped temporary storage and must discharge temporary retained/copied
references before completion. This does not undo any `consume` at entry.

## C4. Buffers and strings

Every pointer leaf, including returned pointers and nested pointer leaves, requires
one `extent($slot, one)` or
`extent($slot, buffer(length, capacity, bytes|elements))`. Length and capacity are
nonnegative integer literals or integral scalar slots. For input pointers they
must be valid at entry; for output pointers on every outcome claiming validity.
`one` means storage for exactly one `T`; not an unspecified extent. A buffer
requires `0 <= length <= capacity` as a caller precondition on input and callee
postcondition on output. Multiplication by element size must not overflow the
selected provider's address space. Capacity describes allocated storage, length
describes readable initialized elements. A non-null **zero-capacity** buffer need
not be dereferenceable. Positive capacity requires allocated, correctly aligned
storage for that capacity, even when length is zero. Input `out` buffers need no
initialized elements on entry; a valid output initializes the declared length.
A nullable pointer must have zero length/capacity when null.

Pointer parameters require `contents($slot, binary)` or
`contents($slot, text("encoding", none|nul))`. Other pointer slots require it
where their pointee is byte/integer character storage. Encoding identifiers and
code-unit widths are supplied by the access profile. For `nul`, length excludes
the final zero code unit, capacity includes it, and length + 1 <= capacity;
embedded zero code units are forbidden. Binary has no terminator. Pointer
constness, direction, mutation and extent must agree. An `out` or `inout` buffer
requires a `mutptr`, not `ptr`.

A pointer is not automatically a C string. C-string encoding and termination
must be established. Strings whose extent is determined only by searching for
a terminator require a profile-defined scanned-buffer contract; the core does
not invent a maximum bound. Record layout, field offsets and array stride are
representation facts supplied by an access provider under [A4](profiles.md#a4-representation-and-compatibility).

## C5. Outcomes and returned obligations

Each callable MUST have at least one named outcome. Each outcome requires exactly
one `when(completion, predicate)` and `meaning(success|failure|cancellation|termination)`.
Predicates are `any`, `null($slot)`, `nonnull($slot)`, `equal($slot, literal)` or
`range($slot, lowerInteger, upperInteger)`, with inclusive bounds. Literals here
are integers or Booleans. Slots are the result or an `out`/`inout` scalar pointee,
and `$exception` for thrown completion. Per completion, predicates must either be
one `any`, or use the **same** discriminator slot. Discriminators must be valid
on every outcome for that completion. Ranges apply only to integers; null tests
apply only to nullable reference types. Floating comparisons are not supported.

Outcomes for each declared completion MUST be mutually exclusive and exhaustive
over its discriminator's entire type domain, using the enum/flags domain from
L4 when applicable. Every declared completion has outcomes; no other completion
does. Closed integer intervals, finite enums/Booleans and the null/non-null split
make this rule decidable. Guards do not evaluate native code. Correlations across
multiple discriminators require a profile with its own equally precise rules.

Every non-unit result, thrown value and writable pointee MUST have exactly one
`state($slot, valid|invalid|unchanged)` in each applicable outcome. A top-level
state covers scalar contents and aggregate shape; reference leaves still require
individual transfer and validity clauses. A writable buffer uses `state($p[], ...)`
for its elements; a single pointee uses `state($p.*, ...)`. Unused buffer capacity
never contains owned values implicitly. `unchanged` is legal only for `inout`
storage and preserves its entry obligations. Returned results and thrown values
must be valid on their corresponding completion. A result is not available on
thrown/cancelled/terminated completion. An invalid output cannot be read, freed,
tested for null or used as a discriminator. An invalid output buffer conveys no
initialized elements. Partially initialized buffers need an explicit valid length.

| Outcome clause | Meaning |
|---|---|
| `give($slot, owned\|borrow(region))` | Required for each valid output reference leaf; `owned` supplies one lifecycle obligation to the caller, `borrow` supplies none. Pointers may be owned only with a profile-defined allocator/release contract. |
| `invalidated_by($slot, [@operation, ...])` | Required for every output borrow, even if empty. Invalidation happens at entry to any listed operation involving its owner, in addition to region end. Such operations must have an owner parameter and an appropriate mutation contract. There are no hidden earlier invalidators. |
| `state($slot, valid\|invalid\|unchanged)` | Defined above. Cannot contradict its enclosing outcome predicate. |

Clauses for a nullable reference are conditional on non-null, so a null failure
result can retain the same `give` annotation without creating an obligation.
An outcome's `give` and `invalidated_by` override nothing: input clauses describe
entry, output clauses describe exit. Pointer extent/content clauses for results
belong to the callable body and must be satisfiable on every valid outcome.

Errors are observations. `meaning(failure)` alone does not convert null or a status
code into an exception. BOOL/error-out, exception, sentinel return and status-code
APIs keep their actual signatures and outcomes. A projected operation that loses
observable success/status distinctions is a different declaration, related using
an access profile, not an interchangeable path to the same operation.

## C6. Callback schedules and teardown

Each callback-typed parameter MUST have one `callback $parameter { ... }` block,
including nullable parameters (rules apply when non-null). Nested callback fields
use their full place. This is separate from the callback declaration's signature
and its own input/output contracts. Each block requires all these clauses:

| Clause | Meaning |
|---|---|
| `timing(during_call\|after_return\|either)` | Allowed invocation start times relative to the registration call. `after_return` excludes invocation before returned completion. |
| `count(min, max)` | Nonnegative integer minimum and integer maximum or `many`. Bounds count invocations over this registration's whole scope, conditional on eventual scope end. `many` is unbounded, not unknown. Min <= max. |
| `scope(call\|owner($slot))` | Last possible invocation belongs to the call or the owned returned object/resource's lifetime. For owner scope, every successful registration outcome must return that valid non-null owner. A null/failure registration creates no stored callback and has zero invocations after return. |
| `executor(any\|main\|executor(profile, "identity"))` | Executor on which callbacks enter. Must be compatible with the callback declaration. |
| `concurrency(serial\|parallel)` | Whether independent invocations of this registration may overlap; nested invocation is governed by `reentrancy`. Independent registrations also obey the callback declaration's concurrency contract. |
| `reentrancy(allowed\|forbidden)` | Whether an invocation of this registration may be nested inside an earlier invocation. |
| `quiescence(return)` or `quiescence(@destroy)` | `return` requires scope `call` and all callbacks finish before registration completes. `@destroy` requires a unique owner and its declared destructor: when it returns no invocation is running or can begin, including on other threads. |

`scope(call)` requires `timing(during_call)`, retention `none`, and quiescence
`return`. An owner scope requires retention whose region is that same owner,
and quiescence at its destruction. The provider must define the stored callback
representation and how it is released. A blocking destructor with quiescence
must require `outside_callback` unless a profile specifies a non-deadlocking
reentrant destruction protocol. No special case is inferred from a callback name.

Count, timing, thread, overlap and teardown are independent facts. “Copied for
asynchronous invocation” supplies neither exactly-once delivery nor a cancellation
guarantee. The core supports termination through unique-owner destruction; token
cancellation with a separate acknowledgement or a callback destroy-notifier needs
a profile with explicit events and ordering. Such APIs MUST NOT be flattened into
`quiescence(@cancel)` when cancellation return is not a quiescence boundary.

## C7. Global storage

A global requires `sharing`, `isolation`, `extent`/`contents` if pointer-typed,
and `give`/`invalidated_by` directly in its body if its loaded value is a borrowed
reference. Core globals permit scalar/value storage or `give($result, borrow(static))`
with no earlier invalidators. Mutable reference globals and ownership-changing
reads/writes need a profile or explicit accessor functions. Core mutable value
globals require `sharing(confined)` and non-`none` isolation; atomics require a
profile. Constants with access paths obey the same output rules, are immutable,
and have no mutation contract. Literal scalar constants need no ownership clauses.

## C8. Obligation checking

Validators MUST reject missing applicable facts, contradictory clauses, unknown
vocabulary, invalid slot paths, unsatisfied lifecycle references, impossible
outcomes, uncovered output states and unsupported required profile semantics.
They MUST NOT substitute a “safe” guessed contract. Conservative generated
bindings may add restrictions, but must label them as consumer restrictions and
must preserve the API's actual contract in documentation and machine views.

This core checks local symbolic constraints; it is not a proof system for native
implementations, arbitrary program behaviour or termination. Finite publication
checks do not establish that an author has told the truth. Trust, review and
implementation testing remain separate from language validity.
