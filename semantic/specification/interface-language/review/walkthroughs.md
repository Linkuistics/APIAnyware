# Reading the conformance examples

> **Purpose:** review guide — trace the facts a caller or tool needs through three AIL packages.
> **Reader:** language designers who have read the orientation and want to inspect concrete contracts.
> **Before this:** [Using an API across languages](../explanation/unsaid.md) and [the API model](../explanation/model.md); consult [the glossary](../glossary.md) as needed.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [L1–L6](../language.md#l1), [C1–C8](../contracts.md#c1), [A1–A5 and F1](../profiles.md#a1) are canonical. These readings are non-normative.

Choose the question you want to follow:

- [Buffers](#buffers): who releases a store, and which bytes can a caller read?
- [Callbacks](#callbacks): when can notifications arrive, and when can callback state be released?
- [Objects](#objects): which calls belong to an object, and how does a tool reach its code and data?

Each section reads every declaration in its linked package. The paragraphs
beside each extract group clauses by the [API model's concepts](../explanation/model.md#from-the-model-to-ail).
A fragment preserves the source text but relies on the rest of its package.
The final questions ask you to recover a fact, then judge how AIL expresses it.
Expected observations follow the questions so you can try them first.

All three APIs are invented. Their `fixture` profile and `native` ABI entry
come from the [synthetic catalogue F1](../profiles.md#f1). The repeated `a`
and `b` digest pins are test resolution tokens, usable only in fixture mode;
they make no claim about an installed library or a real operating-system ABI.
The [conformance record](../conformance.md#verification-record) describes
historical checks. Here, you inspect descriptions and permitted behaviour;
there is no implementation to run.

<a id="buffers"></a>

## Buffers: ownership, views and output states

The invented store owns sixteen immutable bytes. Its caller can obtain a
view into those bytes or copy them into caller-supplied storage. Use this
example to separate [Release responsibility](../explanation/model.md#responsibility)
from [Validity](../explanation/model.md#validity): owning the store brings a
destruction duty, while receiving a view brings a limit on how long the bytes
may be used. Copying introduces a further question: whether the destination
contains readable output when the call fails.

Complete source: [`buffers.ail`](../examples/buffers.ail).

### Package and environment

[The published description](../explanation/model.md#description) tells a tool
which API and configuration these obligations describe. All declarations below
belong to `example::buffers`, version `1`.

Fragment — the package opening. The [complete package](../examples/buffers.ail)
also supplies the declarations read below and the closing package boundary.

<!-- ail-example: ../examples/buffers.ail lines=1-10 -->
```ail
language "0.1";
package example::buffers version "1" {
  surface("A synthetic immutable sixteen-byte store and its complete lifetime API.");
  exports([@Store, @create, @destroy, @view, @copy_bytes, @store_lifetime]);
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
```

**[The published description](../explanation/model.md#description).**
`language "0.1"` selects this draft. The package name and version contribute
to each declaration's identity. `surface` claims the immutable store and its
complete lifetime API; `exports` lists its public roots. `store_lifetime` is
public, and its supporting `lifetime` pattern remains in the package's
dependency closure. The local environment `test` names exactly target
`fixture64` and platform `fixture`, version `1`; it does not describe a range
of platforms ([L1–L3](../language.md#l1)).

**[Reaching the code](../explanation/model.md#access).**
`use profile fixture` selects the versioned definitions of mechanisms such as
`symbol`. `use abi native` separately selects the calling conventions and
representations. The pins select F1's fixture definitions. These catalogue
aliases are distinct from imported API declarations: this package has no
`import` clause ([L2](../language.md#l2), [A1](../profiles.md#a1),
[F1](../profiles.md#f1)). Exact syntax: [package shells](../reference/notation.md#shell)
and [provider dependencies](../reference/notation.md#dependency).

### Store: one destruction duty

[Entities that outlive a call](../explanation/model.md#entities) lets a caller
identify what persists between operations. `Store` is the local opaque
resource type that the functions use; its contents have no dereferenceable
layout in this declaration ([L4](../language.md#l4)).

Fragment — `Store` in `example::buffers`. The [complete package](../examples/buffers.ail)
also supplies its destructor, operations and publication context.

<!-- ail-example: ../examples/buffers.ail lines=11-19 -->
```ail
  resource Store {
    available([test]);
    deprecated(no);
    implements([]);
    lifecycle(unique, @destroy);
    sharing(transferable);
    isolation(none);
    doc("Owns sixteen immutable bytes. Moving sole ownership between executors is allowed.");
  }
```

**[Entities that outlive a call](../explanation/model.md#entities).**
`implements([])` records an empty interface-conformance list.
`lifecycle(unique, @destroy)` associates each owned handle with exactly one
destruction obligation, discharged by the local `destroy` function. Its
`doc` explains the immutable bytes and ownership movement; that prose
supplements the clauses ([L5](../language.md#l5), [C2](../contracts.md#c2)).

**[Where and when calls run](../explanation/model.md#execution).**
`sharing(transferable)` permits sole ownership to move across executors,
with no concurrent access. `isolation(none)` records no nominal executor
restriction. Each operation still has its own entry and overlap conditions
([C2](../contracts.md#c2)).

**[The published description](../explanation/model.md#description).**
`available([test])` places `Store` in the declared configuration;
`deprecated(no)` records that it is not deprecated. Those two clauses recur
on the package's public functions with the same meaning
([L3](../language.md#l3), [L5](../language.md#l5)).

### Create: a handle or a null failure

[Operations and their values](../explanation/model.md#operations) identifies
`create` as a function with no parameters and a nullable `Store` result.
To decide what to release, the caller also needs
[How a call finishes](../explanation/model.md#outcomes).

Fragment — `create` in `example::buffers`. The [complete package](../examples/buffers.ail)
also supplies `Store`, its destructor and the selected providers.

<!-- ail-example: ../examples/buffers.ail lines=20-48 -->
```ail
  fn create() -> nullable<Store> {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(parallel);
    reentrancy(allowed);
    mutation(none);
    variadic(false);
    outcome created {
      when(returned, nonnull($result));
      meaning(success);
      state($result, valid);
      give($result, owned);
    }
    outcome allocation_failed {
      when(returned, null($result));
      meaning(failure);
      state($result, valid);
      give($result, owned);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_store_create");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations).**
`nullable<Store>` admits a handle or null. `$result` addresses this
invocation's result slot. `variadic(false)` fixes the signature to its declared
parameters ([L4](../language.md#l4), [C1](../contracts.md#c1),
[C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` gives the sole completion mode. `created` selects
non-null and calls it success; `allocation_failed` selects null and calls it
failure. Both declare the result valid, so the caller may inspect it in
either case. The two predicates cover the nullable domain exactly. Failure
remains a returned null value ([C3](../contracts.md#c3), [C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility).**
`give($result, owned)` supplies one destruction obligation on a non-null
result. On the null outcome the same annotation creates no obligation: null
carries none ([C1](../contracts.md#c1), [C5](../contracts.md#c5)).

**[Where and when calls run](../explanation/model.md#execution).**
`execution(sync)` completes this invocation before control returns;
`executor(any)` permits entry on any executor. `concurrency(parallel)`
permits independent overlap, and `reentrancy(allowed)` permits nested
re-entry. These permissions carry no promise of eventual completion
([C3](../contracts.md#c3)).

**[Validity](../explanation/model.md#validity).**
`mutation(none)` records no change to externally visible input state. Creating
private storage is compatible with that promise ([C3](../contracts.md#c3)).

**[The published description](../explanation/model.md#description).**
`available([test])` and `deprecated(no)` apply the package's configuration
and advisory status to `create` ([L3](../language.md#l3), [L5](../language.md#l5)).

**[Reaching the code](../explanation/model.md#access).**
The `direct` path applies in `test`. `abi(native, "c")` selects a convention
within the ABI entry; `via` names `fixture_store_create` as a function symbol.
`mapping(identity)` requires faithful lowering of the whole signature and
contract. `compatibility(stable)` uses the ABI entry's guaranteed fixture
domain ([A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

### Destroy: transfer the obligation at entry

[Release responsibility](../explanation/model.md#responsibility) answers when
the caller gives up its duty. `destroy` receives the owned handle and takes
that duty as the call begins.

Fragment — `destroy` in `example::buffers`. The [complete package](../examples/buffers.ail)
also supplies `Store`'s lifecycle and the paths that create and borrow it.

<!-- ail-example: ../examples/buffers.ail lines=49-71 -->
```ail
  fn destroy(store: Store) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    input($store, consume);
    retain($store, none);
    outcome done {
      when(returned, any);
      meaning(success);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_store_destroy");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations).**
The parameter `store` has the non-null local type `Store`; `unit` supplies no
result value. `variadic(false)` keeps this a one-parameter call
([L4](../language.md#l4), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` and `done` describe one successful returned case,
selected by `when(returned, any)`. A unit result needs no `state` clause
([C2](../contracts.md#c2), [C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility).**
`input($store, consume)` transfers the owned obligation at entry.
`retain($store, none)` promises no retention. The caller supplies a valid
owned handle at entry; the declared unique destructor discharges its duty
([C2–C3](../contracts.md#c2)).

**[Validity](../explanation/model.md#validity).**
Destroying the owner ends its dependent borrows before this function returns.
`mutation(none)` remains correct: destruction and borrow ending follow
transfer and lifecycle, while mutation classifies changes to live contents
([C2–C3](../contracts.md#c2)).

**[Where and when calls run](../explanation/model.md#execution).**
The call is synchronous and may enter on any executor. `concurrency(serial)`
requires callers to avoid independent overlap using the same resource;
`reentrancy(forbidden)` also forbids nested entry on that resource
([C3](../contracts.md#c3)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
`available([test])` and `deprecated(no)` give the local availability and
status. The `direct` access in `test` uses `native`'s `c` convention and the
fixture symbol `fixture_store_destroy`; `mapping(identity)` preserves this
contract, and `compatibility(stable)` uses the fixture ABI domain
([L3](../language.md#l3), [L5](../language.md#l5), [A2–A4](../profiles.md#a2),
[F1](../profiles.md#f1)).

### View: borrow bytes while their owner lives

[Validity](../explanation/model.md#validity) connects two durations here:
the input handle must stay usable during `view`, and the returned bytes may
be used while their store remains alive. The latter duration is what makes
the result useful after the function returns.

Fragment — `view` in `example::buffers`. The [complete package](../examples/buffers.ail)
also supplies the owner's lifecycle and all operations on the store.

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

**[Operations and their values](../explanation/model.md#operations).**
`view` accepts a non-null `Store` and returns a non-null pointer to readable
`u8` storage. `variadic(false)` fixes the parameter list. The pointer's
ownership and size come from the clauses below ([L4](../language.md#l4),
[C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` has one exhaustive outcome, `viewed`:
`when(returned, any)` is successful and `state($result, valid)` makes the
pointer usable ([C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility).**
`input($store, borrow)` leaves the store's duty with its caller.
`retain($store, none)` promises no stored reference. The result's
`give(..., borrow(...))` likewise gives the caller access without a release
duty for the pointer ([C3](../contracts.md#c3), [C5](../contracts.md#c5)).

**[Validity](../explanation/model.md#validity).**
`valid($store, call)` requires the input to remain valid through the call.
`owner($store)` bounds the returned borrow by the store's lifetime;
`invalidated_by($result, [])` records no earlier invalidating operations.
`mutation(none)` agrees with this immutable API. The empty list leaves the
owner-lifetime bound in force ([C1](../contracts.md#c1),
[C3](../contracts.md#c3), [C5](../contracts.md#c5)).

**[Storage](../explanation/model.md#storage).**
`buffer(16, 16, elements)` supplies sixteen initialized `u8` elements in
capacity for sixteen. `contents($result, binary)` gives raw bytes without a
text terminator ([C4](../contracts.md#c4)).

**[Where and when calls run](../explanation/model.md#execution).**
`execution(sync)` and `executor(any)` permit synchronous entry anywhere.
`concurrency(serial)` prevents independent overlap on the same store;
`reentrancy(allowed)` separately permits nested re-entry
([C3](../contracts.md#c3)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
`view` is available in `test` and not deprecated. Its `direct` path applies
there, selects the `native` ABI's `c` convention, and calls
`fixture_store_view` through `fixture`'s `symbol` mechanism. The identity
mapping preserves this whole contract within the stable fixture domain
([L3](../language.md#l3), [L5](../language.md#l5), [A2–A4](../profiles.md#a2),
[F1](../profiles.md#f1)).

For exact notation, see [places](../reference/notation.md#places) and
[outcomes](../reference/notation.md#outcome). For the lifetime relationship,
see [the owner-borrow view](../explanation/contracts.md#how-long-a-borrow-lasts).

### Copy bytes: readable output depends on success

[Storage](../explanation/model.md#storage) tells the caller what to allocate;
[How a call finishes](../explanation/model.md#outcomes) tells it whether to
read the result. `copy_bytes` writes into the caller's destination, so its
output-state clauses matter even though the function returns only a Boolean.

Fragment — `copy_bytes` in `example::buffers`. The [complete package](../examples/buffers.ail)
also supplies `Store`, its lifetime and the selected providers.

<!-- ail-example: ../examples/buffers.ail lines=101-139 -->
```ail
  fn copy_bytes(store: Store, destination: mutptr<u8>) -> bool {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(allowed);
    mutation(arguments);
    variadic(false);
    input($store, borrow);
    retain($store, none);
    valid($store, call);
    input($destination, borrow);
    retain($destination, none);
    valid($destination, call);
    direction($destination, out);
    aliasing($destination, disjoint);
    extent($destination, buffer(16, 16, elements));
    contents($destination, binary);
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
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_store_copy");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations).**
`store` names the resource input; `destination` is a non-null pointer to
writable `u8` storage. The result is a `bool`, and `variadic(false)` fixes the
two parameters. `$destination[]` selects the buffer's initialized elements,
whereas `$destination` selects the pointer itself
([L4](../language.md#l4), [C1](../contracts.md#c1), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
The returned completion splits into `copied` for `true` and `failed` for
`false`. Both make `$result` valid, so the caller can always test the status.
On success the destination elements are valid; on failure they are invalid
and convey no readable initialized output. Failure therefore supplies no
permission to inspect the bytes, even if their addresses remain accessible
([C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
For both `store` and `destination`, `input(..., borrow)` transfers no duty,
`retain(..., none)` promises no retention, and `valid(..., call)` requires
validity through completion. `mutation(arguments)` permits the output write.
The caller continues to manage its destination allocation; this call creates
no owner-dependent borrow into the store ([C3](../contracts.md#c3)).

**[Storage](../explanation/model.md#storage).**
`direction($destination, out)` permits writing without reading prior
contents. `aliasing(..., disjoint)` forbids overlap with other accessed memory
in this call, including the store's bytes. The caller supplies allocated,
aligned space for sixteen elements. The `buffer(16, 16, elements)` length
becomes initialized output on success; an `out` buffer needs no initialized
contents at entry. `contents(..., binary)` requires no text terminator
([C3–C4](../contracts.md#c3)).

**[Where and when calls run](../explanation/model.md#execution).**
The function is synchronous, allows entry on any executor, requires serial
independent uses of the same resource or mutable storage, and permits nested
re-entry. The buffer and aliasing conditions still apply
([C3](../contracts.md#c3)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
Availability is `test`, with no deprecation. `direct` applies in that
environment: convention `c`, symbol `fixture_store_copy`, faithful identity
mapping and stable fixture-domain compatibility. The different access
spelling leaves the declaration's name `copy_bytes` unchanged
([L2–L3](../language.md#l2), [L5](../language.md#l5), [A2–A4](../profiles.md#a2),
[F1](../profiles.md#f1)).

### Lifetime pattern: connect a type to its release operation

[Entities that outlive a call](../explanation/model.md#entities) also includes
relationships between declarations. The pattern describes a kind of
relationship; the instance selects its participants.

Fragment — `lifetime` and `store_lifetime` in `example::buffers`. The
[complete package](../examples/buffers.ail) also supplies the participants and
exports the instance.

<!-- ail-example: ../examples/buffers.ail lines=140-148 -->
```ail
  pattern lifetime {
    role resource_type: type one;
    role release: operation one;
    law(releases, release, resource_type);
  }
  instance store_lifetime: lifetime {
    bind(resource_type, [@Store]);
    bind(release, [@destroy]);
  }
```

**[Entities that outlive a call](../explanation/model.md#entities).**
`resource_type: type one` requires exactly one type participant;
`release: operation one` requires exactly one operation. The
`law(releases, release, resource_type)` requires that operation to be the
resource's declared unique destructor. `store_lifetime` binds the roles to
local `@Store` and `@destroy`. Both participants apply in `test`, giving the
instance a nonempty common availability. The pattern records a checked
relationship already supported by `Store`'s lifecycle; it does not invent a
new release function ([L6](../language.md#l6)).

Exact syntax: [patterns and instances](../reference/notation.md#pattern).

### Plain-language view of the buffer API

Creation returns either an owned store or a null failure. An owned store has
one destruction duty. `view` lends access to its sixteen immutable bytes;
the caller keeps the store alive while reading that view. `copy_bytes`
requires separate writable space and tells the caller, through its Boolean
result, whether that space contains readable output. Destruction consumes
the handle and ends views into its storage. Independent uses of a store are
serialized, even though its ownership may move between executors
([C2–C5](../contracts.md#c2)).

### Trace the buffer obligations

Using the extracts above or [the complete package](../examples/buffers.ail):

1. **Release responsibility:** after `create` returns null, identify any
   remaining release duty. Explain why both outcomes contain `give(owned)`.
2. **Validity:** follow `view`'s result through a later `destroy` call.
   Identify the boundary that ends the borrow when the invalidator list is empty.
3. **Storage and outcomes:** suppose `copy_bytes` returns `false`. Identify
   what the caller may inspect, then compare the `true` outcome.
4. **The published description:** classify `Store`, `destroy`, `fixture`
   and `native` as local declarations, imports or catalogue aliases.
   Find the rule that would govern a declaration imported under an alias.

**Expected observations**

1. Null carries no obligation. A non-null result gives the caller one
   `Store` destruction duty; the nullable annotation is conditional on
   non-null ([C1](../contracts.md#c1), [C5](../contracts.md#c5)).
2. `owner($store)` ends at owner destruction. The unique destructor
   invalidates dependent borrows before returning; the empty list only
   excludes earlier invalidating operations ([C1–C2](../contracts.md#c1),
   [C5](../contracts.md#c5)).
3. The Boolean is valid in both cases. Only `true` makes the sixteen
   destination elements valid. `false` supplies no readable output elements
   ([C4–C5](../contracts.md#c4)).
4. `Store` and `destroy` are local declarations. `fixture` and `native`
   select profile and ABI catalogues. There is no API import here; the
   [two-package example](../language.md#l2) shows a local `Canvas` and an
   imported `Geometry::Point`. L2 preserves the latter's identity in its
   defining package ([L2](../language.md#l2)).

**Review prompt:** In `view` and `copy_bytes`, which facts about the caller's
next legal action were hard to find? Cite the clauses and the relevant
[C1–C5 rule](../contracts.md#c1). Propose a clearer grouping or notation if
these declarations make that decision unnecessarily difficult.

<a id="callbacks"></a>

## Callbacks: registration, invocation and teardown

[Callbacks and their schedules](../explanation/model.md#callbacks) asks when
a supplied function may run and how long its saved state must remain usable.
This package describes integer notifications attached to a uniquely owned
subscription. Read the callback type for one invocation, then `subscribe` for
the schedule of those invocations.

Complete source: [`callbacks.ail`](../examples/callbacks.ail).
The API and providers are synthetic; F1's closure representation supplies
retention and release, with no separately visible context argument.

### Package and environment

[The published description](../explanation/model.md#description) bounds the
review to this notification API and its single fixture configuration.

Fragment — the package opening. The [complete package](../examples/callbacks.ail)
also supplies the four exported declarations and the closing boundary.

<!-- ail-example: ../examples/callbacks.ail lines=1-10 -->
```ail
language "0.1";
package example::callbacks version "1" {
  surface("A synthetic subscription delivering integer notifications until quiescent destruction.");
  exports([@Subscription, @Handler, @subscribe, @unsubscribe]);
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
```

**[The published description](../explanation/model.md#description).**
The header selects `0.1`; `example::callbacks`, version `1`, owns
`Subscription`, `Handler`, `subscribe` and `unsubscribe`. `surface` states the
notification API through quiescent destruction, and `exports` lists those
four public roots. `test` selects target `fixture64` and platform `fixture`,
version `1` ([L1–L3](../language.md#l1)).

**[Reaching the code](../explanation/model.md#access).**
`fixture` and `native` pin the synthetic profile and ABI entry at version
`1`. Their `a` and `b` tokens select F1's test catalogue. They supply access
and representation definitions; they import no API declarations
([L2](../language.md#l2), [A1](../profiles.md#a1), [F1](../profiles.md#f1)).

### Subscription: the owner of a registration

[Entities that outlive a call](../explanation/model.md#entities) gives the
registration a lifetime that persists after `subscribe` returns.

Fragment — `Subscription` in `example::callbacks`. The
[complete package](../examples/callbacks.ail) also supplies registration,
callback and destructor contracts.

<!-- ail-example: ../examples/callbacks.ail lines=11-18 -->
```ail
  resource Subscription {
    available([test]);
    deprecated(no);
    implements([]);
    lifecycle(unique, @unsubscribe);
    sharing(transferable);
    isolation(none);
  }
```

**[Entities that outlive a call](../explanation/model.md#entities).**
`Subscription` is an opaque resource. `implements([])` declares no interface
conformance. `lifecycle(unique, @unsubscribe)` attaches one destruction duty
to each owned handle and names its local destructor
([L4–L5](../language.md#l4), [C2](../contracts.md#c2)).

**[Where and when calls run](../explanation/model.md#execution).**
`sharing(transferable)` permits sole ownership to move between executors,
without concurrent access. `isolation(none)` gives it no nominal executor
restriction ([C2](../contracts.md#c2)).

**[The published description](../explanation/model.md#description).**
The resource is `available([test])` and `deprecated(no)`; these same two
clauses recur on the other public declarations
([L3](../language.md#l3), [L5](../language.md#l5)).

### Handler: one callback invocation

[Operations and their values](../explanation/model.md#operations) describes
what one notification delivers. The API invokes a supplied `Handler` with
an unsigned 64-bit integer and receives no result value.

Fragment — `Handler` in `example::callbacks`. The
[complete package](../examples/callbacks.ail) supplies the registration schedule
separately in `subscribe`.

<!-- ail-example: ../examples/callbacks.ail lines=19-37 -->
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

**[Operations and their values](../explanation/model.md#operations).**
`value: u64` is passed by value and needs no input ownership clause.
`unit` gives no result value; `variadic(false)` fixes this one-parameter
signature ([L4](../language.md#l4), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` and `handled` give one successful returned case,
selected by `when(returned, any)`. There is no result value requiring
`state` ([C5](../contracts.md#c5)).

**[Validity](../explanation/model.md#validity).**
`mutation(none)` promises no change to externally visible input state.
It describes the invocation's inputs, rather than private implementation
state ([C3](../contracts.md#c3)).

**[Where and when calls run](../explanation/model.md#execution).**
`sharing(shared)` and `isolation(none)` govern the callback value and all its
captures: they must permit references to cross executors. Invocation has its
own synchronous execution, `executor(any)`, serial independent concurrency
and forbidden nested re-entry. Shared captures therefore do not establish
permission for overlapping invocations ([C2–C3](../contracts.md#c2)).

**[The published description](../explanation/model.md#description).**
`Handler` is available in `test` and not deprecated
([L3](../language.md#l3), [L5](../language.md#l5)).

**[Reaching the code](../explanation/model.md#access).**
`callback_abi(native, "c")` selects callback entry rules.
`representation(fixture, "closure")` selects F1's stored callback form,
including strong retain/release support and its captured environment.
Callbacks use these clauses where functions have `access` blocks
([A2](../profiles.md#a2), [F1](../profiles.md#f1)).

### Subscribe: retain the handler for a returned owner

[Callbacks and their schedules](../explanation/model.md#callbacks) answers
the question the callback signature leaves open: when this registration may
invoke the handler and how those uses end.

Fragment — `subscribe` in `example::callbacks`. The
[complete package](../examples/callbacks.ail) also defines `Handler`,
`Subscription` and its destructor.

<!-- ail-example: ../examples/callbacks.ail lines=38-72 -->
```ail
  fn subscribe(handler: Handler) -> Subscription {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
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
    outcome registered {
      when(returned, any);
      meaning(success);
      state($result, valid);
      give($result, owned);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_subscribe");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations).**
The function accepts a non-null `Handler` and returns a non-null
`Subscription`. `variadic(false)` fixes the signature
([L4](../language.md#l4), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` has one `registered` outcome. `when(returned, any)`
covers that completion, `meaning(success)` labels it, and
`state($result, valid)` establishes the returned owner
([C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility).**
`input($handler, borrow)` takes no ownership duty from the caller.
`retain($handler, strong(owner($result)))` creates a separate retained
reference for the subscription's lifetime. `give($result, owned)` gives the
caller one subscription destruction duty ([C2–C3](../contracts.md#c2),
[C5](../contracts.md#c5)).

**[Validity](../explanation/model.md#validity).**
`valid($handler, call)` requires the caller's input to be valid through
registration. The independent retained reference supports later uses.
`mutation(none)` permits the retention: reference-count increments are
outside its classification of changes to live input contents
([C3](../contracts.md#c3)).

**[Where and when calls run](../explanation/model.md#execution).**
The registration call itself is synchronous, permits entry on any executor,
requires serial independent calls over the same resource or mutable storage,
and forbids nested re-entry. Later notifications are described separately;
they do not make this operation `execution(async)`
([C3](../contracts.md#c3), [F1](../profiles.md#f1)).

**[Callbacks and their schedules](../explanation/model.md#callbacks).**
Inside `callback $handler`, `timing(after_return)` allows invocation starts
only after registration's returned completion. `count(0, many)` permits zero
or more invocations over the registration's scope, conditional on eventual
scope end. It offers no notification-delivery promise. `scope(owner($result))`
ties the schedule to the returned subscription, matching the retention region
([C6](../contracts.md#c6)).

The block's `executor(any)`, `concurrency(serial)` and
`reentrancy(forbidden)` govern entries of this registration: they may use any
executor but may neither overlap independently nor nest within an earlier
invocation. `Handler`'s declaration also governs uses across registrations.
`quiescence(@unsubscribe)` promises that when the owner's destructor returns,
no invocation is running or can begin, including on another thread. None of
these clauses guarantees that teardown eventually returns
([C3](../contracts.md#c3), [C6](../contracts.md#c6)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
The function is available in `test` and not deprecated. The `direct` path in
`test` selects `native`'s `c` convention, the symbol `fixture_subscribe`,
identity mapping and stable fixture-domain compatibility
([L3](../language.md#l3), [L5](../language.md#l5), [A2–A4](../profiles.md#a2),
[F1](../profiles.md#f1)).

Exact syntax: [callback-use blocks](../reference/notation.md#callback-use).
The [callback schedule comparison](../explanation/contracts.md#callbacks)
shows the difference between call-scoped work and this owner-scoped schedule.

### Unsubscribe: wait for quiescence outside the callback

[Callbacks and their schedules](../explanation/model.md#callbacks) supplies
the safe teardown boundary. The caller invokes this destructor from outside
an invocation of the registration it is stopping.

Fragment — `unsubscribe` in `example::callbacks`. The
[complete package](../examples/callbacks.ail) also supplies `Subscription`'s
lifecycle and `subscribe`'s callback use.

<!-- ail-example: ../examples/callbacks.ail lines=73-97 -->
```ail
  fn unsubscribe(subscription: Subscription) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    input($subscription, consume);
    retain($subscription, none);
    requires(outside_callback(@subscribe::handler));
    outcome stopped {
      when(returned, any);
      meaning(success);
      doc("No callback is running or can start after this completion.");
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_unsubscribe");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations)** and
**[How a call finishes](../explanation/model.md#outcomes).**
The function takes a non-null `Subscription` and returns `unit`, with no
variadic arguments. The sole completion mode is `returned`; `stopped` covers
it with `when(returned, any)` and `meaning(success)`. A unit result needs no
output state ([L4](../language.md#l4), [C3](../contracts.md#c3),
[C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
`input($subscription, consume)` transfers the destruction duty at entry;
`retain(..., none)` promises no retention. `mutation(none)` is compatible
with destruction, whose effects follow the unique lifecycle
([C2–C3](../contracts.md#c2)).

**[Where and when calls run](../explanation/model.md#execution).**
`execution(sync)` waits for completion before returning control.
`executor(any)` permits entry anywhere; `concurrency(serial)` and
`reentrancy(forbidden)` restrict independent overlap and nested entry
([C3](../contracts.md#c3)).

**[Callbacks and their schedules](../explanation/model.md#callbacks).**
`requires(outside_callback(@subscribe::handler))` names the `handler`
parameter slot of the local `subscribe` operation. It forbids this teardown
from within an invocation of that callback use, avoiding a blocking
destructor waiting for the callback that invoked it. The `stopped` outcome's
`doc` explains the quiescence guarantee; the enforcing relationship is
`subscribe`'s `quiescence(@unsubscribe)` together with the lifecycle
([L2](../language.md#l2), [L5](../language.md#l5),
[C3](../contracts.md#c3), [C6](../contracts.md#c6)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
The declaration is available in `test` and not deprecated. `direct` uses the
`c` convention and `fixture_unsubscribe` symbol in `test`, with identity
mapping and stable fixture-domain compatibility
([L3](../language.md#l3), [L5](../language.md#l5), [A2–A4](../profiles.md#a2),
[F1](../profiles.md#f1)).

### Plain-language view of the callback API

The caller supplies a handler whose captures permit the declared uses.
Registration borrows that handler and retains a separate reference, then
returns an owned subscription. Notifications may start after registration
returns, including before the caller performs its next action. There may be
none or many. The caller eventually discharges its subscription duty through
`unsubscribe`, outside its callback invocation. Once that call returns, no
callback remains active or can start; the provider releases the stored
callback representation under its lifetime rules
([C2–C3](../contracts.md#c2), [C6](../contracts.md#c6), [F1](../profiles.md#f1)).

### Trace the callback obligations

Using [the registration and teardown above](#subscribe-retain-the-handler-for-a-returned-owner):

1. **Callbacks and their schedules:** locate the earliest permitted
   notification start. Decide whether a registration that receives no
   notifications before destruction violates the count.
2. **Release responsibility:** explain how `input(borrow)` and
   `retain(strong(owner($result)))` can both be true. Identify what the
   caller owns after registration returns.
3. **Callbacks and their schedules:** follow an `unsubscribe` call made
   from the handler it would stop. Identify the relevant precondition and
   the boundary at which callback state is no longer in use.
4. **Operations and their values:** compare `@subscribe::handler` in
   `unsubscribe` with `$handler` in `subscribe`. Locate each reference's
   declaration and parameter; then find the callback invocation's own `value` slot.

**Expected observations**

1. Starts occur after returned completion of `subscribe`; zero is permitted
   by `count(0, many)`. The count supplies no eventual-delivery guarantee
   ([C6](../contracts.md#c6)).
2. Borrowing transfers no existing duty. Strong retention creates an
   independent reference scoped to the returned owner. The caller receives
   one owned `Subscription` with an `unsubscribe` duty
   ([C2–C3](../contracts.md#c2), [C5](../contracts.md#c5)).
3. Such a call violates `outside_callback`. Quiescence is promised at
   destructor return, so merely starting teardown does not establish that
   every active invocation has finished ([C3](../contracts.md#c3),
   [C6](../contracts.md#c6)).
4. The `@` reference addresses another declaration's parameter; the `$`
   place addresses the enclosing invocation's parameter. `Handler` has its
   own `value` parameter, addressable externally as `@Handler::value`
   ([L2](../language.md#l2), [C1](../contracts.md#c1)).

**Review prompt:** To establish when captures can be released, you followed
`Handler`, `subscribe`, `Subscription` and `unsubscribe`. Which relationships
in [C2](../contracts.md#c2) and [C6](../contracts.md#c6) deserve separate
clauses, and which would you express together? Cite any step where the
notation obscured the lifetime or suggested a stronger delivery promise.

<a id="objects"></a>

## Objects: members, properties and alternative access paths

[Entities that outlive a call](../explanation/model.md#entities) includes
objects supplied by a host and their associated operations. This package
uses a reference-counted `Counter` with a mutable count. It also gives a tool
two ways to call its getter and two different ways to obtain a pointer.
Use it to judge whether the description keeps those distinctions visible.

Complete source: [`objects.ail`](../examples/objects.ail).
The names `objc_like` and `swift_like` identify synthetic access alternatives;
they assert no real Objective-C or Swift interoperability.

### Package and environment

[The published description](../explanation/model.md#description) locates the
object, its members and the two data declarations in one package.

Fragment — the package opening. The [complete package](../examples/objects.ail)
also supplies the six exported declarations and its closing boundary.

<!-- ail-example: ../examples/objects.ail lines=1-11 -->
```ail
language "0.1";
package example::objects version "1" {
  surface("A synthetic reference-counted object, a custom property, and two faithful call paths.");
  exports([@Counter, @read_count, @write_count, @count, @fixed_bytes, @pointer_value]);
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  environment test {
    target("fixture64");
    platform("fixture", "1");
    toolchain("fixture-compiler", "1");
  }
```

**[The published description](../explanation/model.md#description).**
The header selects `0.1`; `example::objects`, version `1`, owns every
declaration below. `surface` states the object/property/access scope, and
`exports` lists the six public roots. `test` records the exact target and
platform plus `toolchain("fixture-compiler", "1")`, needed for the selected
source-build recipe ([L1–L3](../language.md#l1), [F1](../profiles.md#f1)).

**[Reaching the code](../explanation/model.md#access).**
`fixture` and `native` select the same versioned synthetic profile and ABI
catalogues as the preceding examples. Their pins remain fixture-only test
tokens. Both getter paths below use this one ABI entry, selecting different
conventions within it ([L2](../language.md#l2), [A1](../profiles.md#a1),
[F1](../profiles.md#f1)).

### Counter: reference counting on the main executor

[Entities that outlive a call](../explanation/model.md#entities) identifies
`Counter` as a host-supplied object. Its release protocol differs from the
unique resources in the earlier examples.

Fragment — `Counter` in `example::objects`. The [complete package](../examples/objects.ail)
also supplies its members, property and environment.

<!-- ail-example: ../examples/objects.ail lines=12-23 -->
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

**[Entities that outlive a call](../explanation/model.md#entities).**
`base(none)` declares no base object; `implements([])` declares no interfaces.
`lifecycle(refcounted, runtime(fixture, "retain"), runtime(fixture, "release"))`
uses the provider's primitives: each owned reference has a release duty,
and retaining creates another. F1 destroys the object at count zero. The
`doc` identifies host-supplied instances and their mutable count; this
package declares no creator ([L5](../language.md#l5), [C2](../contracts.md#c2),
[F1](../profiles.md#f1)).

**[Where and when calls run](../explanation/model.md#execution).**
`sharing(confined)` and `isolation(main)` restrict use to the main executor,
including retain, release and destruction. `fixture::sendability(nonconforming)`
records a separate synthetic compiler-conformance fact. It carries neither
an actual Swift compiler finding nor an exemption from confinement
([C2](../contracts.md#c2), [F1](../profiles.md#f1)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
`available([test])` and `deprecated(no)` establish the configuration and
status. `source(fixture, "Outer.Counter")` supplies an exact source identity
interpreted by the profile; the canonical local declaration name remains
`Counter`. This source spelling supplies no callable access path by itself
([L2–L3](../language.md#l2), [L5](../language.md#l5),
[A2](../profiles.md#a2), [F1](../profiles.md#f1)).

### Read count: one member, two ways to call it

[Operations and their values](../explanation/model.md#operations) lets a tool
find the getter's receiver and result. [Entities that outlive a call](../explanation/model.md#entities)
connects that operation to `Counter`: `read_count` is a top-level sibling
of the object declaration, associated with it by `member`.

Fragment — `read_count` in `example::objects`. The
[complete package](../examples/objects.ail) also supplies `Counter`, its
property, setter and provider dependencies.

<!-- ail-example: ../examples/objects.ail lines=24-56 -->
```ail
  fn read_count(receiver: Counter) -> u64 {
    available([test]);
    deprecated(no);
    member(@Counter, instance);
    receiver($receiver);
    execution(sync);
    completions([returned]);
    executor(main);
    concurrency(serial);
    reentrancy(allowed);
    mutation(none);
    variadic(false);
    input($receiver, borrow);
    retain($receiver, none);
    valid($receiver, call);
    outcome read {
      when(returned, any);
      meaning(success);
      state($result, valid);
    }
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "currentCount");
      mapping(identity);
      compatibility(stable);
    }
    access swift_like in [test] {
      abi(native, "source");
      via(fixture, "source-call", "Outer.Counter.currentCount.get");
      mapping(identity);
      compatibility(source, "fixture-build");
    }
  }
```

**[Operations and their values](../explanation/model.md#operations)** and
**[Entities that outlive a call](../explanation/model.md#entities).**
`receiver: Counter` is an ordinary named non-null parameter, and the result
is `u64`. `member(@Counter, instance)` associates this function with the local
object; `receiver($receiver)` identifies the instance parameter.
`variadic(false)` fixes the signature. The result slot can be referenced
externally as `@read_count::result`; within this call it is `$result`
([L2](../language.md#l2), [L4–L5](../language.md#l4),
[C1](../contracts.md#c1), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
`completions([returned])` has one `read` outcome, selected by
`when(returned, any)`, labelled success and returning a valid scalar count
([C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
`input($receiver, borrow)` transfers no release duty. `retain(..., none)`
stores no reference, and `valid(..., call)` requires the object to stay
usable through the call. `mutation(none)` promises no change to its input
state ([C3](../contracts.md#c3)).

**[Where and when calls run](../explanation/model.md#execution).**
`execution(sync)` finishes before return, and `executor(main)` respects
`Counter`'s confinement. `concurrency(serial)` prevents independent overlap
on the same receiver; `reentrancy(allowed)` permits nested re-entry under
that contract ([C2–C3](../contracts.md#c2)).

**[The published description](../explanation/model.md#description).**
The member is available in `test` and not deprecated
([L3](../language.md#l3), [L5](../language.md#l5)).

**[Reaching the code](../explanation/model.md#access).**
Both access blocks apply in `test`. `objc_like` selects convention
`object-message` and `via(fixture, "message", "currentCount")`; F1 lowers
the explicit receiver to an implicit message receiver. Its
`compatibility(stable)` relies on the fixture ABI's stable domain
([A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

`swift_like` selects convention `source` and source-call identity
`Outer.Counter.currentCount.get`. `compatibility(source, "fixture-build")`
binds this path to F1's recipe using `fixture-compiler` version `1`. Each
path's `mapping(identity)` preserves the same complete declaration contract.
A consumer chooses a path explicitly or through configuration; source order
chooses neither, and the source recipe establishes compatibility for that
build ([A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

For the relationship between members and their parameters, see
[the language-containment view and member example](../language.md#l2).
For the two paths, see [Reaching the code](../explanation/packages.md#reaching-the-code);
exact syntax is in [access paths](../reference/notation.md#access).

### Write count: change the receiver without consuming it

[Validity](../explanation/model.md#validity) includes changes to live state.
Here the setter may change the counter while leaving the caller's release
duty intact.

Fragment — `write_count` in `example::objects`. The
[complete package](../examples/objects.ail) also supplies its owner, getter
and property association.

<!-- ail-example: ../examples/objects.ail lines=57-82 -->
```ail
  fn write_count(receiver: Counter, value: u64) -> unit {
    available([test]);
    deprecated(no);
    member(@Counter, instance);
    receiver($receiver);
    execution(sync);
    completions([returned]);
    executor(main);
    concurrency(serial);
    reentrancy(allowed);
    mutation(receiver);
    variadic(false);
    input($receiver, borrow);
    retain($receiver, none);
    valid($receiver, call);
    outcome written {
      when(returned, any);
      meaning(success);
    }
    access objc_like in [test] {
      abi(native, "object-message");
      via(fixture, "message", "replaceCount:");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Operations and their values](../explanation/model.md#operations)** and
**[Entities that outlive a call](../explanation/model.md#entities).**
The setter takes `receiver: Counter` and scalar `value: u64`, then returns
`unit`. `member(@Counter, instance)` and `receiver($receiver)` identify the
same instance owner as the getter. `variadic(false)` fixes both parameters;
the scalar `value` needs no input ownership clauses
([L4–L5](../language.md#l4), [C3](../contracts.md#c3)).

**[How a call finishes](../explanation/model.md#outcomes).**
The returned completion has one successful `written` outcome selected by
`any`. With a unit result and no writable pointee, no output `state` is
needed ([C5](../contracts.md#c5)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
The receiver is borrowed, not retained, and valid for the call.
`mutation(receiver)` permits changing its live contents. Those clauses
express a state change while ownership remains with the caller
([C3](../contracts.md#c3)).

**[Where and when calls run](../explanation/model.md#execution).**
The setter is synchronous on `main`, with serial independent concurrency
and allowed nested re-entry, matching the getter's entry restrictions
([C2–C3](../contracts.md#c2)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
`available([test])` and `deprecated(no)` match the getter. Its one
`objc_like` path uses `native`'s `object-message` convention and the exact
selector `replaceCount:`. Identity mapping preserves the receiver and value
semantics while making the receiver implicit; compatibility is stable in
the fixture domain. The getter's source path creates no second path for
this setter ([L3](../language.md#l3), [L5](../language.md#l5),
[A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

### Count: a property refers to full accessor contracts

[Entities that outlive a call](../explanation/model.md#entities) connects a
property's value to operations on its owner. The property records that
relationship without repeating the getter's and setter's call contracts.

Fragment — `count` in `example::objects`. The [complete package](../examples/objects.ail)
also supplies `Counter` and both named accessor functions.

<!-- ail-example: ../examples/objects.ail lines=83-89 -->
```ail
  property count: u64 {
    available([test]);
    deprecated(no);
    member(@Counter, instance);
    accessors(@read_count, @write_count);
    storage(value);
  }
```

**[Entities that outlive a call](../explanation/model.md#entities).**
`count: u64` is an instance property of local `Counter`.
`accessors(@read_count, @write_count)` selects the getter and setter already
read. Their owner, member kind, availability and types agree: the getter
returns `u64`, and the setter accepts one additional `value: u64` and returns
`unit`. `storage(value)` asserts value storage consistent with those scalar
contracts ([L5](../language.md#l5), [C3](../contracts.md#c3)).

**[The published description](../explanation/model.md#description).**
The property is available in `test` and not deprecated. Its accessor
references name local declarations; the property's spelling does not create
an additional access mechanism ([L2–L3](../language.md#l2),
[L5](../language.md#l5), [A2](../profiles.md#a2)).

### Fixed bytes: take the address of storage

[Storage](../explanation/model.md#storage) gives the reader four initialized
bytes. [Reaching the code](../explanation/model.md#access) tells the consumer
to obtain their address from an exported symbol.

Fragment — `fixed_bytes` in `example::objects`. The
[complete package](../examples/objects.ail) also supplies the environment and
provider definitions it selects.

<!-- ail-example: ../examples/objects.ail lines=90-105 -->
```ail
  constant fixed_bytes: ptr<u8> {
    available([test]);
    deprecated(no);
    sharing(shared);
    isolation(none);
    extent($result, buffer(4, 4, elements));
    contents($result, binary);
    give($result, borrow(static));
    invalidated_by($result, []);
    access direct in [test] {
      abi(native, "c");
      via(fixture, "address", "fixture_fixed_bytes");
      mapping(identity);
      compatibility(stable);
    }
  }
```

**[Entities that outlive a call](../explanation/model.md#entities)** and
**[Storage](../explanation/model.md#storage).**
This constant denotes an immutable pointer value of type `ptr<u8>`.
`extent($result, buffer(4, 4, elements))` gives four initialized elements and
capacity for four; `contents(..., binary)` gives bytes without a text
terminator. `$result` describes the supplied value here, although there is
no callable outcome block ([L4–L5](../language.md#l4),
[C4](../contracts.md#c4), [C7](../contracts.md#c7)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
`give($result, borrow(static))` lends the bytes without transferring a release
duty. `static` lasts for the loaded API instance; F1 ends it at provider
unload. `invalidated_by($result, [])` records no earlier invalidation
([C1](../contracts.md#c1), [C5](../contracts.md#c5),
[C7](../contracts.md#c7), [F1](../profiles.md#f1)).

**[Where and when calls run](../explanation/model.md#execution).**
`sharing(shared)` lets the reference cross executors; `isolation(none)`
places no executor confinement on it. Shared access still supplies no
permission for data races ([C2](../contracts.md#c2), [C7](../contracts.md#c7)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
The constant is available in `test` and not deprecated. Its `direct` access
in `test` selects convention `c` and uses the `address` mechanism on
`fixture_fixed_bytes`: the symbol supplies the address of the pointee
storage. `mapping(identity)` preserves the declared data value;
`compatibility(stable)` uses the fixture domain
([L3](../language.md#l3), [L5](../language.md#l5),
[A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

### Pointer value: load a pointer held in storage

[Entities that outlive a call](../explanation/model.md#entities) includes
named global storage. This global holds a pointer whose value is loaded
before the caller reads the bytes it addresses.

Fragment — `pointer_value` in `example::objects`. The
[complete package](../examples/objects.ail) also supplies the selected providers
and the contrasting `fixed_bytes` constant.

<!-- ail-example: ../examples/objects.ail lines=106-122 -->
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

**[Entities that outlive a call](../explanation/model.md#entities).**
`global pointer_value: ptr<u8>` denotes storage holding a pointer;
`mutable(false)` makes that global storage immutable. The loaded value is a
non-null pointer to readable bytes ([L4–L5](../language.md#l4),
[C7](../contracts.md#c7)).

**[Release responsibility](../explanation/model.md#responsibility)** and
**[Validity](../explanation/model.md#validity).**
`give($result, borrow(static))` and `invalidated_by($result, [])` describe a
borrow lasting until provider unload, without earlier invalidators. Core
rules permit this immutable reference global. A caller acquires no pointer
release duty ([C1](../contracts.md#c1), [C5](../contracts.md#c5),
[C7](../contracts.md#c7), [F1](../profiles.md#f1)).

**[Storage](../explanation/model.md#storage)** and
**[Where and when calls run](../explanation/model.md#execution).**
`buffer(4, 4, elements)` and `binary` supply four initialized bytes in capacity
for four, with no terminator. `sharing(shared)` permits the reference to
cross executors, and `isolation(none)` gives it no executor confinement
([C2](../contracts.md#c2), [C4](../contracts.md#c4), [C7](../contracts.md#c7)).

**[The published description](../explanation/model.md#description)** and
**[Reaching the code](../explanation/model.md#access).**
The global is available in `test` and not deprecated. Its `direct` path uses
convention `c` with `via(fixture, "load", "fixture_pointer_value")`: load the
pointer stored at that symbol. Identity mapping and stable compatibility
preserve the value in the fixture domain. Substituting the symbol's own
address would instead point at the storage holding the pointer. The common
`ptr<u8>` type therefore cannot choose between this mechanism and
`fixed_bytes`'s `address` mechanism ([L3](../language.md#l3),
[L5](../language.md#l5), [A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

### Plain-language view of the object API

The host supplies reference-counted counters whose use and release stay on
the main executor. Reading borrows a counter and returns its count; writing
borrows it and may change that count. The `count` property connects those
two full functions. A tool can reach the getter by a synthetic message call
or by the specified source-build recipe; either route preserves its complete
contract. Separately, one data symbol supplies the address of four bytes,
and another stores a pointer to four bytes. Both give static borrows that
end at provider unload ([L5](../language.md#l5),
[C2–C3](../contracts.md#c2), [C7](../contracts.md#c7),
[A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).

### Trace the object obligations

Using [the complete package](../examples/objects.ail) and the readings above:

1. **Entities that outlive a call:** start at `count`. Find its nominal
   owner, both accessor declarations and their receiver parameters. Locate
   `@write_count::value` and `@read_count::result`.
2. **Where and when calls run:** decide whether obtaining a counter on the
   main executor permits releasing it on a worker. Identify all clauses
   needed to answer, including the fixture conformance fact.
3. **Reaching the code:** compare the getter's two paths. Identify the
   ABI entry, conventions, identities and compatibility conditions. Decide
   whether the setter automatically gains both paths too.
4. **Storage:** describe what a consumer retrieves from
   `fixture_fixed_bytes` and from `fixture_pointer_value`, then identify
   when either returned pointer stops being usable.

**Expected observations**

1. `count`, `read_count` and `write_count` are top-level declarations with
   the same local `Counter` owner and instance kind. The accessors identify
   their ordinary `receiver` parameter with `receiver($receiver)`.
   `@write_count::value` names the setter's scalar input;
   `@read_count::result` names the getter's result slot. Neither reference
   imports a declaration ([L2](../language.md#l2), [L5](../language.md#l5)).
2. `sharing(confined)` and `isolation(main)` cover release as well as calls;
   the runtime release primitive follows those restrictions.
   `fixture::sendability(nonconforming)` remains a separate profile fact
   ([C2](../contracts.md#c2), [F1](../profiles.md#f1)).
3. Both paths use `native`. One uses `object-message`, selector
   `currentCount` and stable compatibility. The other uses `source`,
   `Outer.Counter.currentCount.get` and recipe `fixture-build`.
   Selection is explicit. The setter has only its declared message path
   ([A2–A4](../profiles.md#a2), [F1](../profiles.md#f1)).
4. `fixed_bytes` takes the symbol address as the byte-storage address;
   `pointer_value` loads a pointer held at its symbol. Their static borrows
   end at provider unload, and the empty invalidator lists promise no
   earlier invalidation ([C1](../contracts.md#c1), [C7](../contracts.md#c7),
   [A3](../profiles.md#a3), [F1](../profiles.md#f1)).

**Review prompt:** Starting at `count`, could you recover its ownership,
executor and access facts without mistaking a derived property view for a
separate contract? Cite the relationships in [L5](../language.md#l5) or the
access alternatives in [A2](../profiles.md#a2) that helped or hindered you.
Describe an alternative organization if it would make those facts easier to
find while preserving both call paths and the address/load distinction.

## Where next

For **[Writers, checkers and users](../explanation/model.md#agreement)**,
compare these readings with [Two views of one contract](../conformance.md#two-views-of-one-contract).
A consumer may present selected facts for a task, provided the complete
normative facts remain accessible and its own restrictions are labelled
([A5](../profiles.md#a5)). The plain-language views above are such summaries;
the linked packages retain the full descriptions.

Continue to [Review tasks](tasks.md) to test and judge the notation, and use
[Reviewing AIL](README.md) for the six dimensions and feedback template.
[Design choices, limits and open questions](../explanation/choices.md)
helps frame criticism; use [the reference indexes](../reference/README.md)
to find exact clauses and rejection cases. Return to
[the documentation map](../README.md#paths-through-the-documentation).
