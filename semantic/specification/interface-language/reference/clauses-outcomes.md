# Outcome and callback schedule clauses

> **Purpose:** reference — look up output states, returned obligations and [callback](../glossary.md#callback) schedules.
> **Reader:** reviewers, API authors and tool implementers checking an exact draft 0.1 fact.
> **Before this:** [How a call finishes](../explanation/model.md#outcomes), [Callbacks and their schedules](../explanation/model.md#callbacks), and [entry conventions](notation.md#entry-conventions).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L5`](../language.md#l5), [`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5), [`C6`](../contracts.md#c6) and [`C7`](../contracts.md#c7) are canonical. These entries are non-normative summaries.

Entries are alphabetical. [Outcomes](declarations.md#outcome) describe how one
invocation finishes; [callback-use blocks](declarations.md#callback-use) describe
the schedule for a supplied callback. Their forms use the generic
[`clause` production](notation.md#clause), inside the [outcome](notation.md#outcome)
or [callback-use](notation.md#callback-use) production.

A [place](../glossary.md#place) selects a value or storage within its [callable](../glossary.md#callable).
A [reference leaf](../glossary.md#reference-leaf) needs its own applicable
ownership facts, even inside an aggregate. A [region](../glossary.md#region)
bounds a [borrow](../glossary.md#borrow)'s lifetime. Callback [quiescence](../glossary.md#quiescence)
means that no invocation is running or can start. Examples use invented APIs
and the [synthetic `F1` providers](../profiles.md#f1).

In summary (non-normative; [`L5`](../language.md#l5), [`C8`](../contracts.md#c8)):
clauses outside their scope, missing applicable facts, wrong operands and
duplicate singular clauses are rejected. Place-keyed clauses repeat only for
distinct applicable places; an aggregate state excludes explicit child states.
The entries give the additional checks specific to each [clause](../glossary.md#clause).

<a id="count"></a>

## `count`

**Expresses:** [Callbacks and their schedules](../explanation/model.md#callbacks) — bounds on invocations over one registration's scope.

**Form:** `count(min, max);`, where `max` may be `many` ([callback-use grammar](notation.md#callback-use)).

**Operands and types:** A nonnegative integer minimum and a nonnegative integer maximum or the name `many`.

**Applies to:** Callback-use blocks, including uses of nested callback fields; nullable callbacks are governed when non-null.

**Required and repeatability:** Required exactly once per callback-use block.

**Default:** None; required.

**Meaning (non-normative; [`C6`](../contracts.md#c6)):** The bounds count all invocations for this registration, conditional on eventual scope end. `many` means unbounded. A minimum does not promise that the scope eventually ends.

**Constraints:** The minimum is at most the maximum. Count, start timing, [executor](../glossary.md#executor), overlap and teardown are independent facts; a known broad permission cannot stand for an unestablished fact ([`C6`](../contracts.md#c6), [contract scope](../contracts.md)).

**Rejected when:** Bounds are negative or reversed, or the required clause is absent. `N17` changes the bounds to `count(2, 1)` ([`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8), [`N17`](README.md#n17)).

**Example.** Fragment — the notification registration and its destructor. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, `Subscription`'s unique [lifecycle](../glossary.md#lifecycle), input [retention](../glossary.md#retention), outcomes, effects, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=callback-use -->
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

`count(0, many)` permits zero or more notifications. The owner scope and quiescent destructor determine when this registration ends; the count does not choose that boundary.

**Used by and see also:** [`scope`](#scope); [`timing`](#timing); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="give"></a>

## `give`

**Expresses:** [Release responsibility](../explanation/model.md#responsibility) — ownership or borrowing delivered with a valid output reference.

**Form:** `give($place, owned);` or `give($place, borrow(region));` ([clause grammar](notation.md#clause)).

**Operands and types:** An output reference-leaf place and either `owned` or `borrow(region)`. The region is `static` or `owner($slot)` for an escaping borrow; `C1` also defines `call` for uses that do not escape delivery.

**Applies to:** Valid reference leaves in results, thrown values and writable pointees, within the applicable [outcome](../glossary.md#outcome). Borrowed references loaded from globals or access-backed constants use the clause directly in the [declaration](../glossary.md#declaration) body, with `$result` denoting the loaded value.

**Required and repeatability:** Required once per valid output reference leaf in each applicable outcome, and for the borrowed global/constant case under `C7`. Repeatable by place.

**Default:** None; required where applicable.

**Meaning (non-normative; [`C5`](../contracts.md#c5), [`C7`](../contracts.md#c7)):** `owned` delivers one lifecycle obligation to the recipient. `borrow` delivers permission to use the reference within its region, with no [ownership transfer](../glossary.md#ownership-transfer). On nullable references, the annotation applies only when non-null.

**Constraints:** Each aggregate reference leaf needs its own clause. Owned pointers need a [profile](../glossary.md#profile)-defined allocator/release contract. Borrow regions survive delivery, have no lifetime cycle, and name a valid non-null object/resource when using `owner`. Every output borrow also has `invalidated_by`. Core global borrows use `static` with no earlier invalidators; ownership-changing storage needs a profile or explicit accessors ([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5), [`C7`](../contracts.md#c7)).

**Rejected when:** A valid output reference lacks ownership/borrowing, an escaping borrow uses `call`, its owner is invalid or unresolved, or pointer ownership lacks a release recipe. `N02`, `N07`, `N08`, `N31` and `N32` illustrate these cases ([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8), [mutation index](README.md#mutations)).

**Example.** Fragment — `Store`'s returned view. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s lifecycle, publication context, effects and access.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=regions -->
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

The view borrows the bytes until this call's `Store` is destroyed. In the same complete [package](../glossary.md#package), `create` instead returns an owned `Store` using `give($result, owned)`; the caller receives its destruction obligation only for a non-null result.

**Used by and see also:** [`invalidated_by`](#invalidated_by); [`state`](#state); [`input`](clauses-callable.md#input); [`lifecycle`](clauses-package.md#lifecycle); [lending tutorial](../tutorial/02-lending.md); [global output example](../contracts.md#c7).

**Rationale:** [Who owns what](../explanation/contracts.md#who-owns-what).

<a id="invalidated_by"></a>

## `invalidated_by`

**Expresses:** [Validity](../explanation/model.md#validity) — operations that end an output borrow before its region ends.

**Form:** `invalidated_by($place, [@operation, ...]);`, including an empty list ([clause grammar](notation.md#clause)).

**Operands and types:** An output borrowed-reference place and a list of operation references.

**Applies to:** Output borrows in outcomes, and borrowed global/constant values under `C7`.

**Required and repeatability:** Required once per output borrow, even for an empty list; repeatable by place.

**Default:** None; an empty list is an explicit fact.

**Meaning (non-normative; [`C5`](../contracts.md#c5)):** The borrow ends at entry to any listed operation involving its owner, as well as at region end. An empty list states that no operation invalidates it earlier.

**Constraints:** Each listed operation has an owner parameter and an appropriate mutation contract. There are no hidden earlier invalidators. Core global borrows use `static` with no earlier [invalidation](../glossary.md#invalidation) ([`C5`](../contracts.md#c5), [`C7`](../contracts.md#c7)).

**Rejected when:** The required clause is missing, a reference does not resolve, or the operation lacks the required owner association or mutation contract. A coherent list that omits an actual API invalidator is an authoring/implementation truth problem, beyond local symbolic checking ([`L2`](../language.md#l2), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `Store`'s immutable view. The complete [buffers package](../examples/buffers.ail) supplies the lifecycle, effects, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=regions -->
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

The empty list leaves `Store` destruction as the endpoint. The [lending tutorial](../tutorial/02-lending.md#5-end-earlier-borrows-when-refresh-begins) instead names `@refresh_card`, whose entry ends the old label borrow while the card remains alive.

**Used by and see also:** [`give`](#give); [`mutation`](clauses-callable.md#mutation); [region](../glossary.md#region); [global output example](../contracts.md#c7).

**Rationale:** [How long a borrow lasts](../explanation/contracts.md#how-long-a-borrow-lasts).

<a id="meaning"></a>

## `meaning`

**Expresses:** [How a call finishes](../explanation/model.md#outcomes) — the interpretation of an observable outcome.

**Form:** `meaning(success);`, `meaning(failure);`, `meaning(cancellation);` or `meaning(termination);` ([outcome grammar](notation.md#outcome)).

**Operands and types:** One of the four meaning names.

**Applies to:** Named outcomes of functions and callback declarations.

**Required and repeatability:** Required exactly once per outcome.

**Default:** None; required.

**Meaning (non-normative; [`C5`](../contracts.md#c5)):** The clause labels the case selected by `when`. A failure label preserves the operation's actual result/status observations; it does not convert a null or status return into an exception.

**Constraints:** The signature, [completion](../glossary.md#completion) partition and output states still describe the actual API. A [projection](../glossary.md#projection) that removes an observable status distinction becomes a different declaration related through an access profile. Cancellation and termination delivery require profile support ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5), [`A2`](../profiles.md#a2)).

**Rejected when:** The label is missing, duplicated or unknown, or the surrounding completion/contract is unsupported or contradictory. A failure label cannot make an invalid [discriminator](../glossary.md#discriminator) readable ([`L5`](../language.md#l5), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8); [`N12`](README.md#n12)).

**Example.** Fragment — `copy_bytes`'s two returned cases. The complete [buffers package](../examples/buffers.ail) supplies inputs, buffer bounds, effects, access, `Store` and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=outcomes -->
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

Both cases return a valid Boolean. `meaning(failure)` describes the false case; the separate destination state tells the caller that no initialized output bytes are delivered there.

**Used by and see also:** [`when`](#when); [`state`](#state); [storage tutorial](../tutorial/03-storage.md).

**Rationale:** [Every way a call can end](../explanation/contracts.md#every-way-a-call-can-end).

<a id="quiescence"></a>

## `quiescence`

**Expresses:** [Callbacks and their schedules](../explanation/model.md#callbacks) — the boundary after which no invocation runs or can begin.

**Form:** `quiescence(return);` or `quiescence(@destroy);` ([callback-use grammar](notation.md#callback-use)).

**Operands and types:** The name `return`, or a declaration reference to the unique owner's destructor.

**Applies to:** Callback-use blocks.

**Required and repeatability:** Required exactly once per callback-use block.

**Default:** None; required.

**Meaning (non-normative; [`C6`](../contracts.md#c6)):** `return` promises that all callbacks finish before registration completes. `@destroy` promises that when the destructor returns, no invocation is running or can begin, including on other threads.

**Constraints:** `return` requires `scope(call)`, `timing(during_call)` and retention `none`. Destructor quiescence requires a unique owner, its declared destructor and retention for that same owner's region. A blocking destructor requires `outside_callback` unless a profile defines a non-deadlocking reentrant destruction protocol. Separate cancellation acknowledgement or destroy-notifier events need an explicit profile ([`C6`](../contracts.md#c6)).

**Rejected when:** Quiescence is absent, uses the wrong scope/destructor, or lacks the blocking teardown precondition or a supported reentrant protocol. Cancellation return cannot stand for quiescence when callbacks may still run ([`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8); [`N16`](README.md#n16), [`N18`](README.md#n18)).

**Example.** Fragment — registration and blocking teardown. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, `Subscription`'s unique lifecycle, retention, outcomes, effects, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=callback-use -->
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

`@unsubscribe` is `Subscription`'s destructor. Its precondition prevents a callback from waiting for its own completion through that blocking destructor. Returning from `subscribe` alone does not end this owner-scoped schedule.

**Used by and see also:** [`scope`](#scope); [`requires`](clauses-callable.md#requires); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="scope"></a>

## `scope`

**Expresses:** [Callbacks and their schedules](../explanation/model.md#callbacks) — the lifetime bounding a registration's invocations.

**Form:** `scope(call);` or `scope(owner($slot));` ([callback-use grammar](notation.md#callback-use)).

**Operands and types:** The name `call`, or `owner` applied to the returned owner [slot](../glossary.md#slot), whose value is an owned object/resource.

**Applies to:** Callback-use blocks.

**Required and repeatability:** Required exactly once per callback-use block.

**Default:** None; required.

**Meaning (non-normative; [`C6`](../contracts.md#c6)):** The last possible invocation belongs to this registration call or to the returned owner's lifetime. Every successful owner-scoped registration returns the owner valid and non-null. A null/failure registration stores no callback and permits zero invocations after return.

**Constraints:** Call scope pairs with `during_call`, retention `none` and quiescence `return`. Owner scope pairs with retention for the same owner and quiescence at its destruction; core destructor quiescence requires a unique owner. The [provider](../glossary.md#provider) defines stored callback [representation](../glossary.md#representation) and release ([`C6`](../contracts.md#c6)).

**Rejected when:** The scope contradicts timing, retention or quiescence, a successful registration lacks its valid non-null owner, or the provider cannot realize storage/release. `N15` combines call scope with `after_return` ([`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8), [`N15`](README.md#n15)).

**Example.** Fragment — owner-scoped notification registration. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, the owned `Subscription` result, its lifecycle, retention and the omitted contracts/publication facts.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=callback-use -->
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

The result of this `subscribe` invocation bounds this registration. Call-scoped delivery instead finishes before the registration completes, with the companions described above.

**Used by and see also:** [`timing`](#timing); [`quiescence`](#quiescence); [`retain`](clauses-callable.md#retain); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="state"></a>

## `state`

**Expresses:** [How a call finishes](../explanation/model.md#outcomes) — which outputs may be used on each outcome.

**Form:** `state($place, valid);`, `state($place, invalid);` or `state($place, unchanged);` ([outcome grammar](notation.md#outcome)).

**Operands and types:** An output place and one state name. Writable buffers use `$p[]`; single pointees use `$p.*`.

**Applies to:** Non-unit results, thrown values and writable pointees in each applicable outcome.

**Required and repeatability:** Required exactly once per applicable output; repeatable by place. An aggregate's state covers its contents and shape recursively and excludes explicit child states.

**Default:** None; required where applicable.

**Meaning (non-normative; [`C5`](../contracts.md#c5)):** `valid` supplies usable output; `invalid` supplies output that cannot be read, freed, null-tested or used as a discriminator. `unchanged` preserves an `inout` subtree's entry contents and obligations. Reference leaves still need their individual transfer/validity clauses.

**Constraints:** Results and thrown values are valid on their corresponding completion. Results are unavailable on thrown/cancelled/terminated completion. `unchanged` applies only to `inout` storage and is forbidden when its entry obligations were consumed. Invalid output buffers convey no initialized elements; partially initialized output needs an explicit valid length. State agrees with the outcome predicate ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**Rejected when:** An applicable state is missing or duplicated, a child overrides aggregate state, an invalid output is a discriminator, or `unchanged` is used outside eligible `inout` storage. `N12` uses an invalid buffer as discriminator. `N11` instead tests a declared valid output against an implementation that does not initialize it; syntax alone cannot establish that truth ([`L5`](../language.md#l5), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8); [`N11`](README.md#n11), [`N12`](README.md#n12)).

**Example.** Fragment — copy success and failure. The complete [buffers package](../examples/buffers.ail) supplies pointer direction/extent, inputs, effects, access, `Store` and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=outcomes -->
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

The result is readable in both cases and selects the outcome. Destination bytes are readable only in `copied`. Their state describes initialized elements within the declared length, not spare capacity.

**Used by and see also:** [`give`](#give); [`when`](#when); [`extent`](clauses-callable.md#extent); [storage tutorial](../tutorial/03-storage.md).

**Rationale:** [Every way a call can end](../explanation/contracts.md#every-way-a-call-can-end).

<a id="timing"></a>

## `timing`

**Expresses:** [Callbacks and their schedules](../explanation/model.md#callbacks) — when invocations may start relative to registration.

**Form:** `timing(during_call);`, `timing(after_return);` or `timing(either);` ([callback-use grammar](notation.md#callback-use)).

**Operands and types:** One of the three timing names.

**Applies to:** Callback-use blocks.

**Required and repeatability:** Required exactly once per callback-use block.

**Default:** None; required.

**Meaning (non-normative; [`C6`](../contracts.md#c6)):** The clause permits invocation starts during the registration call, after its returned completion, or in either period. `after_return` excludes any start before returned completion.

**Constraints:** Call scope requires `during_call`, retention `none` and quiescence `return`. Owner scope needs its matching retention and destructor quiescence. Timing does not determine invocation count, executor, overlap or nested invocation. A synchronous registration can deliver callbacks after return without being an `execution(async)` operation ([`C6`](../contracts.md#c6), [`F1`](../profiles.md#f1)).

**Rejected when:** Timing is missing or incompatible with the scope/teardown contract; `N15` combines `after_return` with call scope ([`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8), [`N15`](README.md#n15)).

**Example.** Fragment — notification starts after registration. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, `Subscription` lifetime, matching retention, outcomes, effects, access and publication facts.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=callback-use -->
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

Notifications can start after `subscribe` returns. `count(0, many)` independently permits no notifications, and `quiescence` bounds their completion at teardown.

**Used by and see also:** [`scope`](#scope); [`count`](#count); [`execution`](clauses-callable.md#execution); [callback tutorial](../tutorial/04-callbacks.md).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="when"></a>

## `when`

**Expresses:** [How a call finishes](../explanation/model.md#outcomes) — the completion and observable predicate selecting an outcome.

**Form:** `when(completion, predicate);` ([outcome grammar](notation.md#outcome)).

**Operands and types:** A declared completion name (`returned`, `thrown`, `cancelled` or `terminated`) and `any`, `null($slot)`, `nonnull($slot)`, `equal($slot, literal)` or `range($slot, lowerInteger, upperInteger)`. Equality literals are integers or Booleans; ranges have inclusive integer bounds. A discriminator is the result, an `out`/`inout` scalar pointee, or `$exception` for thrown completion.

**Applies to:** Named outcomes of functions and callback declarations.

**Required and repeatability:** Required exactly once per outcome; every callable has at least one named outcome.

**Default:** None; required.

**Meaning (non-normative; [`C5`](../contracts.md#c5)):** The predicate selects an observable case of a completion. For each declared completion, outcomes partition the discriminator's entire type domain into mutually exclusive, exhaustive cases, using `L4`'s enum/flags domain where applicable.

**Constraints:** Each completion has either one `any` outcome or predicates over the same discriminator slot, valid in every outcome for that completion. Null tests require nullable reference types; ranges require integers; floating comparisons are unsupported. Every declared completion has outcomes and no other completion does. Guards do not execute native code; multiple-discriminator correlations need a profile with equally precise rules ([`C5`](../contracts.md#c5)).

**Rejected when:** Cases overlap or leave a gap, predicates use different or invalid discriminators, an operand has the wrong type, or a completion is undeclared/uncovered. `N05` removes a null case, `N06` duplicates a non-null case, and `N12` tests an invalid non-scalar buffer ([`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8); [`N05`](README.md#n05), [`N06`](README.md#n06), [`N12`](README.md#n12)).

**Example.** Fragment — the two Boolean outcomes of `copy_bytes`. The complete [buffers package](../examples/buffers.ail) supplies `Store`, inputs, bounds, effects, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=outcomes -->
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

`true` and `false` cover the whole Boolean result domain and share `$result` as discriminator. The same complete package's `create` partitions a nullable `Store` result with `nonnull($result)` and `null($result)`.

**Used by and see also:** [`meaning`](#meaning); [`state`](#state); [`completions`](clauses-callable.md#completions); [outcome block](declarations.md#outcome); [lifetime tutorial](../tutorial/01-lifetime.md).

**Rationale:** [Every way a call can end](../explanation/contracts.md#every-way-a-call-can-end).
