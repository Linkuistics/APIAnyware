# 4. Callbacks and teardown

> **Purpose:** tutorial — describe a [retained](../glossary.md#retention) [callback](../glossary.md#callback) and the boundary after which it cannot run.
> **Reader:** language designers new to [API binding](../glossary.md#binding).
> **Before this:** [3. Caller-supplied storage and failure](03-storage.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`C2–C3`](../contracts.md#c2), [`C5–C6`](../contracts.md#c5), [`A2`](../profiles.md#a2) and the synthetic catalogue [`F1`](../profiles.md#f1) are canonical.

## Goal

Add a notification subscription with a unique `Watch` owner. At the checkpoint,
identify when notifications may start and when the [caller](../glossary.md#caller-and-callee) can rely on all
invocations having stopped.

## The domain obligation

The callee keeps a stored callback alive while it
may invoke it, and the destructor reaches [quiescence](../glossary.md#quiescence)
before returning ([callback schedules and teardown](../explanation/contracts.md#callbacks)).

## Steps

1. **For each delivered notification, declare what one invocation does.**
   Add `callback LabelChanged(change: u64) -> unit`. The scalar `change`
   identifies a synthetic change notification; it carries no card or label
   ownership. The callback finishes synchronously with a successful returned
   [outcome](../glossary.md#outcome). Give it all seven callable effects, [`sharing(shared)`](../glossary.md#shared) and
   `isolation(none)`, as in the checkpoint.

   A callback that reads immutable [captured state](../glossary.md#callback-captures) and returns can satisfy
   this type. One that requires main-thread-only captured state cannot:
   `executor(any)` permits entry elsewhere. Here
   callback captures are the state held by
   the callable value. In summary (non-normative;
   [`C2–C3`](../contracts.md#c2)): the callback value and its captures allow
   every use the declaration permits; sharing alone does not authorize
   concurrent invocation. Choose `concurrency(serial)` and
   `reentrancy(forbidden)` for this example; [re-entrancy](../glossary.md#re-entrancy)
   concerns nested calls, separately from independent overlapping invocations.

   For the synthetic fixture [representation](../glossary.md#representation), add
   `callback_abi(native, "c")` and `representation(fixture, "closure")`.
   The callback has these clauses instead of a function's [access path](../glossary.md#access-path) block
   ([`A2`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

2. **For registration that lasts beyond the call, add a separate owner.**
   Declare `resource Watch` with `lifecycle(unique, @destroy_watch)`,
   `sharing(transferable)`, `isolation(none)` and the common clauses shown
   below. Add `watch_labels(handler: LabelChanged) -> Watch` with one
   successful returned outcome, a valid result and `give($result, owned)`.
   The caller receives one [owned](../glossary.md#owned) destruction obligation.
   This synthetic operation returns a non-null owner whenever it completes;
   no failure result is declared ([`C2`](../contracts.md#c2),
   [`C5`](../contracts.md#c5)).

   [Borrow](../glossary.md#borrow) `$handler` with `valid($handler, call)`, and specify an independent
   retained reference with `retain($handler, strong(owner($result)))`.
   The caller supplies a valid callback during registration; the callee's
   retained reference keeps it alive for the `Watch` lifetime. The synthetic
   fixture [provider](../glossary.md#provider) supplies retention and release
   ([`C3`](../contracts.md#c3), [`F1`](../profiles.md#f1)).
   No `Card` is passed to this operation. The subscription neither retains
   a card nor keeps a borrowed `Label` valid.

3. **For delivery after registration returns, add the use-site schedule.**
   In `callback $handler`, write `timing(after_return)`, `count(0, many)`
   and `scope(owner($result))`. Also write `executor(any)`,
   `concurrency(serial)`, `reentrancy(forbidden)` and
   `quiescence(@destroy_watch)`.

   A callback used only during a call could instead finish before that call
   returns. This registration allows later entry and needs the returned
   owner to bound it. Timing, count and lifetime are separate facts
   ([`C6`](../contracts.md#c6)); declaring a synchronous registration does
   not restrict notifications to its call. The selected count promises
   neither a first notification nor exactly-once delivery. `many` permits
   an unbounded number; it does not mean the producer left the count unknown.

4. **For teardown, consume the owner and wait for quiescence.**
   Add `destroy_watch(subscription: Watch) -> unit` with
   `input($subscription, consume)`, `retain($subscription, none)` and one
   successful returned outcome. The destructor [consumes](../glossary.md#consume) the [handle](../glossary.md#handle) at entry;
   the schedule's quiescence boundary is destructor return. During teardown
   the callee may still be finishing callbacks. After teardown returns,
   none is running or can start ([`C2`](../contracts.md#c2),
   [`C6`](../contracts.md#c6)).

5. **To exclude a teardown waiting for its own callback, add the precondition.**
   In `destroy_watch`, write
   `requires(outside_callback(@watch_labels::handler))`. A caller outside
   that callback use can request teardown. Calling from inside it would
   leave the destructor waiting for the very invocation that is waiting for
   destruction to finish. `reentrancy(forbidden)` is a separate restriction;
   it does not replace this explicit precondition
   ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).
   The synthetic fixture supplies no alternative reentrant teardown protocol.
   The contracts do not promise that a callback or the destructor eventually
   returns ([`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8)).

6. **To publish the expanded subset, include the four new declarations.**
   Extend `surface` and `exports`, retain the earlier declarations unchanged,
   and give both new functions complete synthetic symbol paths
   ([`L3`](../language.md#l3), [`A2`](../profiles.md#a2)).

## Checkpoint package

The synthetic fixture [profile](../glossary.md#profile), catalogue and [digest tokens](../glossary.md#digest-pin) are defined by
[`F1`](../profiles.md#f1). Compare your work with the complete
[subscription checkpoint](../examples/tutorial/04-callbacks.ail).

Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: ../examples/tutorial/04-callbacks.ail region=checkpoint -->
```ail
language "0.1";
package tutorial::callbacks version "1" {
  surface("Synthetic label-card API release 1: Card lifetime, label lending, refresh, text copying and independent label-change notifications; other operations excluded.");
  exports([@Card, @create_card, @destroy_card, @Label, @destroy_label, @current_label, @refresh_card, @CopyStatus, @copy_text, @Watch, @LabelChanged, @watch_labels, @destroy_watch]);
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
  environment test {
    target("fixture64");
    platform("fixture", "1");
  }
  resource Card {
    available([test]);
    deprecated(no);
    implements([]);
    lifecycle(unique, @destroy_card);
    sharing(transferable);
    isolation(none);
    doc("Owns its current label; refresh replaces that label.");
  }
  fn create_card() -> nullable<Card> {
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
      via(fixture, "symbol", "fixture_create_card");
      mapping(identity);
      compatibility(stable);
    }
  }
  fn destroy_card(card: Card) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    input($card, consume);
    retain($card, none);
    outcome done {
      when(returned, any);
      meaning(success);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_destroy_card");
      mapping(identity);
      compatibility(stable);
    }
  }
  resource Label {
    available([test]);
    deprecated(no);
    implements([]);
    lifecycle(unique, @destroy_label);
    sharing(transferable);
    isolation(none);
    doc("A label of seven nonzero UTF-8 code units; an owned Label is an independent snapshot.");
  }
  fn destroy_label(label: Label) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    input($label, consume);
    retain($label, none);
    outcome done {
      when(returned, any);
      meaning(success);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_destroy_label");
      mapping(identity);
      compatibility(stable);
    }
  }
  fn current_label(card: Card) -> Label {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(allowed);
    mutation(none);
    variadic(false);
    input($card, borrow);
    retain($card, none);
    valid($card, call);
    outcome lent {
      when(returned, any);
      meaning(success);
      state($result, valid);
      give($result, borrow(owner($card)));
      invalidated_by($result, [@refresh_card]);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_current_label");
      mapping(identity);
      compatibility(stable);
    }
  }
  fn refresh_card(card: Card) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(allowed);
    mutation(arguments);
    variadic(false);
    input($card, borrow);
    retain($card, none);
    valid($card, call);
    outcome done {
      when(returned, any);
      meaning(success);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_refresh_card");
      mapping(identity);
      compatibility(stable);
    }
  }
  enum CopyStatus: i32 {
    available([test]);
    deprecated(no);
    values(closed);
    sharing(value);
    isolation(none);
    case copied = 0;
    case unavailable = 1;
  }
  fn copy_text(label: Label, destination: mutptr<u8>) -> CopyStatus {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(allowed);
    mutation(arguments);
    variadic(false);
    input($label, borrow);
    retain($label, none);
    valid($label, call);
    input($destination, borrow);
    retain($destination, none);
    valid($destination, call);
    direction($destination, out);
    aliasing($destination, disjoint);
    extent($destination, buffer(7, 8, elements));
    contents($destination, text("utf-8", nul));
    outcome copied {
      when(returned, equal($result, 0));
      meaning(success);
      state($result, valid);
      state($destination[], valid);
    }
    outcome unavailable {
      when(returned, equal($result, 1));
      meaning(failure);
      state($result, valid);
      state($destination[], invalid);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_copy_text");
      mapping(identity);
      compatibility(stable);
    }
  }
  resource Watch {
    available([test]);
    deprecated(no);
    implements([]);
    lifecycle(unique, @destroy_watch);
    sharing(transferable);
    isolation(none);
  }
  callback LabelChanged(change: u64) -> unit {
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
  fn watch_labels(handler: LabelChanged) -> Watch {
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
      quiescence(@destroy_watch);
    }
    outcome registered {
      when(returned, any);
      meaning(success);
      state($result, valid);
      give($result, owned);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_watch_labels");
      mapping(identity);
      compatibility(stable);
    }
  }
  fn destroy_watch(subscription: Watch) -> unit {
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
    requires(outside_callback(@watch_labels::handler));
    outcome stopped {
      when(returned, any);
      meaning(success);
      doc("No callback is running or can start after this completion.");
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_destroy_watch");
      mapping(identity);
      compatibility(stable);
    }
  }
}
```

## Expected observations

In summary (non-normative; [`C2–C3`](../contracts.md#c2),
[`C5–C6`](../contracts.md#c5)):

- `LabelChanged` describes one invocation. `callback $handler` describes
  when this registration can invoke it. The scalar parameter needs no
  ownership clause.
- `execution(sync)` on `watch_labels` coexists with `timing(after_return)`:
  registration completes before returning, and any notifications start later.
- The callee strongly retains the callback in the returned owner's [region](../glossary.md#region).
  `input(borrow)` transfers none of the caller's existing ownership.
- `destroy_watch` consumes the unique owner at entry. Its return establishes
  quiescence, so neither returning from registration nor merely starting
  destruction establishes the same fact.
- The callback declaration also constrains independent registrations. Its
  serial contract still applies if the same callback value is registered twice.
- Nothing in this subscription changes `current_label`'s owner region or
  its refresh invalidation. A notification conveys a number, not a new label
  borrow or an owned label.

## Check yourself

1. Can `LabelChanged` run before `watch_labels` returns?
2. If no notification arrives before destruction, is the count contract broken?
3. Can a notification handler destroy its watch because calls are serial?

### Answers

1. No. `timing(after_return)` excludes earlier invocation starts
   ([`C6`](../contracts.md#c6)).
2. No. `count(0, many)` permits zero over the registration's whole scope,
   conditional on that scope eventually ending ([`C6`](../contracts.md#c6)).
3. No. Serial invocation does not discharge `outside_callback`. The handler
   is inside the callback use that teardown excludes
   ([`C3`](../contracts.md#c3), [`C6`](../contracts.md#c6)).

## Invalid variant

In `watch_labels`, replace only the callback-use block's `quiescence` clause
with the following clause, leaving its owner scope in place.

Invalid — rejected under [`C6`](../contracts.md#c6).

<!-- ail-fragment -->
```ail
quiescence(return);
```

Quiescence at registration return requires call scope. The retained,
owner-scoped schedule instead names its unique owner's destructor.

Return: [Describing a small API](README.md).
Next: [5. Reaching the code, and changing the contract](05-access-and-change.md).
