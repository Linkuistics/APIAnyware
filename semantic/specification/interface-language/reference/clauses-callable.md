# Callable effects and input clauses

> **Purpose:** reference — look up call conditions, input obligations, buffers and strings.
> **Reader:** reviewers, API authors and tool implementers checking an exact draft 0.1 fact.
> **Before this:** [Operations and their values](../explanation/model.md#operations), [declarations and blocks](declarations.md), and [entry conventions](notation.md#entry-conventions).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L5`](../language.md#l5), [`C1–C8`](../contracts.md#c1) and the cited [provider rules](../profiles.md) are canonical. These entries are non-normative summaries.

Entries are alphabetical. The [model-concept index](README.md#model-concepts)
starts from the fact you need to record; the [applicability table](declarations.md#applicability)
starts from the enclosing [declaration](../glossary.md#declaration). Forms use the [`clause` and `constructor`
productions](notation.md#clause). [`fn` and callback declarations](notation.md#callable)
describe an invocation; a [callback-use block](notation.md#callback-use)
describes the API's use of a supplied [callable](../glossary.md#callable).

A [place](../glossary.md#place), such as `$store` or `$value.*`, identifies the
value or storage a [clause](../glossary.md#clause) concerns. A [reference leaf](../glossary.md#reference-leaf)
can occur inside an aggregate as well as directly in a parameter. A
[region](../glossary.md#region) bounds how long a reference remains usable or
stored. A [profile](../glossary.md#profile) supplies the additional semantics
explicitly required by an entry; [`F1`](../profiles.md#f1) is the synthetic
catalogue used by the examples.

In summary (non-normative; [`L1`](../language.md#l1), [`L5`](../language.md#l5),
[`C8`](../contracts.md#c8)): unknown vocabulary, wrong operand types, invalid
places, clauses outside their scope, duplicate singular clauses and missing
applicable facts are rejected. Place-keyed clauses allow one instance per
applicable place in their scope. The rejection fields below add the conditions
specific to each entry; examples are fragments, with omitted context named.

<a id="aliasing"></a>

## `aliasing`

**Expresses:** [Storage](../explanation/model.md#storage) — whether a pointer's storage may overlap other memory accessed by the call.

**Form:** `aliasing($pointer, disjoint);` or `aliasing($pointer, may_alias);` ([clause grammar](notation.md#clause)).

**Operands and types:** A pointer-parameter place and an aliasing policy.

**Applies to:** Pointer parameters in function and [callback](../glossary.md#callback) declarations.

**Required and repeatability:** Required once per pointer parameter; repeatable by place.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3)):** `disjoint` requires the caller to supply storage that does not overlap other accessed memory for this call. `may_alias` permits aliasing supported by the access [provider](../glossary.md#provider).

**Constraints:** `may_alias` needs provider support. Both policies preserve the prohibition on concurrent data races, including races through unrelated raw aliases ([`C3`](../contracts.md#c3)).

**Rejected when:** The applicable clause is missing or the provider cannot support `may_alias` ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `copy_bytes`'s destination contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`, its input, remaining effects, outcomes, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=pointers -->
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

`disjoint` keeps the destination separate from `Store`'s source bytes and any other memory this call accesses. The writable destination and its size are stated independently.

**Used by and see also:** [`direction`](#direction); [`extent`](#extent); [`concurrency`](#concurrency); [buffer tutorial](../tutorial/03-storage.md).

**Rationale:** [Buffers and strings](../explanation/contracts.md#buffers-and-strings).

<a id="completions"></a>

## `completions`

**Expresses:** [How a call finishes](../explanation/model.md#outcomes) — the possible modes of [completion](../glossary.md#completion).

**Form:** `completions([returned, thrown, cancelled, terminated]);` with the applicable subset ([clause grammar](notation.md#clause)).

**Operands and types:** One nonempty, duplicate-free list of completion names from that set.

**Applies to:** Function and callback declarations.

**Required and repeatability:** Required exactly once per callable.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)):** The list states how an invocation can finish. Each listed mode has outcomes describing its observable cases. The list supplies no guarantee that the call eventually finishes.

**Constraints:** `thrown` appears exactly when the signature has `throws T`. Cancellation and termination require profile-defined delivery or observation and cleanup. Outcomes cover every declared completion and use no undeclared completion. `F1` supports only non-throwing synchronous callable entry ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5), [`F1`](../profiles.md#f1)).

**Rejected when:** The list is empty, repeats a mode, disagrees with `throws`, lacks required provider semantics, or disagrees with the [outcome](../glossary.md#outcome) coverage ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `view`'s invocation contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`, the pointer result's obligations, outcome, access and publication facts.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=effects -->
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

`view` permits returned completion. Its complete declaration has a successful returned outcome; a separate operation could distinguish success and failure within that same completion mode.

**Used by and see also:** [`execution`](#execution); [outcome](declarations.md#outcome); [completion](../glossary.md#completion).

**Rationale:** [Every way a call can end](../explanation/contracts.md#every-way-a-call-can-end).

<a id="concurrency"></a>

## `concurrency`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — permission for independent calls to overlap.

**Form:** `concurrency(serial);` or `concurrency(parallel);` ([clause grammar](notation.md#clause)).

**Operands and types:** One [concurrency](../glossary.md#concurrency) policy.

**Applies to:** Function and callback declarations; callback-use blocks.

**Required and repeatability:** Required exactly once in each applicable scope.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)):** On a callable, `serial` requires callers to keep independent calls using the same mutable storage or receiver/resource from overlapping. `parallel` permits independent overlap subject to buffer rules. In a callback-use block, the policy governs independent invocations of that registration.

**Constraints:** Independent registrations also obey the callback declaration's concurrency contract. Nested calls have a separate [`reentrancy`](#reentrancy) policy; allowed nested re-entry is excluded from the serial prohibition. Neither concurrency value permits races through unrelated raw aliases ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).

**Rejected when:** The clause is missing in either required scope or the registration's permissions contradict the callback declaration ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8)).

**Example.** Fragment — a callback registration and its teardown. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`'s invocation contract, `Subscription`'s lifetime, input [retention](../glossary.md#retention), outcomes, access and publication context.

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

The API keeps independent invocations of this registration's handler from overlapping. `Handler`'s declaration also uses `serial`, governing calls across registrations. The separate `reentrancy(forbidden)` clause addresses nested invocation.

**Used by and see also:** [`executor`](#executor); [`reentrancy`](#reentrancy); [callback use](declarations.md#callback-use); [concurrency](../glossary.md#concurrency).

**Rationale:** [Threads and sharing](../explanation/contracts.md#threads-and-sharing).

<a id="contents"></a>

## `contents`

**Expresses:** [Storage](../explanation/model.md#storage) — whether pointed-to data is binary or encoded text.

**Form:** `contents($pointer, binary);`, `contents($pointer, text("encoding", none));` or `contents($pointer, text("encoding", nul));` ([clause grammar](notation.md#clause)).

**Operands and types:** A pointer place and either `binary` or a `text` constructor containing an encoding string and termination policy.

**Applies to:** Pointer parameters; other pointer slots whose pointees are byte/integer character storage. Result clauses belong to the callable body. Pointer-typed globals and accessed constants follow `C7`'s output rules.

**Required and repeatability:** Required once per applicable pointer place; repeatable by place.

**Default:** None where applicable; the author supplies the interpretation.

**Meaning (non-normative; [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5), [`C7`](../contracts.md#c7)):** `binary` has no terminator requirement. `text` names the encoding and whether a final zero code unit terminates it. The access profile defines encoding identifiers and code-unit widths.

**Constraints:** For `nul`, length excludes the final zero, capacity includes it, `length + 1 <= capacity`, and embedded zero code units are forbidden. Extent, direction, pointer mutability and mutation agree. Scanning for a terminator as the sole extent determination requires a profile-defined scanned-buffer contract ([`C4`](../contracts.md#c4)).

**Rejected when:** An applicable clause is absent, the provider does not define the encoding, or termination, extent or writable-storage requirements conflict ([`C4`](../contracts.md#c4), [`C8`](../contracts.md#c8)).

**Example.** Fragment — a constructed text input. A complete [package](../glossary.md#package) also supplies header, pinned providers, [environment](../glossary.md#environment)/publication context, effects, successful returned outcome and access.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=text -->
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

`F1` supplies `utf-8`. Three text code units occupy the first three bytes, and a zero occupies the fourth. With `text("utf-8", none)`, the length would delimit text without a required terminator; with `binary`, zero bytes would be ordinary data.

**Used by and see also:** [`extent`](#extent); [`direction`](#direction); [contents](../glossary.md#contents); [buffer tutorial](../tutorial/03-storage.md).

**Rationale:** [Buffers and strings](../explanation/contracts.md#buffers-and-strings).

<a id="direction"></a>

## `direction`

**Expresses:** [Storage](../explanation/model.md#storage) — which pointee contents the callee reads or writes.

**Form:** `direction($pointer, in);`, `direction($pointer, out);` or `direction($pointer, inout);` ([clause grammar](notation.md#clause)).

**Operands and types:** A pointer-parameter place and a direction value.

**Applies to:** Pointer parameters in function and callback declarations.

**Required and repeatability:** Required once per pointer parameter; repeatable by place.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3)):** `in` supplies readable storage, `out` supplies writable output storage whose old contents are not read, and `inout` supplies both. The pointer itself remains valid for the call.

**Constraints:** `out` and `inout` buffers use `mutptr`; direction agrees with mutation and extent. Input obligations cover reference leaves read from `in`/`inout` storage. New references written to writable storage have outcome obligations; an `out` pointee has no initialized old value to consume ([`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5)).

**Rejected when:** The clause is absent, writable output uses `ptr` (`N13`), or the direction conflicts with the input/output, mutation or extent contract ([`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5)).

**Example.** Fragment — `copy_bytes`'s destination. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s input, remaining effects, outcomes, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=pointers -->
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

The caller supplies writable storage. `out` prevents reading its old contents; a successful outcome makes the sixteen written elements valid. The failure outcome marks them invalid.

**Used by and see also:** [`input`](#input); [`mutation`](#mutation); [`extent`](#extent); [output states](../contracts.md#c5); [`N13`](../conformance.md#rejection-mutations).

**Rationale:** [Buffers and strings](../explanation/contracts.md#buffers-and-strings).

<a id="execution"></a>

## `execution`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — the invocation's completion relationship to return of control.

**Form:** `execution(sync);` or `execution(async);` ([clause grammar](notation.md#clause)).

**Operands and types:** One execution mode.

**Applies to:** Function and callback declarations.

**Required and repeatability:** Required exactly once per callable.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3)):** `sync` completes before control returns to the caller. `async` requires a profile defining suspension, scheduling and completion delivery.

**Constraints:** Core semantics alone cannot lower `async`. A callback declaration states the execution mode of one invocation; its registration's later invocation schedule is expressed separately. `F1` permits owner-scoped callbacks after registration returns while supporting only synchronous callable entry ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`F1`](../profiles.md#f1)).

**Rejected when:** The clause is missing or `async` lacks a supporting provider (`N30`) ([`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8), [`F1`](../profiles.md#f1)).

**Example.** Fragment — `view`'s invocation contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`, result obligations, outcome, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=effects -->
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

`view` uses synchronous entry. Changing that clause to `async` would require additional provider semantics; its existing fixture providers cannot supply them.

**Used by and see also:** [`completions`](#completions); [callback use](declarations.md#callback-use); [`N30`](../conformance.md#rejection-mutations).

**Rationale:** [Threads and sharing](../explanation/contracts.md#threads-and-sharing); [callbacks](../explanation/contracts.md#callbacks).

<a id="executor"></a>

## `executor`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — where entry is permitted.

**Form:** `executor(any);`, `executor(main);` or `executor(executor(profileAlias, "identity"));` ([clause and constructor grammar](notation.md#clause)).

**Operands and types:** `any`, `main`, or an `executor` constructor naming a declared profile alias and its [executor](../glossary.md#executor)-identity string.

**Applies to:** Function and callback declarations; callback-use blocks.

**Required and repeatability:** Required exactly once in each applicable scope.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)):** The clause identifies allowed entry executors. `any` permits any thread/executor. In a callback-use block it identifies where that registration's callbacks enter.

**Constraints:** Callback-use entry agrees with the callback declaration. Members respect nominal [isolation](../glossary.md#isolation) unless a profile justifies an exception. Use of a confined reference, including through a free function, requires its executor unless a profile defines a legal transfer protocol. `any` supplies no permission for simultaneous calls ([`C2`](../contracts.md#c2), [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).

**Rejected when:** The clause is missing, the named provider/executor is unsupported, or entry permissions conflict with isolation, confinement or the callback declaration ([`L2`](../language.md#l2), [`C2`](../contracts.md#c2), [`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8), [`A1`](../profiles.md#a1)).

**Example.** Fragment — `view`'s invocation contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s nominal contract, result obligations, outcome, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=effects -->
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

`any` allows entry from any executor, while `serial` restricts independent overlap. The [callback-use example](#concurrency) uses the same executor form in a registration's schedule.

**Used by and see also:** [`isolation`](clauses-package.md#isolation); [`sharing`](clauses-package.md#sharing); [`concurrency`](#concurrency); [executor](../glossary.md#executor).

**Rationale:** [Threads and sharing](../explanation/contracts.md#threads-and-sharing).

<a id="extent"></a>

## `extent`

**Expresses:** [Storage](../explanation/model.md#storage) — how much pointed-to storage exists and how much is initialized.

**Form:** `extent($pointer, one);` or `extent($pointer, buffer(length, capacity, bytes));`, with `elements` as the other unit ([clause grammar](notation.md#clause)).

**Operands and types:** A pointer-leaf place; `one` or a `buffer` constructor. Length and capacity are nonnegative integer literals or integral scalar slots. The final operand is `bytes` or `elements`.

**Applies to:** Every pointer leaf, including returned and nested pointers. Result clauses belong to the callable body; pointer-typed globals and accessed constants follow `C7`'s output rules.

**Required and repeatability:** Required once per pointer leaf; repeatable by place.

**Default:** None; required.

**Meaning (non-normative; [`C1`](../contracts.md#c1), [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5), [`C7`](../contracts.md#c7)):** `one` describes storage for exactly one pointee. A buffer's capacity describes allocated storage and its length describes readable initialized data. Element contracts cover the initialized length.

**Constraints:** Length and capacity are valid at input entry or on every output outcome claiming validity; `0 <= length <= capacity`. Element-size multiplication fits the provider's address space. Positive capacity requires allocated, aligned storage even at zero length; a non-null zero-capacity buffer needs no dereferenceable storage. A null pointer has zero length/capacity. Input `out` buffers need no initialized entry elements; valid output initializes the declared length. `.*` addresses `one` storage and `[]` addresses buffer elements ([`C1`](../contracts.md#c1), [`C4`](../contracts.md#c4)).

**Rejected when:** The extent is missing, a size operand is invalid, literal length exceeds capacity (`N14`), a storage path uses the wrong extent form, or required storage/size relationships contradict the contract. Dynamic sizes retain the runtime inequality obligation; a syntax check cannot establish runtime values ([`C1`](../contracts.md#c1), [`C4`](../contracts.md#c4); [`N14` qualifications](../conformance.md#rejection-mutations)).

**Example.** Fragment — a text input with an explicit bound. A complete package also supplies header, providers, environments, effects, successful returned outcome, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=text -->
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

The buffer has three text code units and room for four, including its zero terminator. `buffer(0, 4, elements)` would still require four allocated bytes; `buffer(0, 0, elements)` could use a non-null pointer with no dereferenceable storage.

**Used by and see also:** [`contents`](#contents); [`direction`](#direction); [pointer types](types.md#pointers); [buffer extent](../glossary.md#buffer-extent).

**Rationale:** [Buffers and strings](../explanation/contracts.md#buffers-and-strings).

<a id="input"></a>

## `input`

**Expresses:** [Release responsibility](../explanation/model.md#responsibility) — whether an existing owned obligation transfers at entry.

**Form:** `input($slot, borrow);` or `input($slot, consume);` ([clause grammar](notation.md#clause)).

**Operands and types:** An input reference-leaf place and a transfer policy.

**Applies to:** Reference leaves in function/callback inputs, including those inside by-value aggregates and those read from `in`/`inout` pointee storage. An `out` pointee's uninitialized contents have no input obligation.

**Required and repeatability:** Required once per input reference leaf; repeatable by place. Copyable scalar/value input passes by value without this clause.

**Default:** None where applicable; required.

**Meaning (non-normative; [`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3)):** `borrow` transfers no ownership obligation. `consume` transfers one owned obligation to the callee at entry on every outcome. Null carries no obligation.

**Constraints:** A consumed obligation belongs to the callee until discharged according to [lifecycle](../glossary.md#lifecycle) or returned through an outcome. Consumption alone implies no mutation. For `inout` replacement, old input and new output ownership are both explicit; a consumed subtree cannot have [`state(unchanged)`](clauses-outcomes.md#state). Returning the same reference needs `state(valid)` and [`give(owned)`](clauses-outcomes.md#give) ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**Rejected when:** An applicable input contract is absent, duplicated for the same place (`N20`), applied to an unsuitable place, or contradicted by the output contract ([`L5`](../language.md#l5), [`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**Example.** Fragment — `Store` and its consuming destructor. The complete [buffers package](../examples/buffers.ail) supplies publication facts, remaining callable effects, the successful returned outcome and access.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=lifecycle -->
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

`destroy` takes `Store`'s one destruction obligation at entry. In contrast, `view` in the [validity example](#valid) borrows `Store` and leaves that obligation with the caller.

**Used by and see also:** [`retain`](#retain); [`valid`](#valid); [`lifecycle`](clauses-package.md#lifecycle); [`N20`](../conformance.md#rejection-mutations).

**Rationale:** [Who owns what](../explanation/contracts.md#who-owns-what).

<a id="mutation"></a>

## `mutation`

**Expresses:** [Validity](../explanation/model.md#validity) — which input state may change, including changes associated with early [borrow](../glossary.md#borrow) [invalidation](../glossary.md#invalidation).

**Form:** `mutation(none);`, `mutation(receiver);`, `mutation(arguments);` or `mutation(receiver_and_arguments);` ([clause grammar](notation.md#clause)).

**Operands and types:** One mutation classification.

**Applies to:** Function and callback declarations.

**Required and repeatability:** Required exactly once per callable.

**Default:** None; required. The explicit `none` value states absence of externally visible input mutation.

**Meaning (non-normative; [`C3`](../contracts.md#c3)):** The clause classifies which externally visible input state may change. Writing `out` parameters counts as argument mutation. Private implementation state and reference-count increments are outside this classification.

**Constraints:** Mutation agrees with pointer constness, direction and extent. Consumption/destruction and the resulting end of borrows are described by transfer/lifecycle. An operation named by [`invalidated_by`](clauses-outcomes.md#invalidated_by) has an owner parameter and an appropriate mutation contract ([`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5)).

**Rejected when:** The clause is missing, contradicts the declared writable-storage contract, or cannot support its stated invalidation relation ([`C3`](../contracts.md#c3), [`C4`](../contracts.md#c4), [`C5`](../contracts.md#c5), [`C8`](../contracts.md#c8)).

**Example.** Fragment — the destination contract for `copy_bytes`. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s input, remaining effects, outcomes, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=pointers -->
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

Writing destination elements is an externally visible argument change. `Store`'s destruction instead uses transfer and lifecycle; it needs no additional mutation merely to discharge the consumed obligation.

**Used by and see also:** [`direction`](#direction); [`input`](#input); [invalidation rules](../contracts.md#c5); [lending tutorial](../tutorial/02-lending.md#5-end-earlier-borrows-when-refresh-begins).

**Rationale:** [How long a borrow lasts](../explanation/contracts.md#how-long-a-borrow-lasts).

<a id="reentrancy"></a>

## `reentrancy`

**Expresses:** [Where and when calls run](../explanation/model.md#execution) — permission for a call nested under an active invocation.

**Form:** `reentrancy(allowed);` or `reentrancy(forbidden);` ([clause grammar](notation.md#clause)).

**Operands and types:** One nested-entry policy.

**Applies to:** Function and callback declarations; callback-use blocks.

**Required and repeatability:** Required exactly once in each applicable scope.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)):** On a callable, the clause governs whether control nested under an active API call may enter this operation on the same receiver/resource before the earlier call completes, including through synchronous callbacks. In a callback-use block it governs invocation nested inside an earlier invocation of that registration.

**Constraints:** Independent overlap is governed separately by `concurrency`. A blocking destructor with [quiescence](../glossary.md#quiescence) needs an `outside_callback` precondition unless a profile specifies a non-deadlocking reentrant destruction protocol. `allowed` alone supplies no such protocol ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).

**Rejected when:** A required clause is missing, the registration contradicts its callback declaration, or blocking teardown lacks the required precondition/provider protocol (`N18`) ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8)).

**Example.** Fragment — `view`'s invocation contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`, result obligations, outcome, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=effects -->
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

The combination `serial` and `allowed` permits nested re-entry while excluding independent overlap on the same `Store`. The [callback-use example](#concurrency) instead forbids nested invocations of its registration.

**Used by and see also:** [`concurrency`](#concurrency); [`requires`](#requires); [re-entrancy](../glossary.md#re-entrancy); [`N18`](../conformance.md#rejection-mutations).

**Rationale:** [Threads and sharing](../explanation/contracts.md#threads-and-sharing).

<a id="requires"></a>

## `requires`

**Expresses:** [Callbacks and their schedules](../explanation/model.md#callbacks) — an entry restriction used for safe teardown; the capability form also restricts calls to optional members.

**Form:** `requires(capability(@optionalMember, $receiver));` or `requires(outside_callback(@operation::parameter));` ([clause grammar](notation.md#clause)).

**Operands and types:** One precondition constructor. `capability` takes an optional interface-[member](../glossary.md#member) reference and the receiver place. `outside_callback` takes the qualified [slot](../glossary.md#slot) reference identifying a callback use.

**Applies to:** Callable entry preconditions.

**Required and repeatability:** Repeatable. Optional-member calls require the capability test. Blocking quiescent destruction requires `outside_callback` unless a profile defines a non-deadlocking reentrant protocol.

**Default:** No implicit precondition replaces either required case.

**Meaning (non-normative; [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)):** `capability` requires a profile-defined runtime test establishing that this receiver implements the optional member. `outside_callback` requires the call to occur outside an invocation of the specified callback use.

**Constraints:** Platform [availability](../glossary.md#availability) cannot establish receiver capability. References identify the particular member/receiver or callback use; names alone imply no teardown exception. `F1` does not support optional interface members ([`L5`](../language.md#l5), [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`F1`](../profiles.md#f1)).

**Rejected when:** A required precondition is missing (`N18` for teardown), its references do not resolve or type-check, or the required capability test/reentrant protocol lacks provider support ([`L2`](../language.md#l2), [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8)).

**Example.** Fragment — registration and blocking teardown. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, `Subscription`, retention, callable contracts, access and publication context.

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

`@subscribe::handler` identifies the callback use whose running invocation could otherwise wait on itself through `unsubscribe`. The requirement belongs to the operation being restricted.

**Example.** Fragment — a hypothetical optional interface member. A complete description also needs `Panel`'s nominal contracts, publication facts, callable contracts and a provider defining the runtime test and access; `F1` cannot supply that provider.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=capability -->
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

`capability(@redraw, $panel)` concerns this `Panel` receiver. The declaration's environment availability, supplied in a complete package, answers a separate question.

**Used by and see also:** [`requirement`](clauses-package.md#requirement); [callback use](declarations.md#callback-use); [teardown tutorial](../tutorial/04-callbacks.md#8-require-teardown-from-outside-the-callback); [`N18`](../conformance.md#rejection-mutations).

**Rationale:** [Callbacks](../explanation/contracts.md#callbacks).

<a id="retain"></a>

## `retain`

**Expresses:** [Release responsibility](../explanation/model.md#responsibility) — the callee's storage of a reference beyond immediate use.

**Form:** `retain($slot, none);` or `retain($slot, strong(region));`, with `copy`, `weak` and `unretained` as the other storage constructors ([clause grammar](notation.md#clause)).

**Operands and types:** An input reference-leaf place and a storage policy. Each policy other than `none` takes a region: `call`, `static` or `owner($slot)` under `C1`.

**Applies to:** Every input reference leaf in function/callback declarations, including leaves in aggregates and those read from `in`/`inout` storage.

**Required and repeatability:** Required once per input reference leaf, independently of `input`; repeatable by place.

**Default:** None; required. Explicit `none` promises no retention.

**Meaning (non-normative; [`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3)):** `strong` creates an independent ownership obligation. `copy` creates a profile-defined semantic copy. `weak` stores a zeroing reference; `unretained` stores a non-owning, non-zeroing reference whose referent the caller keeps alive for the storage region.

**Constraints:** Unique resources need an explicit clone profile for strong retention or copying. An output-owner region takes effect only on outcomes returning that owner non-null and valid; other outcomes allow only call-scoped temporary storage and discharge temporary retained/copied references before completion. This does not undo entry consumption. Owner-scoped callback use retains for that same owner region; call scope uses `none`. `F1` supports strong retention of callback values but no `copy` ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`F1`](../profiles.md#f1)).

**Rejected when:** The applicable clause is missing, the region is invalid or cyclic, or lifecycle, callback scope or provider support cannot satisfy the policy ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6), [`C8`](../contracts.md#c8)).

**Example.** Fragment — retaining a callback during subscription. The complete [callbacks package](../examples/callbacks.ail) supplies `Handler`, `Subscription`'s unique lifetime, schedule, owned result outcome, effects, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=retention -->
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

The caller lends `Handler` at entry and retains its original obligation. The callee creates a separate reference lasting through the returned `Subscription`'s lifetime. `valid($handler, call)` covers the caller's initial loan.

**Used by and see also:** [`input`](#input); [`valid`](#valid); [`storage`](clauses-package.md#storage); [retention](../glossary.md#retention); [callback tutorial](../tutorial/04-callbacks.md#5-keep-the-handler-for-later-notifications).

**Rationale:** [Who owns what](../explanation/contracts.md#who-owns-what).

<a id="valid"></a>

## `valid`

**Expresses:** [Validity](../explanation/model.md#validity) — the caller's lifetime guarantee for a borrowed input.

**Form:** `valid($slot, call);`, `valid($slot, static);` or `valid($slot, owner($owner));` ([clause grammar](notation.md#clause)).

**Operands and types:** A borrowed input reference-leaf place and a region. An `owner` operand names a non-null object/resource slot valid on the relevant outcome.

**Applies to:** Borrowed input reference leaves in function/callback declarations, including aggregate leaves and references read from `in`/`inout` storage.

**Required and repeatability:** Required once per borrowed input reference leaf; repeatable by place. Consumed inputs require validity at entry; their subsequent lifetime follows lifecycle and retention.

**Default:** None where applicable; required.

**Meaning (non-normative; [`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3)):** The caller guarantees usability for the stated region. `call` runs from entry through completion, including synchronous callbacks. `static` lasts for the loaded API instance; `owner` ends at owner destruction or final release.

**Constraints:** The provider defines shutdown for `static`. Owner dependencies are acyclic. For unretained storage the caller keeps the referent alive for the full storage region. Output borrows use [`give`](clauses-outcomes.md#give) and a region surviving delivery; their validity is a separate exit obligation ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**Rejected when:** A borrowed input lacks its clause, a place does not resolve or type-check, an owner is unsuitable, dependencies are cyclic, or the guarantee cannot cover the unretained storage period ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8)).

**Example.** Fragment — the input and returned borrow for `view`. The complete [buffers package](../examples/buffers.ail) supplies `Store`'s lifetime, callable effects, availability, access and publication context.

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

The caller keeps `Store` usable during `view`. The returned pointer's borrow lasts until `Store`'s lifetime ends, as stated separately by `give($result, borrow(owner($store)))`.

**Used by and see also:** [`input`](#input); [`retain`](#retain); [region](../glossary.md#region); [lending tutorial](../tutorial/02-lending.md#3-keep-the-input-card-usable-during-the-call).

**Rationale:** [How long a borrow lasts](../explanation/contracts.md#how-long-a-borrow-lasts).

<a id="variadic"></a>

## `variadic`

**Expresses:** [Operations and their values](../explanation/model.md#operations) — whether arguments extend beyond the fixed signature.

**Form:** `variadic(false);` or `variadic(true);` ([clause grammar](notation.md#clause)).

**Operands and types:** One Boolean value.

**Applies to:** Function and callback declarations.

**Required and repeatability:** Required exactly once per callable.

**Default:** None; required.

**Meaning (non-normative; [`C3`](../contracts.md#c3)):** `false` supplies the complete core non-variadic contract. `true` requires a profile specifying the argument schema, promotions and termination.

**Constraints:** The provider supplies the additional argument rules needed by `true`; `F1` supports only non-variadic signatures ([`C3`](../contracts.md#c3), [`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

**Rejected when:** The clause is missing or `true` lacks the required provider semantics ([`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8), [`F1`](../profiles.md#f1)).

**Example.** Fragment — `view`'s invocation contract. The complete [buffers package](../examples/buffers.ail) supplies `Store`, result obligations, outcome, access and publication context.

<!-- ail-example: ../examples/rule-reading/contracts.ail region=effects -->
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

`false` fixes `view`'s input to the one declared `Store` parameter. Changing it to `true` would require a provider-defined argument contract beyond this fixture's capabilities.

**Used by and see also:** [function](declarations.md#fn); [callback](declarations.md#callback); [`execution`](#execution).

**Rationale:** [From signature to contract](../explanation/contracts.md#from-signature-to-contract); [extending the language with profiles](../explanation/contracts.md#extending-the-language-with-profiles).
