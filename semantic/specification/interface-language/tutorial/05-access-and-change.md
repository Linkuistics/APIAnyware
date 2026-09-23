# 5. Reaching the code, and changing the contract

> **Purpose:** tutorial — read the finished [package](../glossary.md#package)'s [access paths](../glossary.md#access-path) and change a [borrowed](../glossary.md#borrow) label into an [owned](../glossary.md#owned) snapshot.
> **Reader:** language designers new to [API binding](../glossary.md#binding).
> **Before this:** [4. Callbacks and teardown](04-callbacks.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L2–L5`](../language.md#l2), [`C1–C6`](../contracts.md#c1), [`A1–A5`](../profiles.md#a1) and the synthetic catalogue [`F1`](../profiles.md#f1) are canonical.

## Goal

Read how the finished package reaches its synthetic implementation. Then
change `current_label` to return an independent owned snapshot, and identify
what changes in the [caller](../glossary.md#caller-and-callee)'s obligations even though the result type stays
`Label`.

## The domain obligation

The implementation reached through the selected access path fulfils the whole
contract, including who destroys a returned value
([reaching the code](../explanation/packages.md#reaching-the-code)).

## Steps

1. **For an existing function, separate its identity from its access path.**
   Find `current_label` in the finished package below. Its
   [canonical identity](../glossary.md#canonical-identity) is the package
   name, package version and declaration name. Its synthetic linker identity
   is the string `fixture_current_label` in `via`. The local access name
   `direct` labels this path; the [environment](../glossary.md#environment) list `[test]` limits where it
   applies. A source spelling alone supplies no access path
   ([`L2`](../language.md#l2), [`A2`](../profiles.md#a2)).

2. **For that path, trace each of its four [clauses](../glossary.md#clause) to a [provider](../glossary.md#provider) fact.**
   A [profile](../glossary.md#profile) defines an access mechanism; an
   [ABI entry](../glossary.md#abi-entry) defines [representation](../glossary.md#representation) and [calling
   conventions](../glossary.md#calling-convention). Follow the synthetic `fixture` and `native` aliases to their
   `use` declarations, then to [`F1`](../profiles.md#f1).

   | Clause in `current_label` | Observation to check |
   |---|---|
   | `abi(native, "c")` | The pinned synthetic ABI entry supports the selected `c` calling convention. The convention is one selection within the entry, not the whole ABI. |
   | `via(fixture, "symbol", "fixture_current_label")` | The synthetic profile supports a function symbol with all parameters explicit and a nonempty linker name. |
   | `mapping(identity)` | `F1` defines faithful lowering for this mechanism and ABI pair, including the `Card` input and `Label` result. This [mapping](../glossary.md#mapping) preserves ownership and the other contracts. |
   | `compatibility(stable)` | `F1` guarantees the reachable representations within its synthetic fixture [compatibility domain](../glossary.md#compatibility-domain); this says nothing about a real host ABI. |

   These are non-normative summaries of [`A1–A4`](../profiles.md#a1) and
   [`F1`](../profiles.md#f1). Every function has a path covering `test`.
   `LabelChanged` uses `callback_abi` and `representation` instead
   ([`A2`](../profiles.md#a2)). All these clauses were present from the
   checkpoint that introduced each declaration.

## Checkpoint package

The finished package assembles the API from parts 1–4 under the identity
`tutorial::finished`. Its synthetic fixture profile, catalogue and [digest
tokens](../glossary.md#digest-pin) are defined by [`F1`](../profiles.md#f1). Before applying the change,
compare the full [finished file](../examples/tutorial/05-finished.ail) with your work.

Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: ../examples/tutorial/05-finished.ail region=checkpoint -->
```ail
language "0.1";
package tutorial::finished version "1" {
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

### Guided change: an owned snapshot

1. **Before changing the contract, compare the two caller journeys.**
   With the existing borrow, keep the card alive and avoid refresh while
   using the label; do not destroy that borrowed [handle](../glossary.md#handle). With an independent
   owned snapshot, use the label even after card refresh or destruction,
   then call `destroy_label` exactly once for its ownership obligation.
   The result type is `Label` in both cases. The `give` clause distinguishes
   the journeys ([`C1–C2`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

   The owned version is a different synthetic API contract. It still returns
   a non-null `Label` successfully whenever it completes; this exercise adds
   no allocation-failure result and promises no eventual completion.
   The implementation burden of supplying such a snapshot belongs to that
   API choice, not to a guarantee made by AIL
   ([`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8)).

2. **For the changed API, make a separate publication.**
   Starting with the finished checkpoint, use `package tutorial::owned
   version "1"` and describe the owned-snapshot variant in [`surface`](../glossary.md#surface).
   Keep the existing [export](../glossary.md#exports) list: `Label` and `destroy_label` are already
   included. The new package name gives its declarations distinct canonical
   identities. Read each package independently; shared spellings do not
   make their nominal declarations interchangeable
   ([`L2–L3`](../language.md#l2)).

3. **In `current_label`'s [outcome](../glossary.md#outcome), change the returned obligation.**
   Replace `give($result, borrow(owner($card)))` with
   `give($result, owned)`, and remove
   `invalidated_by($result, [@refresh_card])`. Rename the explanatory outcome
   name from `lent` to `supplied`. Keep `when(returned, any)`,
   `meaning(success)` and `state($result, valid)`.
   The caller receives one unique destruction obligation, with no returned
   borrow to invalidate ([`C2`](../contracts.md#c2),
   [`C5`](../contracts.md#c5)).

   Keep `input($card, borrow)`, `retain($card, none)` and
   `valid($card, call)`: creating the snapshot still needs temporary access
   to a valid card. Changing the output does not change entry obligations
   ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

4. **For the changed operation's access path, name the changed implementation.**
   Replace `fixture_current_label` with `fixture_current_label_owned` in
   `via`. Keep `abi`, `mapping` and `compatibility`: `F1` still represents the
   same signature, and the new synthetic symbol is specified to deliver the
   owned snapshot. Reusing the old borrowing implementation would not
   implement this whole declaration, even though its signature fits
   ([`A2–A4`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

The complete [owned-snapshot variant](../examples/tutorial/05-owned.ail)
is the answer to the guided change. It retains the synthetic fixture profile,
catalogue and digest tokens. The changed operation is reproduced below so
that you can compare its entry and exit obligations; the linked file also
contains the new package identity and surface, all dependencies and all
other declarations.

Fragment — omits the package, dependencies and other declarations; not a
publishable package.

<!-- ail-example: ../examples/tutorial/05-owned.ail region=current-label -->
```ail
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
    outcome supplied {
      when(returned, any);
      meaning(success);
      state($result, valid);
      give($result, owned);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_current_label_owned");
      mapping(identity);
      compatibility(stable);
    }
  }
```

## Expected observations

Trace the following edits and retained obligations in the two files. This is
a non-normative inspection guide; the linked rules determine the constraints.

| Location or clause | What the change touches | Rule |
|---|---|---|
| Package name and version | `tutorial::owned` at version `1` gives a distinct publication identity from `tutorial::finished` at version `1`; local type and operation identities change with it. | [`L2`](../language.md#l2) |
| `surface`, `exports` | The surface now claims an owned-snapshot variant. The unchanged exports include `Label` and its destructor, so the new obligation has its dependencies. | [`L3`](../language.md#l3) |
| `current_label` signature | The input remains `Card` and the result remains non-null `Label`. A resource is already a handle; no pointer, extent or allocator contract is added. | [`L4`](../language.md#l4), [`C4–C5`](../contracts.md#c4) |
| `give` | `owned` replaces the owner-scoped borrow. The caller now receives one destruction obligation. | [`C1–C2`](../contracts.md#c1), [`C5`](../contracts.md#c5) |
| `invalidated_by` | Remove the borrow's earlier invalidator. `refresh_card` still mutates the card, but no longer ends this independent snapshot's validity. | [`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5) |
| `lifecycle` and `destroy_label` | Keep `lifecycle(unique, @destroy_label)`. The destructor still consumes one non-null `Label`, returns `unit` and has one successful returned outcome. The caller can now use it for this result. | [`C2–C3`](../contracts.md#c2) |
| `input`, `retain`, `valid` | Keep the card's input borrow, no retention and call validity. Output ownership does not transfer or retain the card. | [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5) |
| Outcome name, `when`, `meaning`, `state` | `supplied` replaces the name `lent`; the single successful, valid returned result and exhaustive `any` predicate stay the same. There is no new nullable failure branch. | [`L2`](../language.md#l2), [`C5`](../contracts.md#c5) |
| `via`, `abi`, `mapping`, `compatibility` | The symbol identity changes. The synthetic provider pair and signature lowering stay the same; the chosen implementation still owes the whole new contract. | [`A2–A4`](../profiles.md#a2), [`F1`](../profiles.md#f1) |
| Common and effect clauses | Keep `available`, `deprecated`, `sharing`, `isolation`, and the seven callable effects. Supplying a snapshot need not mutate the card's externally visible contents. Clauses remain in their original scopes, with one per applicable place. | [`L3`](../language.md#l3), [`L5`](../language.md#l5), [`C2–C3`](../contracts.md#c2) |
| Copying and notifications | `copy_text` still borrows a valid `Label` for its call; its output states and buffer contract stay the same. The independent `Watch` schedule, retention and teardown also stay the same. | [`C3–C6`](../contracts.md#c3) |
| Any prose or machine view of the changed API | It now presents an owned snapshot and the caller's destruction obligation. It cannot keep describing a card-dependent borrow. | [`A5`](../profiles.md#a5) |

The difference is visible without native execution: one result depends on the
card and refresh, while the other creates its own destruction obligation.
The files cannot establish that a real implementation honours either contract
([`C8`](../contracts.md#c8)).

## Check yourself

1. In the owned variant, does refreshing the card discharge the `Label`'s destruction obligation?
2. Does `mapping(identity)` allow the original borrowing symbol to serve the owned contract?
3. Does the owned result allow the caller to pass an invalid card to `current_label`?

### Answers

1. No. The `Label` is an independent owned snapshot. Its caller owes
   `destroy_label` even after card refresh or destruction
   ([`C2`](../contracts.md#c2), [`C5`](../contracts.md#c5)).
2. No. Identity mapping preserves the full contract; it does not adapt a
   borrow into an owned snapshot. This example names a different synthetic
   symbol for the changed implementation ([`A2`](../profiles.md#a2)).
3. No. `valid($card, call)` remains the caller's entry obligation for the
   borrowed input ([`C3`](../contracts.md#c3)).

## Invalid variant

In the owned variant's `current_label`, delete `give($result, owned)` and
leave the outcome as follows.

Invalid — rejected under [`C5`](../contracts.md#c5).

<!-- ail-fragment -->
```ail
outcome supplied {
  when(returned, any);
  meaning(success);
  state($result, valid);
}
```

A valid reference result still needs its ownership contract. `Label`'s
lifecycle alone does not say whether this call lends a handle or transfers
an owned one.

Return: [Describing a small API](README.md).
Next: [Conformance examples and pressure cases](../conformance.md) provides
other contracts to inspect; [Design choices and open questions](../explanation/choices.md)
collects questions for reviewing the language.
