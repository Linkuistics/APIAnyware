# Memory, effects and behavioural contracts

<!-- reading-aid: page-context -->
> **Purpose:** rules with reading aids — follow the obligations attached to values and calls.
> **Reader:** language designers new to API binding, and authors or implementers checking exact contracts.
> **Before this:** [A model of API behaviour and binding obligations](explanation/model.md); [the language-containment view](language.md#l2) locates packages, declarations and slots.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [C1](#c1), [C2](#c2), [C3](#c3), [C4](#c4), [C5](#c5), [C6](#c6), [C7](#c7) and [C8](#c8) below are canonical.

Each bordered **Reading aid (non-normative)** explains an invented example.
The rule paragraphs outside the border state the requirements.
Fragments name their omitted context; the [conformance examples](conformance.md#positive-specifications)
supply complete synthetic contracts. For a connected explanation, see
[How AIL states a contract](explanation/contracts.md).
<!-- /reading-aid -->

Normative draft 0.1. These contracts describe permitted observations and obligations,
not an analysis engine's confidence. A broad, authoritative permission such as
zero-or-more invocations is valid; a producer MUST NOT use it to conceal a fact
that it has not established. All clauses below are closed, typed vocabulary.

<a id="c1"></a>

## C1. Slots and regions

<!-- reading-aid: c1-places -->
<blockquote>

<a id="reading-aid-non-normative-address-a-value-inside-its-callable"></a>

**Reading aid (non-normative): address a value inside its callable**

C1 connects [Operations and their values](explanation/model.md#operations)
to [Validity](explanation/model.md#validity), so a reader can identify the
value a contract addresses and the lifetime that bounds its use.

The invented canvas package declares a `Canvas` resource and imports the record
`Geometry::Point`, with integer fields `x` and `y` ([L2](language.md#l2)).
Suppose an inspection operation also receives a record containing a canvas
and an array of two canvases. Each input occupies a named [slot](glossary.md#slot).
A [place](glossary.md#place) selects the value to which a contract applies.

Fragment — shows places in an additional canvas operation. The header, import,
`Canvas`, publication context, nominal contracts and most callable contracts
are omitted. This constructed operation is separate from the complete fixtures.

<!-- ail-example: examples/rule-reading/contracts.ail region=places -->
```ail
package example::canvas version "1" {
  record Selection {
    field canvas: Canvas;
    // Nominal contracts omitted.
  }
  fn inspect(selection: Selection, point: ptr<Geometry::Point>, items: array<Canvas, 2>) -> unit {
    input($selection.canvas, borrow);
    retain($selection.canvas, none);
    valid($selection.canvas, call);
    input($items[], borrow);
    retain($items[], none);
    valid($items[], call);
    extent($point, one);
    // Pointer inputs, effects, outcomes and access omitted.
  }
  // Header, import, Canvas and publication context omitted.
}
```

`$selection.canvas` selects the record's field. `$items[]` selects every array
element, giving each the same input policy. These `Canvas` values are
[reference leaves](glossary.md#reference-leaf): each needs its own applicable
ownership and validity facts even though the containing record or array is
passed by value ([C1](#c1), [C3](#c3)).

`$point` selects the pointer value. With `extent($point, one)`, `$point.*`
selects the single pointed-to record and `$point.*.x` its coordinate. For a
buffer pointer, `[]` instead selects the initialized elements within its
buffer extent; [C4](#c4) supplies that different storage contract. Following a
pointer therefore needs an explicit storage description. A field selection
alone describes only which value is addressed.

Within `position(canvas: Canvas) -> Geometry::Point` from L2, `$result.x`
selects the result's `x` field. Within a callable declared with `throws T`,
`$exception` addresses its thrown value; the selected provider would also need
to support throwing ([C3](#c3), [F1](profiles.md#f1)). Callback declarations
have their own parameter, result and exception slots. The longer spelling
`@position::result` identifies a slot from outside its callable; `$result`
selects it locally ([L2](language.md#l2)).

Each place selects a particular subject for a contract:

| Place | Starting slot | Value or storage addressed |
|---|---|---|
| `$selection.canvas` | `selection` | The record's Canvas reference |
| `$items[]` | `items` | Every Canvas reference in the array, under the same policy |
| `$point.*.x` | `point` | The `x` coordinate in the single pointed-to record |
| `$result.x` in `position` | `result` | The returned point's `x` coordinate |

The types and extent clauses determine whether each selection is meaningful;
C1 checks the complete place against them. The [place grammar](reference/notation.md#places)
supplies the exact forms. Return to the [language-containment view](language.md#l2)
to locate `position` and its imported result type, or the
[glossary's place entry](glossary.md#place) for a shorter reminder.

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: c1-regions -->
<blockquote>

<a id="reading-aid-non-normative-connect-a-borrow-to-the-period-it-remains-usable"></a>

**Reading aid (non-normative): connect a borrow to the period it remains usable**

In the synthetic Store API, each `Store` owns sixteen immutable bytes. A caller
can ask for a view of those bytes while keeping ownership of the `Store`.
The view is a [borrow](glossary.md#borrow): the caller can read the bytes for a
stated period while the `Store` continues to own them. The description states
two periods: how long the input `Store` must be valid for the call, and
how long the returned pointer remains usable. A [region](glossary.md#region)
names such a lifetime bound ([C1](#c1)).

Fragment — shows the input and result contracts of `view`. The complete
[buffers package](examples/buffers.ail) supplies Store's lifetime, publication
context, effects and access through the synthetic F1 providers.

<!-- ail-example: examples/rule-reading/contracts.ail region=regions -->
```ail
package example::buffers version "1" {
  fn view(store: Store) -> ptr<u8> {
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
    // Availability, effects and access omitted.
  }
  // Header, Store lifetime and publication context omitted.
}
```

`valid($store, call)` asks the caller to keep the Store valid through this
invocation. `give($result, borrow(owner($store)))` lets the caller use the
returned bytes until that Store is destroyed. The owner is the Store passed
to this invocation, so the caller keeps that particular Store alive while
using the view.
`invalidated_by($result, [])` states that no operation ends the borrow before
its region ends ([C5](#c5)).

For provider-owned data that lasts until unloading, the region can instead be
`static`; [C7's global example](#c7) locates that spelling. The provider defines
what ends this API-instance lifetime. For data replaced by an earlier mutation,
`invalidated_by` names the operation as [C5](#c5) explains. A call-scoped region
is suitable for an input used during the call; a returned borrow needs a region
that survives its delivery. See [Borrow validity](glossary.md#borrow-validity)
for the caller's practical obligation.

</blockquote>
<!-- /reading-aid -->

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

<a id="c2"></a>

## C2. Nominal lifetime and concurrency

<!-- reading-aid: c2-lifetime -->
<blockquote>

<a id="reading-aid-non-normative-name-who-releases-a-handle-and-where-it-can-be-used"></a>

**Reading aid (non-normative): name who releases a handle and where it can be used**

C2 connects [Entities that outlive a call](explanation/model.md#entities)
with [Release responsibility](explanation/model.md#responsibility),
[Where and when calls run](explanation/model.md#execution) and
[Callbacks and their schedules](explanation/model.md#callbacks), so readers
can establish a value's lifetime and permitted use, including callback captures.

The caller who receives an [owned](glossary.md#owned) `Store` handle becomes
responsible for destroying it. The `Store` declaration names `destroy` as the
operation that fulfils that responsibility. This association is its
[lifecycle](glossary.md#lifecycle); [L6](language.md#l6) also shows how a
pattern records the relation between resource and destructor.

Fragment — shows Store and the input of its destructor, as package-level
siblings. The complete [buffers package](examples/buffers.ail) supplies the
header, publication facts and all omitted callable clauses.

<!-- ail-example: examples/rule-reading/contracts.ail region=lifecycle -->
```ail
package example::buffers version "1" {
  resource Store {
    lifecycle(unique, @destroy);
    sharing(transferable);
    isolation(none);
    // Availability, deprecation and implements omitted.
  }
  fn destroy(store: Store) -> unit {
    input($store, consume);
    retain($store, none);
    // Effects, successful returned outcome and access omitted.
  }
  // Header and publication context omitted.
}
```

`@destroy` selects the function declaration. At entry to that function,
`input($store, consume)` transfers the caller's destruction obligation to the
[callee](glossary.md#caller-and-callee), which destroys the `Store`.
`sharing(transferable)` permits moving sole ownership between
[executors](glossary.md#executor), such as from one thread to another.
`isolation(none)` states that the type imposes no restriction on which executor
can use it; this type-level restriction is called [isolation](glossary.md#isolation).
The operation's own concurrency rules still determine which calls may overlap
([C2](#c2), [C3](#c3)).

Now consider an object whose references can be retained independently. Each
owned reference has its own release obligation. The fixture's Counter also
requires use on the main thread, which includes retaining and releasing it.

Fragment — shows Counter from the complete [objects package](examples/objects.ail).
The surrounding package supplies F1's `fixture` provider, the `test` environment,
member operations and publication clauses.

<!-- ail-example: examples/objects.ail lines=12-23 -->
```ail
  object Counter {
    available([test]);
    deprecated(no);
    source(fixture, "Outer.Counter");
    base(none);
    implements([]);
    lifecycle(refcounted, runtime(fixture, "retain"), runtime(fixture, "release"));
    sharing(confined);
    isolation(main);
    fixture::sendability(nonconforming);
    doc("Counter instances supplied by the host have a main-thread lifetime and mutable count.");
  }
```

`runtime(fixture, "retain")` and `runtime(fixture, "release")` name operations
defined by the provider. `sharing(confined)` pairs with `isolation(main)`;
its member operations enter on `main` too. `base(none)` and `implements([])`
are the nominal relations explained in [L5](language.md#l5).
The namespaced `fixture::sendability` fact is explained at [F1](profiles.md#f1).

For a scalar-only record such as `Geometry::Point`, `sharing(value)` permits
copying the value without reference obligations. A record containing a Canvas
reference needs a policy that accounts for that reference. A callback's
`sharing` and `isolation` describe the callable value and its saved
[callback captures](glossary.md#callback-captures); [C6](#c6) separately
shows when the API may invoke it. See [Entities and their lifecycles](explanation/contracts.md#entities-and-their-lifecycles).

</blockquote>
<!-- /reading-aid -->

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

<a id="c3"></a>

## C3. Callable effects and input obligations

<!-- reading-aid: c3-effects -->
<blockquote>

<a id="reading-aid-non-normative-read-the-call-conditions-before-its-inputs"></a>

**Reading aid (non-normative): read the call conditions before its inputs**

C3 records [How a call finishes](explanation/model.md#outcomes),
[Release responsibility](explanation/model.md#responsibility),
[Validity](explanation/model.md#validity), [Storage](explanation/model.md#storage)
and [Where and when calls run](explanation/model.md#execution), so callers
can establish the conditions for entering an operation with its inputs.

When calling `view`, the caller supplies a Store and receives a pointer to its
bytes. The author also describes when the call finishes, where it may enter,
and how it may overlap other calls. These are separate facts about the
invocation ([C3](#c3)).

Fragment — shows `view`'s effects and input clauses. The complete
[buffers package](examples/buffers.ail) supplies the header, Store lifetime,
publication, returned-pointer contract, outcome and F1 access path.

<!-- ail-example: examples/rule-reading/contracts.ail region=effects -->
```ail
package example::buffers version "1" {
  fn view(store: Store) -> ptr<u8> {
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
    // Extent, contents, outcome, availability and access omitted.
  }
  // Header, Store lifetime and publication context omitted.
}
```

`execution(sync)` places completion before control returns to the caller;
`completions([returned])` lists the permitted completion mode. Together these
clauses describe how an invocation can finish, while making no promise that it
ever will finish. `executor(any)` allows entry on any executor.
`concurrency(serial)` requires callers to let one independent call finish before
another uses the same mutable storage or receiver/resource. If an active call
causes a nested call on that same receiver/resource, `reentrancy(allowed)`
permits the nested entry before the outer call finishes.
Executor, independent overlap and nested entry therefore
answer three different questions ([C3](#c3); [concurrency](glossary.md#concurrency),
[re-entrancy](glossary.md#re-entrancy)).

`mutation(none)` says the operation changes no externally visible input state,
and `variadic(false)` says its parameters are exactly those in the signature.
A provider would need to define the extra delivery machinery for `execution(async)`,
and the argument rules for `variadic(true)`. F1 supplies neither. Callback
*declarations* use the same invocation clauses, as the Handler example in
[C6](#c6) shows; callback registration has an additional schedule.

`input($store, borrow)` leaves the ownership obligation with the caller.
`retain($store, none)` promises that the callee stores no reference beyond
immediate use. `valid($store, call)` supplies the caller's lifetime promise.
A scalar argument such as an integer coordinate needs no ownership transfer
clause. [Who is responsible for releasing a value?](explanation/unsaid.md#who-is-responsible-for-releasing-a-value)
explains the distinction in domain terms.

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: c3-retention -->
<blockquote>

<a id="reading-aid-non-normative-distinguish-transfer-from-retained-storage"></a>

**Reading aid (non-normative): distinguish transfer from retained storage**

A registration operation may borrow a callback at entry and retain another
reference for later invocations. Keeping that reference beyond immediate use
is [retention](glossary.md#retention). In the synthetic subscription API, the
retained reference lasts as long as the returned `Subscription`.

Fragment — shows `subscribe`'s input contract. The complete
[callbacks package](examples/callbacks.ail) supplies Handler, the unique
Subscription lifecycle, an owned non-null result, its schedule, effects,
F1 representation and access, and publication context.

<!-- ail-example: examples/rule-reading/contracts.ail region=retention -->
```ail
package example::callbacks version "1" {
  fn subscribe(handler: Handler) -> Subscription {
    input($handler, borrow);
    retain($handler, strong(owner($result)));
    valid($handler, call);
    // Effects, callback schedule, owned result outcome and access omitted.
  }
  // Header, Handler, Subscription lifetime and publication context omitted.
}
```

The caller keeps its original obligation for `handler`; `strong(owner($result))`
creates an independent retained reference. `valid($handler, call)` covers the
borrowed input during registration. The provider's retained reference then keeps
the callback value and its captures alive for the stated storage period.
[C6](#c6) explains when invocations can occur within that period.

The Store destructor in [C2](#c2) instead uses `consume` with retention `none`:
it takes over and discharges the existing obligation. Transfer at entry and
creation of another reference are separate events. If a consuming call fails,
the transfer still occurred. If an operation names an output owner in its
retention region, that storage period takes effect only on outcomes that
produce the valid non-null owner ([C3](#c3)).

Other `retain` values describe other storage policies. In this same clause
position, `copy(owner($result))` would require a provider-defined semantic copy;
F1 does not support it. `weak(owner($result))` would require a zeroing reference,
and `unretained(owner($result))` would require the caller to keep the referent
alive for that full period. These are conditional syntax variants, not claims
that the subscription fixture implements those alternatives. The selected
provider and companion clauses would have to support the chosen policy.
See [Retention](glossary.md#retention) and [C2](#c2) for the lifetime constraints.

</blockquote>
<!-- /reading-aid -->

`input(consume)` and `retain(strong)` are different events: transfer at entry and
creation of another reference. A consumed obligation not returned on an outcome
belongs to the callee, which must discharge it according to lifecycle. A consumed
receiver need not imply mutation, and mutation need not imply consumption.
`mutation` classifies changes to live contents; consuming/destroying a value and
ending its borrows are specified by transfer/lifecycle, not an additional mutation.
Property `storage` must agree with actual setter retention and getter ownership;
`weak` requires zeroing and hence nullable reads after referent death.

<!-- reading-aid: c3-pointers -->
<blockquote>

<a id="reading-aid-non-normative-separate-the-pointer-input-from-the-output-storage"></a>

**Reading aid (non-normative): separate the pointer input from the output storage**

`copy_bytes` receives a writable pointer supplied by the caller. The pointer
itself is borrowed for the call; the memory it addresses receives output.
The callee writes sixteen bytes on success ([C3](#c3), [C4](#c4)).

Fragment — shows the destination contract. The complete
[buffers package](examples/buffers.ail) supplies Store's input, remaining
effects, outcomes, access and publication context.

<!-- ail-example: examples/rule-reading/contracts.ail region=pointers -->
```ail
package example::buffers version "1" {
  fn copy_bytes(store: Store, destination: mutptr<u8>) -> bool {
    mutation(arguments);
    input($destination, borrow);
    retain($destination, none);
    valid($destination, call);
    direction($destination, out);
    aliasing($destination, disjoint);
    extent($destination, buffer(16, 16, elements));
    contents($destination, binary);
    // Store input, remaining effects, outcomes, availability and access omitted.
  }
  // Header, Store lifetime and publication context omitted.
}
```

`direction($destination, out)` lets the callee write the pointed-to storage
and forbids it from reading the old contents. With
`aliasing($destination, disjoint)`, the caller supplies storage that does not
overlap other memory accessed by this call.
`mutation(arguments)` records the externally visible write. The `mutptr<u8>`
type permits writing; `extent` and `contents` describe that storage in [C4](#c4).
For an `in` pointer the callee reads existing contents; `inout` permits both
reading and replacing them. `may_alias` is a separate provider-supported
alternative to `disjoint` and still gives no permission for data races.

An old reference read from `inout` storage has its own input obligation. A new
reference written there has an output obligation. [C5](#c5) shows the two sides
of replacement with `$value.*`. With `out` storage, there is no initialized old
reference to consume. See [Output state](glossary.md#output-state).

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: c3-requires -->
<blockquote>

<a id="reading-aid-non-normative-locate-a-precondition-at-the-call-it-restricts"></a>

**Reading aid (non-normative): locate a precondition at the call it restricts**

Some operations need a fact about this particular receiver before entry.
Suppose a provider offers an interface with an optional `redraw` member.
The caller would use that provider's runtime test to establish that the
receiver implements it ([C3](#c3)).

Fragment — shows an optional-member precondition in a hypothetical package.
The complete description would need Panel's nominal contract, publication
context, callable contracts and a provider defining the runtime test and access.
F1 does **not** support optional interface members.

<!-- ail-example: examples/rule-reading/contracts.ail region=capability -->
```ail
package example::optional version "1" {
  interface Panel {
    // Nominal contracts and provider representation omitted.
  }
  fn redraw(panel: Panel) -> unit {
    member(@Panel, instance);
    receiver($panel);
    requirement(optional);
    requires(capability(@redraw, $panel));
    // Input, effects, outcome, availability and access omitted.
  }
  // Header, capable provider and publication context omitted; F1 cannot support this.
}
```

`requirement(optional)` describes the member; `requires(capability(@redraw, $panel))`
states the condition for calling it on this receiver. `@redraw` names the
operation and `$panel` its local receiver value. `available([test])`, if supplied,
would describe an environment, while this capability concerns one receiver
([L3](language.md#l3), [L5](language.md#l5)).

A teardown operation can instead require
`outside_callback(@subscribe::handler)`. [C6](#c6) locates that clause inside
`unsubscribe` and explains the deadlock it prevents. Both forms are
`requires(...)` clauses attached to the operation whose entry they constrain.
The [availability glossary entry](glossary.md#availability) revisits the
platform/receiver distinction.

</blockquote>
<!-- /reading-aid -->

<a id="c4"></a>

## C4. Buffers and strings

<!-- reading-aid: c4-buffers -->
<blockquote>

<a id="reading-aid-non-normative-count-initialized-data-and-allocated-space-separately"></a>

**Reading aid (non-normative): count initialized data and allocated space separately**

C4 expresses [Storage](explanation/model.md#storage), so callers and tools
can determine how much memory exists, which elements are initialized and
how to interpret them.

The preceding `copy_bytes` example describes sixteen writable bytes with
`extent($destination, buffer(16, 16, elements))`. The first number is the
initialized length supplied by a valid output; the second is allocated
capacity. Here the element type is `u8`, so an element occupies one byte.
For other types, `elements` counts values of that type and `bytes` counts bytes
([C4](#c4); [Buffer extent](glossary.md#buffer-extent)).

A text input needs another fact: how the bytes encode characters and whether
a terminator follows them. Consider three UTF-8 code units followed by a zero.

Fragment — shows a constructed text input using F1's supported `utf-8`
encoding. A complete package also supplies the header, pinned providers,
environment/publication context, effects, successful returned outcome and access.

<!-- ail-example: examples/rule-reading/contracts.ail region=text -->
```ail
package example::text version "1" {
  fn accept_text(text: ptr<u8>) -> unit {
    input($text, borrow);
    retain($text, none);
    valid($text, call);
    direction($text, in);
    aliasing($text, disjoint);
    extent($text, buffer(3, 4, elements));
    contents($text, text("utf-8", nul));
    // Effects, successful returned outcome, availability and access omitted.
  }
  // Header, fixture provider dependencies and publication context omitted.
}
```

The caller supplies four allocated bytes. Three contain the text and the fourth
contains the zero terminator; the text's three code units contain no embedded
zero. `contents($text, text("utf-8", nul))` names that interpretation. With
`text("utf-8", none)`, the length would delimit text without a required
terminator. With `binary`, zero bytes would be ordinary data ([C4](#c4)).

`buffer(0, 0, elements)` permits a non-null pointer with no dereferenceable
storage. `buffer(0, 4, elements)` still requires four allocated, aligned bytes,
even though its initialized length is zero. A nullable pointer that is null has
both length and capacity zero. Length and capacity may also name integral
scalar places, such as `$length`, when those slots exist and are valid at the
required entry or output point. An output buffer's `state` covers its initialized
elements as [C5](#c5) shows; capacity alone creates no initialized values.

For one pointed-to record, `extent($point, one)` in [C1](#c1) supplies a single
pointee instead of a buffer. Native field offsets and array stride come from the
selected representation provider ([A3](profiles.md#a3)). See [How many bytes exist,
and what do they contain?](explanation/unsaid.md#how-many-bytes-exist-and-what-do-they-contain).

</blockquote>
<!-- /reading-aid -->

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

<a id="c5"></a>

## C5. Outcomes and returned obligations

<!-- reading-aid: c5-outcomes -->
<blockquote>

<a id="reading-aid-non-normative-use-an-observable-result-to-choose-the-output-contract"></a>

**Reading aid (non-normative): use an observable result to choose the output contract**

C5 connects [How a call finishes](explanation/model.md#outcomes) to
[Release responsibility](explanation/model.md#responsibility) and
[Validity](explanation/model.md#validity), so callers know which outputs they
can use and which obligations arrive with them.

The Store copy operation returns a Boolean. On `true`, its destination contains
sixteen initialized bytes; on `false`, the destination cannot be read as output.
The Boolean remains valid in both cases so the caller can decide which case
occurred. It is the [discriminator](glossary.md#discriminator) for these two
[outcomes](glossary.md#outcome) ([C5](#c5)).

Fragment — shows both outcomes inside their callable. The complete
[buffers package](examples/buffers.ail) supplies the header, Store lifetime,
input/effect/buffer contracts, availability and F1 access path.

<!-- ail-example: examples/rule-reading/contracts.ail region=outcomes -->
```ail
package example::buffers version "1" {
  fn copy_bytes(store: Store, destination: mutptr<u8>) -> bool {
    outcome copied {
      when(returned, equal($result, true));
      meaning(success);
      state($result, valid);
      state($destination[], valid);
    }
    outcome failed {
      when(returned, equal($result, false));
      meaning(failure);
      state($result, valid);
      state($destination[], invalid);
    }
    // Input, buffer, effect and access contracts omitted.
  }
  // Header, Store lifetime and publication context omitted.
}
```

`copied` and `failed` are names local to this function. `when` pairs the
completion `returned` with a predicate over `$result`. `equal(..., true)` and
`equal(..., false)` cover the Boolean domain without overlap. `meaning`
labels `true` as success and `false` as failure. In both cases the caller
receives a Boolean return value. `state($destination[], ...)` addresses the
initialized buffer elements; `state($result, valid)` keeps the discriminator readable.
An invalid destination cannot be inspected even though the returned Boolean can.

For a nullable result, `nonnull($result)` and `null($result)` divide the two
cases. See `create` in the [complete buffers package](examples/buffers.ail).
For an integer, inclusive `range($result, 0, 255)` would cover all of a `u8`
result's domain in one outcome. `any` is the single unpartitioned case, as in
`view` at [C1](#c1). A partition within one completion uses the same valid
discriminator throughout ([C5](#c5)).

Both outcomes belong to `copy_bytes`; each states what its caller may observe
and read for that case. C5 checks that they cover every permitted finish
without overlap and supply the applicable output clauses.
[Every way a call can end](explanation/contracts.md#every-way-a-call-can-end)
explains why a caller needs this complete partition. For exact syntax, see
the [outcome](reference/notation.md#outcome),
[callable](reference/notation.md#callable) and
[clause-value](reference/notation.md#clause) grammar sections.

</blockquote>
<!-- /reading-aid -->

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

<!-- reading-aid: c5-outputs -->
<blockquote>

<a id="reading-aid-non-normative-track-the-obligation-delivered-with-a-valid-output"></a>

**Reading aid (non-normative): track the obligation delivered with a valid output**

When a caller receives an owned reference, it becomes responsible for releasing
or destroying the value according to its lifecycle. When it receives a borrowed
reference, it gains permission to use the value for a bounded period.
The [C1 `view` fragment](#c1) gives a borrowed pointer tied to the Store;
`create` in the [buffers package](examples/buffers.ail) instead uses
`give($result, owned)` for a newly created Store ([C5](#c5)).

For a null result in `create`'s failure outcome, the same `give` annotation
creates no obligation. For a non-null result, it delivers the one destruction
obligation defined by Store's lifecycle. For a returned record containing
references, `state($result, valid)` covers the record's shape while each
reference leaf needs its own `give`, using a place such as `$result.canvas`.
[C1](#c1) explains how field places select those leaves.

Replacing a reference through a pointer has both an entry and an exit side.
Here a constructed operation takes the old Counter reference from one storage
cell and supplies an owned Counter reference on return.

Fragment — shows one `inout` reference cell. A complete package supplies the
header, Counter lifecycle/representation, pointer input obligations, contents,
aliasing, effects, publication context and access. This is a constructed
replacement contract, not an operation in the frozen Counter fixture.

<!-- ail-example: examples/rule-reading/contracts.ail region=replacement -->
```ail
package example::exchange version "1" {
  fn replace(value: mutptr<Counter>) -> unit {
    extent($value, one);
    direction($value, inout);
    input($value.*, consume);
    retain($value.*, none);
    outcome replaced {
      when(returned, any);
      meaning(success);
      state($value.*, valid);
      give($value.*, owned);
    }
    // Pointer input, contents, aliasing, effects, availability and access omitted.
  }
  // Header, Counter lifetime and publication context omitted.
}
```

`$value` is the pointer; `$value.*` is the Counter reference stored in that cell.
`consume` transfers the old reference's obligation at entry. The valid output
and `give(..., owned)` transfer an obligation back on return, even if the
implementation returns the same reference. `state($value.*, unchanged)` would
instead preserve entry obligations, which is incompatible with having consumed
them ([C3](#c3), [C5](#c5)).

For an owner-bounded output borrow, `invalidated_by($result, [@refresh])` would
add an earlier endpoint at entry to `refresh`. That operation would need an
owner parameter and the appropriate mutation contract. The immutable Store's
empty list asserts no such earlier invalidator. The tutorial's
[borrowed-to-owned change](tutorial/05-access-and-change.md) develops a mutable
owner and an independent owned snapshot in complete synthetic packages.

</blockquote>
<!-- /reading-aid -->

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

<a id="c6"></a>

## C6. Callback schedules and teardown

<!-- reading-aid: c6-schedule -->
<blockquote>

<a id="reading-aid-non-normative-separate-one-callback-invocation-from-its-registration"></a>

**Reading aid (non-normative): separate one callback invocation from its registration**

C6 expresses [Callbacks and their schedules](explanation/model.md#callbacks),
so a caller can relate permitted invocations to registration and determine
when callback state can be released.

The synthetic notification API receives a Handler value and returns a
Subscription that keeps it registered. First read the Handler declaration:
its parameter `value` is the integer delivered during one callback invocation.
Its nominal clauses describe the callable value and captured state; its effects
and outcome describe that invocation ([C2](#c2), [C3](#c3)).

Fragment — shows Handler from the complete [callbacks package](examples/callbacks.ail).
The package supplies the F1 provider aliases `native` and `fixture`, environment,
Subscription lifetime, registration/destruction operations and publication context.

<!-- ail-example: examples/callbacks.ail lines=19-37 -->
```ail
  callback Handler(value: u64) -> unit {
    available([test]);
    deprecated(no);
    sharing(shared);
    isolation(none);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    callback_abi(native, "c");
    representation(fixture, "closure");
    outcome handled {
      when(returned, any);
      meaning(success);
    }
  }
```

`callback_abi` and `representation` describe how this callable value can cross
the boundary ([A2](profiles.md#a2)). The callback returns `unit`, so the
successful outcome has no result value needing a `state` clause.

Now place that Handler in the registration function's parameter `handler`.
The inner `callback $handler` block describes how the API may invoke this
particular registration. It selects an existing parameter; the declaration
above introduced its type and signature.

Fragment — shows the registration schedule and destructor precondition. The
complete [callbacks package](examples/callbacks.ail) supplies the header,
Handler declaration, `Subscription` with `lifecycle(unique, @unsubscribe)`,
input retention, outcomes, effects, access and publication clauses.

<!-- ail-example: examples/rule-reading/contracts.ail region=callback-use -->
```ail
package example::callbacks version "1" {
  fn subscribe(handler: Handler) -> Subscription {
    callback $handler {
      timing(after_return);
      count(0, many);
      scope(owner($result));
      executor(any);
      concurrency(serial);
      reentrancy(forbidden);
      quiescence(@unsubscribe);
    }
    // Input retention, effects, owned result outcome and access omitted.
  }
  fn unsubscribe(subscription: Subscription) -> unit {
    input($subscription, consume);
    retain($subscription, none);
    requires(outside_callback(@subscribe::handler));
    // Effects, successful returned outcome and access omitted.
  }
  // Header, Handler, Subscription lifetime and publication context omitted.
}
```

`after_return` allows invocation starts after registration returns.
`count(0, many)` allows zero or more invocations over the registration's scope;
it promises neither a delivery nor eventual scope end. `scope(owner($result))`
connects that scope to the returned Subscription. The input retention shown in
[C3](#c3) uses the same owner. `executor(any)`, `concurrency(serial)` and
`reentrancy(forbidden)` specify entry location, independent overlap and nested
invocation separately ([C6](#c6)).

When `unsubscribe` returns, `quiescence(@unsubscribe)` promises that no invocation
is running or can begin, including on another thread. This state is
[quiescence](glossary.md#quiescence). The
`outside_callback(@subscribe::handler)` precondition keeps callers from entering
this blocking destructor inside the callback it needs to finish. The `@` reference
identifies the registration's parameter slot; `$handler` in the inner block
addresses it locally. A callback field would use its full place, for example
`callback $options.handler`, when the enclosing signature declares that record
and its callback field ([C1](#c1), [C6](#c6)).

A registration that invokes callbacks only during its call uses
`timing(during_call)`, `scope(call)`, `retain($handler, none)` and
`quiescence(return)` together. Those callbacks finish before the registration
completes. The owner-scoped example above instead keeps a retained callback
until destruction. The effects of `subscribe` itself remain synchronous in
both cases; later callback delivery is described by the callback-use block.
See [Callbacks](explanation/contracts.md#callbacks).

Use this comparison to keep the two occurrences of `callback` attached to
their own subjects:

| Example above | Subject | What the body describes |
|---|---|---|
| `callback Handler(value: u64) -> unit` | The Handler type | One Handler invocation and the callable value |
| `callback $handler` inside `subscribe` | The supplied `handler` value | The schedule for this registration's handler |

C6 checks retention, owner scope and quiescence together. The
[callback timing explanation](explanation/contracts.md#callbacks) shows when
invocations may run and what teardown promises. The
[callable grammar](reference/notation.md#callable) describes declarations such
as Handler; the [callback-use grammar](reference/notation.md#callback-use)
describes schedule blocks attached to a callable-local place.

</blockquote>
<!-- /reading-aid -->

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

<a id="c7"></a>

## C7. Global storage

<!-- reading-aid: c7-storage -->
<blockquote>

<a id="reading-aid-non-normative-describe-the-value-a-global-read-supplies"></a>

**Reading aid (non-normative): describe the value a global read supplies**

C7 describes persistent global storage among [Entities that outlive a call](explanation/model.md#entities),
so a reader can identify the storage being read and the obligations attached
to its loaded value.

A global declaration describes accessible storage. In the synthetic Counter
package, `pointer_value` stores a pointer to four bytes that remain usable
until provider unload. Reading the global supplies a borrowed pointer.

Fragment — shows the global from the complete [objects package](examples/objects.ail).
The package supplies `fixture`, `native`, the `test` environment and publication
clauses. F1 is an abstract test provider, not a host ABI.

<!-- ail-example: examples/objects.ail lines=106-122 -->
```ail
  global pointer_value: ptr<u8> {
    available([test]);
    deprecated(no);
    mutable(false);
    sharing(shared);
    isolation(none);
    extent($result, buffer(4, 4, elements));
    contents($result, binary);
    give($result, borrow(static));
    invalidated_by($result, []);
    access direct in [test] {
      abi(native, "c");
      via(fixture, "load", "fixture_pointer_value");
      mapping(identity);
      compatibility(stable);
    }
  }
```

Here `$result` denotes the value loaded by a read. `give` and `invalidated_by`
attach directly to the declaration, without an `outcome` block.
`borrow(static)` bounds use by the provider instance's lifetime; the empty
invalidation list states no earlier endpoint. `mutable(false)` describes the
global storage. The `load` access mechanism fetches its stored pointer
([C7](#c7), [A3](profiles.md#a3)).

A pointer-valued constant uses the same output clauses. For a literal scalar
constant, [L5's declaration example](language.md#l5) instead shows `literal(16)`
without ownership clauses. Core mutable scalar storage uses `mutable(true)`
with `sharing(confined)` and a non-`none` isolation such as `main`; a mutable
reference global requires a provider contract or explicit accessor operations.
The [global storage rule](#c7) below defines that boundary, and the
[region glossary entry](glossary.md#region) explains the lifetime vocabulary.

</blockquote>
<!-- /reading-aid -->

A global requires `sharing`, `isolation`, `extent`/`contents` if pointer-typed,
and `give`/`invalidated_by` directly in its body if its loaded value is a borrowed
reference. Core globals permit scalar/value storage or `give($result, borrow(static))`
with no earlier invalidators. Mutable reference globals and ownership-changing
reads/writes need a profile or explicit accessor functions. Core mutable value
globals require `sharing(confined)` and non-`none` isolation; atomics require a
profile. Constants with access paths obey the same output rules, are immutable,
and have no mutation contract. Literal scalar constants need no ownership clauses.

<a id="c8"></a>

## C8. Obligation checking

<!-- reading-aid: c8-checking -->
<blockquote>

<a id="reading-aid-non-normative-check-a-stated-fact-against-its-rule"></a>

**Reading aid (non-normative): check a stated fact against its rule**

C8 sets the agreement among [Writers, checkers and users](explanation/model.md#agreement),
so they can distinguish a consistent description from evidence about the
implementation and restrictions imposed by a binding.

A tool can check whether the description is internally consistent before a
binding generator decides how to use it. For example, the Store view declares
its initialized length and allocated capacity. A length greater than capacity
contradicts the extent rule ([C4](#c4), [C8](#c8)).

Invalid fragment — rejected under [C4](#c4): length 17 exceeds capacity 16.
This changes only the extent shown in the valid `view` example; omitted
contracts and package context do not remove that contradiction.

<!-- ail-example: examples/rule-reading/contracts.ail region=invalid-extent -->
```ail
package example::buffers version "1" {
  fn view(store: Store) -> ptr<u8> {
    extent($result, buffer(17, 16, elements));
    // All other clauses omitted to isolate the impossible extent.
  }
  // Header, Store lifetime and publication context omitted.
}
```

A missing `extent` would leave a required fact unstated. A made-up
`extent($result, guessed)` would use unknown vocabulary. Both also fail the
checks required by C8. A conforming validator reports those failures instead
of supplying an invented bound. Conversely, a coherent `buffer(16, 16, elements)`
still needs the actual API to honour the promise. Language checking and
implementation testing establish different things.

A generator may impose a stricter rule on its users, such as forbidding all
nested calls even where the API permits them. It identifies that extra rule
as its own restriction and retains the API's `reentrancy(allowed)` fact
([A5](profiles.md#a5)). See [Validation](glossary.md#validation) and the
[conformance record](conformance.md) for the distinction between specification
checks and an implemented validator.

</blockquote>
<!-- /reading-aid -->

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
