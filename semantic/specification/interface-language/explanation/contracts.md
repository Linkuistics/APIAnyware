# How AIL states a contract

> **Purpose:** explanation — read AIL's semantic [clauses](../glossary.md#clause) as obligations between [callers and callees](../glossary.md#caller-and-callee).
> **Reader:** language designers who have met the API [binding](../glossary.md#binding) domain and want to understand the notation.
> **Before this:** [Using an API across languages](unsaid.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L4–L6`](../language.md#l4), [`C1–C8`](../contracts.md#c1) and [`A1–A5`](../profiles.md#a1) are canonical; the explanations here are non-normative.

The domain page asked who releases a value, how long access lasts, and when a
[callback](../glossary.md#callback) can run. This page shows how AIL records those answers. By the end,
you should be able to follow the obligations in the three
[conformance examples](../conformance.md#positive-specifications).

Those examples describe invented APIs using a synthetic fixture
[profile](../glossary.md#profile) (a semantic extension, not a preferences preset),
catalogue and [digest tokens](../glossary.md#digest-pin)
([`F1`](../profiles.md#f1)). They are not contracts
for real operating-system APIs. Extracts below are labelled fragments because
the surrounding declarations and [package](../glossary.md#package) still matter.
The alternatives
compare design possibilities; they do not change draft 0.1 or claim to be its
authors' recorded rationale.

The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows who writes, checks and uses an AIL description. This page looks inside
that description to explain the obligations on each call.

## From signature to contract

A [caller](../glossary.md#caller-and-callee) needs to know whether closing a
watch gives up its obligation to release it. The C header in the domain page
does not answer that. For this first example, assume `watch_close` is the unique
destructor of `Watch`: it [consumes](../glossary.md#consume) the
[handle](../glossary.md#handle), taking the caller's release obligation at entry,
and completes successfully.
This is an illustrative contract choice, not a fact inferred from the header.

Fragment — omits the package, `Watch` declaration,
[availability](../glossary.md#availability), other effects,
[retention](../glossary.md#retention) and [access path](../glossary.md#access-path);
not a publishable package.

<!-- ail-fragment -->
```ail
fn watch_close(watch: Watch) -> unit {
  execution(sync);
  completions([returned]);
  input($watch, consume);
  outcome closed {
    when(returned, any);
    meaning(success);
  }
}
```

Compare the synthetic store's `view`: its signature also accepts a resource,
but its body lends access and describes a returned pointer. `fn` introduces the
operation, the parameter list and arrow describe the values crossing the call,
and the clauses in braces describe their obligations.

Fragment — omits the package, `Store` declaration, availability, effects,
retention, buffer facts and access path; not a publishable package.

<!-- ail-fragment -->
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
}
```

The principle is that the signature and clauses answer different questions.
In summary (non-normative), a resource type identifies a handle; `input` says
whether entry transfers an obligation, and an [outcome](../glossary.md#outcome)
describes [completion](../glossary.md#completion) and
outputs. AIL uses the same `name(arguments);` clause syntax for these facts,
with a closed vocabulary specified by the rules. Merely parsing that shape
does not establish a valid contract ([`L1`](../language.md#l1),
[`L4`](../language.md#l4), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

The choice makes obligations individually addressable, at the cost of a longer
body and several rule lookups. Putting ownership in types is an alternative;
the [design proposal](../../../docs/design/2026-09-22-interface-language.md#7-dedicated-syntax-direction)
left that decision open, and [Q3](choices.md#q3)
records the missing rationale for draft 0.1's choice. Neither fragment hides
the need for a complete function's effects and access path
([`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

## Naming what a contract talks about

Writing to caller-supplied storage changes a different thing from borrowing the
pointer that locates it. Confusing the two can make a binding treat an address
as initialized output. A [slot](../glossary.md#slot) names a parameter, result or
thrown value; a [place](../glossary.md#place) selects a value or storage within it.

Compare a single output integer, addressed with `.*`, with the synthetic
`copy_bytes` output buffer, addressed with `[]`.

Fragment — omits a callable with parameter `length: mutptr<u64>`, its other
contracts, and the enclosing successful outcome for `state`; not a publishable
package.

<!-- ail-fragment -->
```ail
extent($length, one);
// In an outcome:
state($length.*, valid);
```

Fragment — omits the containing `copy_bytes` declaration, other contracts and
outcome wrapper; not a publishable package.

<!-- ail-fragment -->
```ail
extent($destination, buffer(16, 16, elements));
// In the copied outcome:
state($destination[], valid);
```

In the first case, `$length` is the pointer and `$length.*` is one integer.
In the second, `$destination[]` describes the buffer's initialized elements.
The principle is to address the object of each obligation explicitly. In
summary (non-normative), `.*` goes with extent `one`, `[]` with buffer extent,
and `.field` selects a record field. Paths type-check; the two pointer selectors
are not interchangeable spellings ([`C1`](../contracts.md#c1)).

The selector table keeps the pointer value distinct from the storage addressed
through it.

| Place | What it selects | Extent needed for traversal |
|---|---|---|
| `$length` | The pointer value | No traversal |
| `$length.*` | One integer through that pointer | `one` |
| `$destination[]` | Initialized buffer elements | `buffer(...)` |

A [reference leaf](../glossary.md#reference-leaf) is a pointer, resource, object,
interface or callback value, including one within an aggregate. For a record
result with a resource field `handle`, `state($result, valid)` describes the
aggregate shape, while `give($result.handle, owned)` assigns that field's
ownership. A scalar field needs no `give`. Pointer traversal is explicit:
borrowing `$length` does not describe the integer written through it
([`L4–L5`](../language.md#l4), [`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

AIL chooses typed paths rather than implicitly applying every clause throughout
an aggregate. This makes container and element obligations distinguishable, but
makes nested contracts longer. It also uses two naming contexts: local
`$handler` and external `@subscribe::handler`. The latter includes the operation
identity ([`L2`](../language.md#l2)); the discoverability cost is recorded as
[audit Q4](../../../docs/research/interface-language-documentation-audit.md#4-possible-language-issues-surfaced-for-review).

## Who owns what

A binding needs to track responsibility for release as values cross calls.
[Owned](../glossary.md#owned) means one destruction or release obligation; it
does not promise exclusive access. A [borrow](../glossary.md#borrow) grants
access without that transfer and does not imply Rust's static borrow checking.

Compare these entry contracts from the synthetic buffer example. The first
lets `view` use the store; the second hands the store to `destroy`.

Fragment — omits the containing declarations and their remaining clauses;
not a publishable package.

<!-- ail-fragment -->
```ail
// view entry
input($store, borrow);
retain($store, none);
valid($store, call);

// destroy entry
input($store, consume);
retain($store, none);
```

The caller keeps its obligation across `view`. With
[consumption](../glossary.md#consume), the callee takes over at entry on every
outcome. In this example `destroy` discharges it by destruction. Consumption
itself does not mean mutation of live contents, so its `mutation(none)` in the
full file is consistent ([`C2–C3`](../contracts.md#c2)).

Now compare delivery of a new store with delivery of a view into an existing
store. These are exit facts, separate from entry transfer.

Fragment — omits the containing outcomes and their other clauses;
not a publishable package.

<!-- ail-fragment -->
```ail
// create.created
state($result, valid);
give($result, owned);

// view.viewed
state($result, valid);
give($result, borrow(owner($store)));
invalidated_by($result, []);
```

The first gives the caller one destruction obligation for a non-null store.
The second gives access to bytes without giving a release obligation. A null
reference carries no obligation even when its outcome repeats `give(owned)`
([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

[Retention](../glossary.md#retention) answers a third question: what does the
callee store beyond immediate use? The synthetic `subscribe` borrows its
handler at entry and independently retains it for the subscription's lifetime.

Fragment — omits the `subscribe` declaration, schedule, outcomes and remaining
clauses; not a publishable package.

<!-- ail-example: ../examples/callbacks.ail lines=48-50 -->
```ail
    input($handler, borrow);
    retain($handler, strong(owner($result)));
    valid($handler, call);
```

In summary (non-normative), `input(consume)` transfers an existing obligation,
`retain(strong(...))` creates an independent one, and `give(owned)` supplies one
to the caller. `retain(none)` promises no retention. A unique resource cannot be
strongly retained or [copied](../glossary.md#copy) without an explicit clone profile
([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

Use the diagram to follow the same three ownership cases through the domain
page's [invented watch API](unsaid.md#a-small-api). Its `watch_view` borrows the
watch, leaving the program responsible for closing it. Its `watch_close` takes
that responsibility at entry and destroys the watch. A non-null owned result
from `watch_open` gives the program a new watch to close; null gives none.
These are separate possible contracts, with time running downward within each
case. A consuming operation takes the obligation even on failure. It discharges
that obligation unless it explicitly returns it as an owned output
([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

Strong retention is a separate event, as the handler example shows. It creates
an additional release obligation while the caller keeps its own; that event
is outside this figure. Ownership also leaves exclusive access to other rules.

![Three separate synthetic watch cases: watch_view leaves closing to the program; watch_close takes responsibility at entry and destroys the watch; a non-null owned watch_open result gives closing responsibility to the program. A null result gives none.](../figures/g4-ownership.svg)

[Diagram source](../figures/g4-ownership.puml) ·
[How tools use these API facts](../README.md#who-writes-and-uses-an-ail-description)

AIL's choice exposes each event rather than compressing them into a single
“takes ownership” annotation. The cost is more clauses to reconcile. A single
annotation would be shorter, but would need additional meanings to distinguish
borrowing with strong retention from consumption without retention.

## How long a borrow lasts

Keeping an address is useful only while the referenced storage remains usable.
A [region](../glossary.md#region) gives its lifetime boundary;
[invalidation](../glossary.md#invalidation) can end a borrow earlier while its
owner remains alive.

The synthetic `view` lends immutable bytes until store destruction. Compare a
constructed mutable-store variant whose `replace` operation invalidates prior
views at entry.

Fragment — omits the `view` declaration and enclosing outcome;
not a publishable package.

<!-- ail-fragment -->
```ail
valid($store, call);
// In the viewed outcome:
give($result, borrow(owner($store)));
invalidated_by($result, []);
```

Fragment — omits the mutable-store declarations, enclosing outcome and
`replace` contract, which would name the owner parameter and appropriate
mutation; not a publishable package.

<!-- ail-fragment -->
```ail
give($result, borrow(owner($store)));
invalidated_by($result, [@replace]);
```

In the first case, the input clause covers use during `view`; the output region
relates later access to the owner's lifetime. In the second, keeping the owner
alive is insufficient once `replace` starts. The caller stops using the old
view then. An empty invalidator list states that no operation invalidates the
borrow before its region ends; it does not make the borrow permanent
([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

The timing diagram separates input validity during `view` from later use of
its result: owner destruction ends the immutable view, while `replace` entry
ends the constructed mutable view sooner. It zooms into borrow validity and
omits other call obligations and the mutable variant's full contracts.

![Two separate timelines: view borrows its input through completion and delivers an owner-scoped result. The immutable result lasts until Store destruction; in the constructed mutable variant, replace entry invalidates the old result while Store remains alive.](../figures/g5-borrow.svg)

[Borrow timing source](../figures/g5-borrow.puml)

In summary (non-normative), the three regions name different boundaries:

| Region | Boundary | Example |
|---|---|---|
| `call` | Completion of this invocation, including synchronous callbacks | `valid($store, call)` on `view` entry |
| `owner($store)` | Destruction of the owner or release of its final reference | The `view` result |
| `static` | End of the loaded API instance, with [provider](../glossary.md#provider)-defined shutdown | `give($result, borrow(static))` on synthetic `fixed_bytes` |

These meanings come from [`C1`](../contracts.md#c1); synthetic `static` ends at
provider unload ([`F1`](../profiles.md#f1)). An escaping borrow needs a region
that survives delivery: `borrow(call)` cannot describe a returned view
([`C1`](../contracts.md#c1); mutation N07 in the
[conformance corpus](../conformance.md#rejection-mutations)).

The principle is to track both a lifetime boundary and earlier invalidators.
AIL chooses this split instead of a single “valid until next use” description.
It can name an owner independently of mutation, but a reader follows facts
across entry and outcome clauses. That cost is [Q5](choices.md#q5).
The mutable variant illustrates only the relationship: its omitted operation
contracts are needed to check whether the named invalidator is legal.

## Every way a call can end

A binding needs to distinguish an observable failure from unreadable output.
A [completion](../glossary.md#completion) says how an invocation finishes; an
[outcome](../glossary.md#outcome) partitions the possibilities for that
completion. Compare the synthetic null-result constructor with the Boolean
status returned by `copy_bytes`.

Fragment — omits the containing `create` declaration and package;
not a publishable package.

<!-- ail-example: ../examples/buffers.ail lines=30-41 -->
```ail
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
```

Fragment — omits the containing `copy_bytes` declaration and package;
not a publishable package.

<!-- ail-example: ../examples/buffers.ail lines=121-132 -->
```ail
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
```

The constructor's null is a valid, observable result representing failure. It
creates no ownership obligation. The copy's Boolean result is valid on both
outcomes, but on failure the destination elements are unreadable. The caller
can test the status and cannot inspect failed output to find out what happened
([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

The partition table shows why observable failure and unreadable output are
different: each returned value selects exactly one row for its operation.

| Operation and discriminator | Selected outcome | What the caller receives |
|---|---|---|
| `create`: non-null result | `created` — success | Valid store; one destruction obligation |
| `create`: null result | `allocation_failed` — failure | Valid null; no obligation |
| `copy_bytes`: `true` | `copied` — success | Valid status and destination elements |
| `copy_bytes`: `false` | `failed` — failure | Valid status; destination elements unreadable |

In summary (non-normative), `when` selects the case, `meaning` classifies it,
and `state` describes [output state](../glossary.md#output-state).
A [discriminator](../glossary.md#discriminator) is the value being tested.
For each declared completion, outcomes are mutually exclusive and exhaustive
over one valid discriminator's full type domain, or use one `any`. The
null/non-null and true/false pairs cover their respective domains. For an
integer status, “zero” and “positive” would miss negative values of a signed
type ([`C5`](../contracts.md#c5)).

`state(unchanged)` is another possibility for `inout` storage: it preserves
entry obligations. It cannot describe a subtree whose input obligations were
consumed; returning that reference requires explicit valid state and owned
delivery ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

The principle is that failure still has an output contract. AIL chooses a small,
checkable predicate vocabulary over arbitrary executable conditions. This
bounds coverage checking but leaves correlations across multiple
discriminators to profiles. It also preserves the API's error observation:
`meaning(failure)` alone does not turn a null or status into an exception.
These examples only return; thrown, cancelled or terminated completion needs
the corresponding signature and provider support
([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

## Buffers and strings

An address does not tell a binding how much storage it may read, how much it
may write, or whether zero ends text. [Extent](../glossary.md#buffer-extent)
describes length and capacity; [contents](../glossary.md#contents) identifies
binary data or text.

Compare the synthetic sixteen-byte binary view with a constructed three-code-unit
UTF-8 string that includes space for its terminator.

Fragment — omits the containing `view` declaration and other contracts;
not a publishable package.

<!-- ail-example: ../examples/buffers.ail lines=85-86 -->
```ail
    extent($result, buffer(16, 16, elements));
    contents($result, binary);
```

Fragment — omits a callable returning `ptr<u8>`, its ownership/outcomes and the
synthetic fixture profile, catalogue and digest tokens supplying UTF-8;
not a publishable package.

<!-- ail-fragment -->
```ail
extent($result, buffer(3, 4, elements));
contents($result, text("utf-8", nul));
```

The binary view has sixteen readable elements and no terminator convention.
The text has three payload code units, with a final zero in its fourth storage
position. Its length excludes that zero and its capacity includes it; embedded
zero code units are forbidden. This is a count of code units, not necessarily
characters ([`C4`](../contracts.md#c4), [`F1`](../profiles.md#f1)).

The storage comparison shows which positions count toward readable payload
and which provide terminator space.

| Example | Payload length | Storage capacity | Terminator |
|---|---|---|---|
| Synthetic binary view | 16 elements | 16 elements | No terminator convention |
| Constructed UTF-8 text | 3 code units | 4 code units | Zero in the fourth position, outside the payload length |

In summary (non-normative), capacity is allocated storage and length is readable
initialized content. Input `out` buffers need no initialized elements on entry;
a valid output initializes the declared length. Positive capacity still needs
allocated, aligned storage even with zero length. A nullable buffer that is null
has zero length and capacity. Caller and callee share a bound:
`0 <= length <= capacity`, with the additional terminator space for `nul`
([`C4`](../contracts.md#c4)).

Direction and aliasing complete the storage picture. The synthetic
`copy_bytes` uses `direction($destination, out)` to say it does not read prior
contents, and `aliasing($destination, disjoint)` to prohibit overlap with other
accessed memory. Its `mutptr<u8>` and `mutation(arguments)` agree with writing
the buffer ([`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4)).

The principle is to separate storage bounds from interpretation. AIL chooses
explicit bounded extents over treating every byte pointer as a C string.
That costs length/capacity facts even for familiar pointer shapes. A scanned
terminator-only contract is an alternative requiring a profile; the core
cannot invent a maximum bound ([`C4`](../contracts.md#c4)). The fixed-size
examples do not show dynamic length slots, but the same rule permits integral
scalar slots as lengths and capacities.

## Callbacks

Storing a callback creates two questions: what does an invocation do, and when
can the API invoke it? A binding that knows the first alone can release
[callback captures](../glossary.md#callback-captures) while later invocations
still need them. Here captures means callback state, not a
[dependency closure](../glossary.md#dependency-closure).

The synthetic `Handler` declaration describes one invocation. Its
`execution(sync)` says that invocation completes before returning to its caller;
its [`concurrency(serial)`](../glossary.md#concurrency) and
[`reentrancy(forbidden)`](../glossary.md#re-entrancy) constrain uses of that
callback type ([`C2–C3`](../contracts.md#c2)). Compare two schedules for using
such a handler: the synthetic subscription stores it, while a constructed
call-scoped operation invokes it once before completing.

Fragment — omits the `subscribe` declaration, retention and outcome clauses;
not a publishable package.

<!-- ail-example: ../examples/callbacks.ail lines=51-59 -->
```ail
    callback $handler {
      timing(after_return);
      count(0, many);
      scope(owner($result));
      executor(any);
      concurrency(serial);
      reentrancy(forbidden);
      quiescence(@unsubscribe);
    }
```

Fragment — omits a synchronous callable with parameter `handler: Handler`, its
other effects, outcome and access clauses; not a publishable package.

<!-- ail-fragment -->
```ail
input($handler, borrow);
retain($handler, none);
valid($handler, call);
callback $handler {
  timing(during_call);
  count(1, 1);
  scope(call);
  executor(any);
  concurrency(serial);
  reentrancy(forbidden);
  quiescence(return);
}
```

For the subscription, the API starts notifications after registration returns
and may invoke the handler zero or arbitrarily many times over its owner scope.
`many` means
unbounded permission, not an unknown count. `subscribe` itself still completes
synchronously. For the second case, invocations start during the call and all
finish before it completes; the count is exactly one conditional on eventual
scope end. Neither count is a general termination guarantee
([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).

[Quiescence](../glossary.md#quiescence) is the teardown boundary after which no
invocation is running or can start. In the subscription, its unique owner's
`unsubscribe` destructor establishes that boundary before returning. Its
`requires(outside_callback(@subscribe::handler))` prevents calling this blocking
teardown from within the very callback it waits for. The retained callback is
stored for the owner region; the [provider](../glossary.md#provider) defines its
[representation](../glossary.md#representation) and
release ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6),
[`F1`](../profiles.md#f1)).

The timing diagram places quiescence at completion of the enclosing call or
the owner's destructor, so an in-flight callback during teardown cannot be
mistaken for permission to run after teardown returns. The owner-scoped case
shows one permitted trace after successful synthetic registration; zero
invocations is also permitted. The constructed call-scoped case is separate.
This view omits native scheduling and capture-release machinery.

![In the constructed call-scoped case, the handler starts and finishes before registration completes. In the synthetic owner-scoped case, starts follow subscribe return; an invocation can remain in flight when a client outside the callback enters unsubscribe, but none runs or can start after unsubscribe returns.](../figures/g7-callbacks.svg)

[Callback timing source](../figures/g7-callbacks.puml)

The principle is that invocation, schedule and teardown are separate contracts.
AIL chooses explicit timing, count, scope and quiescence rather than one
“asynchronous callback” annotation. That is more to write, but the shorter label
would leave these distinctions unanswered. A different teardown protocol, such
as a cancellation request with later acknowledgement, needs profile-defined
events and ordering; cancellation return cannot be labelled quiescence unless
it actually supplies that boundary ([`C6`](../contracts.md#c6)).

## Threads and sharing

Moving a reference between execution contexts and permitting simultaneous calls
are different permissions. An [executor](../glossary.md#executor) specifies
where entry is allowed; [concurrency](../glossary.md#concurrency) governs
independent overlap; [re-entrancy](../glossary.md#re-entrancy) governs nested
entry while another call is active.

Compare the synthetic store and counter. The store permits moving sole ownership
between executors; the counter is confined to the main thread. Their call
contracts supply the remaining restrictions.

Fragment — omits the enclosing `Store` and `view` declarations and other
contracts; not a publishable package.

<!-- ail-fragment -->
```ail
// Store
sharing(transferable);
isolation(none);
// view
executor(any);
concurrency(serial);
reentrancy(allowed);
```

Fragment — omits the enclosing `Counter` and `read_count` declarations and
other contracts; not a publishable package.

<!-- ail-fragment -->
```ail
// Counter
sharing(confined);
isolation(main);
// read_count
executor(main);
concurrency(serial);
reentrancy(allowed);
```

In the first case, callers may enter on any executor but serialize independent
calls using the same store. In the second, callers also enter on the main thread.
Both permit the
specified nested re-entry, which is distinct from independent overlap. A lock
alone does not satisfy the counter's executor restriction
([`C2–C3`](../contracts.md#c2)).

The comparison keeps executor permission, independent overlap and nested
re-entry on separate rows; granting one does not grant the others.

| Permission | Synthetic `Store` / `view` | Synthetic `Counter` / `read_count` |
|---|---|---|
| Moving or sharing the reference | Sole ownership is transferable | Reference is confined to main |
| Call entry | Any executor | Main thread |
| Independent calls using the same instance | Serialized | Serialized |
| Specified nested re-entry | Allowed | Allowed |

In summary (non-normative), nominal `sharing` and
[isolation](../glossary.md#isolation) describe the type, while per-call clauses
describe operations. [`sharing(shared)`](../glossary.md#shared) permits references to cross executors
without promising safe concurrent mutation; `isolation(none)` records known
absence of nominal isolation without making every operation callable anywhere.
Confinement also covers release and destruction. Callback sharing and isolation
cover its captures independently of its invocation schedule
([`C2`](../contracts.md#c2), [`C6`](../contracts.md#c6)).

AIL chooses several orthogonal facts over a single “thread-safe” flag. The cost
is checking agreement between type and operation contracts; the gain is stating
which permission exists. A source-language conformance flag is another possible
input, but does not answer these questions: the synthetic counter's
`fixture::sendability(nonconforming)` is a separate profile fact, not a claim
about an actual Swift compiler ([`C2`](../contracts.md#c2), [`F1`](../profiles.md#f1)).

## Lifecycles and patterns

A release obligation needs an operation that discharges it, and clients may also
need ordering constraints between operations. A [lifecycle](../glossary.md#lifecycle)
states the release discipline; a [pattern](../glossary.md#pattern) binds named
participants to reusable laws.

Compare the synthetic store's unique handle with the counter's counted
references.

Fragment — omits the containing nominal declarations and other contracts;
not a publishable package. `fixture` denotes the synthetic fixture profile,
whose catalogue and digest tokens are omitted.

<!-- ail-fragment -->
```ail
// Store
lifecycle(unique, @destroy);
// Counter
lifecycle(refcounted, runtime(fixture, "retain"), runtime(fixture, "release"));
```

The store's owned handle carries one destruction obligation. The counter can
have several owned references, each carrying its own release obligation; retain
creates another and final release destroys it. In the unique case, destruction
consumes the handle at entry and invalidates dependent borrows before returning
([`C2`](../contracts.md#c2), [`F1`](../profiles.md#f1)).

The state diagram tracks the immutable store's single destruction obligation:
creation supplies it, borrowing preserves it, and `destroy` takes it at entry
and invalidates dependent borrows before returning. It omits reference counting
and the separate constructed ordering pattern below.

![A non-null create result moves from no owned handle to a live Store with one caller obligation; null leaves no obligation. Borrowing preserves the live state. destroy entry transfers the obligation to the callee, and destruction discharges it and invalidates dependent borrows before return.](../figures/g6-lifecycle.svg)

[Resource state source](../figures/g6-lifecycle.puml)

Now compare two relationships between operations. The buffer example's pattern
identifies the actual release operation.

Fragment — omits the containing package and participant declarations;
not a publishable package.

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

A constructed ordering pattern instead requires a successful `prepare` before
entry into `read_prepared`, on the same resource instance.

Fragment — omits the resource and operation declarations, their contracts and
the package; not a publishable package.

<!-- ail-fragment -->
```ail
pattern prepared_use {
  role preparation: operation one;
  role use: operation one;
  law(before, preparation, use);
}
instance prepared_read: prepared_use {
  bind(preparation, [@prepare]);
  bind(use, [@read_prepared]);
  subject(preparation, @prepare::store);
  subject(use, @read_prepared::store);
}
```

Here a [role](../glossary.md#role) has a participant kind and a
[cardinality](../glossary.md#cardinality); `one` means exactly one.
The [pattern instance](../glossary.md#pattern-instance) supplies the participants.
`subject` names which reference slot in each operation identifies the shared
resource. Those slots need the same
nominal resource type ([`L6`](../language.md#l6)).

The role mapping separates the fixture's release relationship from the
constructed ordering requirement; the latter applies to the same resource
instance, not merely to matching parameter names.

| Pattern instance | Role bindings | Required relationship |
|---|---|---|
| Synthetic `store_lifetime` | `resource_type` → `Store`; `release` → `destroy` | `destroy` agrees with the unique destructor |
| Constructed `prepared_read` | `preparation` → `prepare`; `use` → `read_prepared` | Successful preparation precedes use entry on the resource identified by both `store` subject slots |

The principle is that relationships impose obligations rather than describe a
usual workflow. In summary (non-normative), core `releases` agrees with the
type's declared unique destructor; core `before` adds a state precondition to
the later operation. A role binding is not a second lifecycle definition, and
a successful preparation on one store does not satisfy the order for another
([`L6`](../language.md#l6)).

AIL chooses two typed core laws over arbitrary prose laws or a general state
machine language. The cost is limited expressiveness: richer laws require a
profile with operands, obligations and validation. The ordering fragment does
not itself provide a full lifecycle or prove the native implementation obeys
it ([`L6`](../language.md#l6), [`C8`](../contracts.md#c8)).

## What the core leaves to profiles

Knowing an obligation is different from knowing how a runtime realizes it.
A [profile](../glossary.md#profile) is a versioned semantic extension, not a
preferences preset. A [provider](../glossary.md#provider) supplies its definition
and support for interpreting or realizing it.

Compare a core execution fact admitted by the synthetic fixture with one that
needs additional semantics.

Fragment — omits the containing callable and its other contracts;
not a publishable package.

<!-- ail-fragment -->
```ail
execution(sync);
completions([returned]);
```

Fragment — omits the containing callable, the profile defining suspension,
scheduling and completion delivery, and all other contracts; not a publishable
package. The synthetic fixture alone cannot support this case.

<!-- ail-fragment -->
```ail
execution(async);
completions([returned]);
```

The first completes before returning control. The second needs a profile to say
how suspension and completion work; changing that one word in a synthetic
fixture package is rejected for unsupported semantics, not accepted as an
unfinished contract ([`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1);
N30 in the [conformance corpus](../conformance.md#rejection-mutations)).

In summary (non-normative), profiles define additional typed vocabulary and
obligations without weakening the core. [ABI entries](../glossary.md#abi-entry)
and access providers also supply [representations](../glossary.md#representation)
and call mechanisms: a core integer width or record
field order is not a complete native layout. Consumers identify unsupported
dependencies before claiming complete validation
([`A1–A3`](../profiles.md#a1)).

The principle is to make the boundary explicit. AIL chooses a common core plus
versioned providers over putting every source language and runtime mechanism
in the core. That keeps native distinctions available, but makes interpretation
depend on a larger body of specified rules. Uninterpreted annotations would be
an easier extension mechanism, at the cost of consumers disagreeing about
obligations; draft 0.1 rejects unknown normative vocabulary
([`L1`](../language.md#l1), [`A1`](../profiles.md#a1)).

[Validation](../glossary.md#validation) checks local symbolic constraints and
completeness. It cannot prove that a native implementation honours the asserted
contract, nor that every target language can bind it
([`C8`](../contracts.md#c8), [`A5`](../profiles.md#a5)).

Next: [Packages, environments and access paths](packages.md), then
[Design choices, limits and open questions](choices.md).
For a guided exercise, follow [Describing a small API](../tutorial/README.md).
See [the canonical contract rules](../contracts.md) for exact obligations. Return to the
[overview](../README.md) for the document map or the [domain explanation](unsaid.md)
for the failures these contracts prevent.
