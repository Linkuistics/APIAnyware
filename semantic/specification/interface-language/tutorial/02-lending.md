# 2. Lending access

> **Purpose:** tutorial — describe a label [borrow](../glossary.md#borrow) and the operation that ends it early.
> **Reader:** language designers new to [API binding](../glossary.md#binding).
> **Before this:** [1. A package and one resource](01-lifetime.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L3–L5`](../language.md#l3), [`C1–C3`](../contracts.md#c1), [`C5`](../contracts.md#c5) and [`A2–A4`](../profiles.md#a2) are canonical.

The context map locates this part in the package you are producing. It pins
catalogue definitions and supplies one contract to its consumers; publication
validation checks completeness and consistency, not native behaviour. These are
proposed roles ([`L2–L3`](../language.md#l2), [`C8`](../contracts.md#c8),
[`A1`](../profiles.md#a1), [`A5`](../profiles.md#a5)). The map omits callable
details; this part zooms into the returned label's validity.

![Producers submit a contract for publication validation; the package pins catalogue definitions and supplies the same contract to binding generators, documentation renderers and LLM tooling.](../figures/g1-context.svg)

[Context map source](../figures/g1-context.puml)

## Goal

Extend the lifetime [package](../glossary.md#package) with `current_label` and `refresh_card`.
At the checkpoint, identify both ways that a returned label borrow ends.
Borrowing grants access without an ownership obligation; it does not imply
Rust-style static checking or exclusivity.

## The domain obligation

A [caller](../glossary.md#caller-and-callee) using the card's label keeps the card alive and stops using that
label when refresh begins
([borrow validity and invalidation](../explanation/contracts.md#how-long-a-borrow-lasts)).

## Steps

1. **To expose the label without transferring it, add these operations.**
   The C-shaped sketch uses pointers to opaque types. In AIL, both types
   are resource [handles](../glossary.md#handle), with no exposed layout
   ([`L4`](../language.md#l4)).

   ```c
   typedef struct Label Label;
   Label *current_label(Card *card);
   void refresh_card(Card *card);
   void destroy_label(Label *label);
   ```

   Before refresh, the borrowed label remains usable while its card lives.
   Once refresh begins, that old label is unusable even if the card lives
   on. A call to `current_label` after refresh obtains the new label.
   The earlier [invalidation](../glossary.md#invalidation) is separate
   from the owner's eventual destruction.

2. **For the new label type, declare its own [lifecycle](../glossary.md#lifecycle).** Add `Label`
   with `lifecycle(unique, @destroy_label)`, `implements([])`,
   `sharing(transferable)` and `isolation(none)`. Add its consuming
   destructor using the same shape as `destroy_card`. A resource
   needs its lifecycle even when `current_label` lends it
   ([`C2`](../contracts.md#c2)).
   The caller uses this destructor to discharge an [owned](../glossary.md#owned)
   `Label`. The caller cannot use it on the borrow from `current_label`;
   the card owns that current label.

3. **For `current_label`'s input, borrow the card for the call.**
   Write `input($card, borrow)`, `retain($card, none)` and
   `valid($card, call)`. For its successful returned `Label`, write
   `state($result, valid)` and
   `give($result, borrow(owner($card)))`.
   The caller keeps the input card valid throughout the invocation; the output
   [region](../glossary.md#region) bounds later use of the returned label
   ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3),
   [`C5`](../contracts.md#c5)). See
   [the split between input and output validity](../explanation/choices.md#q5)
   for the design question this raises.

4. **To end old label borrows at refresh entry, name the invalidator.**
   In the `lent` [outcome](../glossary.md#outcome), add
   `invalidated_by($result, [@refresh_card])`. Give `refresh_card`
   a borrowed `Card` parameter and `mutation(arguments)`: it changes
   the card's live contents. Its one outcome successfully returns `unit`.
   In summary (non-normative; [`C5`](../contracts.md#c5)): an earlier
   invalidator takes effect at entry to the listed operation involving
   that owner. Destruction already ends the owner region; it is not
   listed as another mutation.

5. **Before calling the checkpoint complete, expand its publication boundary.**
   Use the new package identity and [surface](../glossary.md#surface) shown below, export the new
   declarations, and include their `available`, `deprecated`, effects
   and synthetic [access path](../glossary.md#access-path) blocks. The `Label` lifecycle and
   `@refresh_card` invalidation reference both belong in the [dependency
   closure](../glossary.md#dependency-closure) ([`L2–L5`](../language.md#l2),
   [`A2`](../profiles.md#a2)). Keep the first checkpoint unchanged as a
   separate, smaller package.

Compare the two timelines to see why keeping `Card` alive is necessary but
does not alone keep a returned `Label` usable. Refresh ends the old borrow at
entry while the card lives on; without refresh, card destruction ends its
owner region. In both cases the returned borrow outlives the input's call
region and gives no permission to `destroy_label`. The figure omits access
paths and shows ordering, not elapsed time (non-normative;
[`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3),
[`C5`](../contracts.md#c5)).

![Two independent cases begin with current_label borrowing Card for the call and returning an owner-scoped Label borrow. In one, refresh invalidates the Label while Card survives; in the other, Card destruction ends the borrow.](../figures/tutorial-borrow.svg)

[Label borrow diagram source](../figures/tutorial-borrow.puml)

## Checkpoint package

The synthetic fixture [profile](../glossary.md#profile), catalogue and [digest tokens](../glossary.md#digest-pin) are defined by
[`F1`](../profiles.md#f1). Read the complete [checkpoint file](../examples/tutorial/02-lending.ail)
alongside your work.

Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: ../examples/tutorial/02-lending.ail region=checkpoint -->
```ail
language "0.1";
package tutorial::lending version "1" {
  surface("Synthetic label-card API release 1: Card lifetime, label lending and refresh; other operations excluded.");
  exports([@Card, @create_card, @destroy_card, @Label, @destroy_label, @current_label, @refresh_card]);
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
}
```

## Expected observations

In summary (non-normative; [`C1–C3`](../contracts.md#c1),
[`C5`](../contracts.md#c5)):

- `current_label` gives no destruction obligation to its caller. Its
  result is non-null because `Label` is not nullable.
- The caller can use the label after `current_label` returns. Its region
  is `owner($card)`, not `call`.
- Entering `refresh_card` ends earlier label borrows for that card.
  Destroying the card also ends them. Neither operation transfers ownership
  of those labels to the caller.
- Both new card operations require serial access. `executor(any)` permits
  entry from any [executor](../glossary.md#executor), without granting concurrent use of the card.
- `destroy_label` describes how to discharge an owned label. A function's
  [availability](../glossary.md#availability) alone does not satisfy its owned-input obligation.

## Check yourself

1. If the card remains alive after refresh, can a caller keep using the old label?
2. If the caller uses a label after `current_label` returns, which clause
   requires the caller to keep the card alive?
3. Does the presence of `destroy_label` mean the caller destroys this borrow?

### Answers

1. No. `invalidated_by` ends the borrow at refresh entry, before the owner
   region ends ([`C5`](../contracts.md#c5)).
2. `give($result, borrow(owner($card)))` supplies the output's validity
   bound. `valid($card, call)` only describes the input obligation for
   that invocation ([`C1`](../contracts.md#c1),
   [`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).
3. No. A borrow supplies no ownership obligation to consume
   ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

## Invalid variant

In `current_label`'s `lent` outcome, replace its `give` clause with
the following clause, leaving the rest unchanged.

Invalid — rejected under [`C1`](../contracts.md#c1).

<!-- ail-fragment -->
```ail
give($result, borrow(call));
```

The returned borrow would expire at the completion that delivers it. An
escaping borrow needs a region that survives delivery to its recipient.

Return: [Describing a small API](README.md).
Next: [3. Caller-supplied storage and failure](03-storage.md).
