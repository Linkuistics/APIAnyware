# 1. A package and one resource

> **Purpose:** tutorial — describe creation and destruction of a uniquely [owned](../glossary.md#owned) card.
> **Reader:** language designers new to [API binding](../glossary.md#binding).
> **Before this:** [Describing a small API](README.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L1–L5`](../language.md#l1), [`C1–C3`](../contracts.md#c1), [`C5`](../contracts.md#c5), [`A2–A4`](../profiles.md#a2) and [`F1`](../profiles.md#f1) are canonical.

## Goal

Write the lifetime subset of the synthetic label-card API as a [package](../glossary.md#package): a card type,
creation that can fail, and destruction. At the checkpoint, explain exactly
what the [caller](../glossary.md#caller-and-callee) owns after either creation [outcome](../glossary.md#outcome).

## The domain obligation

When creation returns a card, the caller owns one destruction obligation;
when creation returns null, the caller has nothing to destroy
([ownership and lifecycles](../explanation/contracts.md#who-owns-what)).

## Steps

1. **Start with the two C-shaped signatures.** Treat them as a sketch of the
   API, not a host [ABI](../glossary.md#abi) definition. AIL's `Card` is already an [opaque resource](../glossary.md#opaque-resource)
   [handle](../glossary.md#handle); it is not written `ptr<Card>`
   ([`L4`](../language.md#l4)).

   ```c
   typedef struct Card Card;
   Card *create_card(void);
   void destroy_card(Card *card);
   ```

   A non-null creation result gives the caller a card to destroy. A null
   result reports allocation failure. The pointer spelling alone does not
   say either of those things.

2. **Before describing operations, declare the publication boundary.**
   Write the language header and package identity shown below. Give
   `surface` the synthetic release and lifetime subset; list `Card`,
   `create_card` and `destroy_card` in
   [`exports`](../glossary.md#exports). Add the synthetic [provider](../glossary.md#provider) pins and
   exact `test` [environment](../glossary.md#environment). The package makes claims only for that
   configuration ([`L2–L3`](../language.md#l2),
   [`F1`](../profiles.md#f1)). The omitted label operations are unrelated
   to using this lifetime subset; its destructor is an included dependency.

3. **For the card's one destruction obligation, declare a unique resource.**
   Set `lifecycle(unique, @destroy_card)`, `implements([])`,
   `sharing(transferable)` and `isolation(none)`. Here
   [`sharing`](../contracts.md#c2) permits sole ownership to move between
   [executors](../glossary.md#executor), without concurrent access. It does not mean shared ownership
   ([`L5`](../language.md#l5), [`C2`](../contracts.md#c2)).

4. **For creation's two possible results, write two outcomes.** Use
   `nullable<Card>`, then pair `nonnull($result)` with success and
   `null($result)` with failure. In both outcomes mark the result valid
   and write `give($result, owned)`. A valid null is an observable
   allocation failure; a non-null result carries the owned obligation.
   Null carries none ([`C1`](../contracts.md#c1),
   [`C5`](../contracts.md#c5)).
   Owned names an obligation, not a C pointer property.

5. **For destruction, transfer the obligation at entry.** Write
   `input($card, consume)` and `retain($card, none)`, return `unit`,
   and supply one successful returned outcome. The caller supplies a valid,
   non-null owned card. The callee [consumes](../glossary.md#consume) that obligation at entry, on every
   outcome. The card's [lifecycle](../glossary.md#lifecycle) specifies when its lifetime ends, so
   `mutation(none)` is consistent with destruction
   ([`C2–C3`](../contracts.md#c2)).

6. **Before finishing either function, fill its other required facts.**
   Copy the explicit [availability](../glossary.md#availability), deprecation and seven effect [clauses](../glossary.md#clause)
   from the checkpoint. Creation permits independent parallel calls;
   destruction requires serial calls and forbids nested [re-entrancy](../glossary.md#re-entrancy).
   Both are synchronous and non-throwing. Give each function its synthetic
   symbol [access path](../glossary.md#access-path) block: `abi`, `via`, `mapping` and
   `compatibility`. These facts are already part of a complete package
   ([`L3`](../language.md#l3), [`L5`](../language.md#l5),
   [`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).
   [Part 5](05-access-and-change.md) explains access paths in detail.

## Checkpoint package

The synthetic fixture [profile](../glossary.md#profile), catalogue and [digest tokens](../glossary.md#digest-pin) are defined by
[`F1`](../profiles.md#f1). Read the complete [checkpoint file](../examples/tutorial/01-lifetime.ail)
alongside your work.

Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: ../examples/tutorial/01-lifetime.ail region=checkpoint -->
```ail
language "0.1";
package tutorial::lifetime version "1" {
  surface("Synthetic label-card API release 1: Card lifetime; other operations excluded.");
  exports([@Card, @create_card, @destroy_card]);
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
}
```

## Expected observations

In summary (non-normative; [`L3`](../language.md#l3),
[`C1–C3`](../contracts.md#c1), [`C5`](../contracts.md#c5)):

- Every exported declaration is available in `test`; every function has
  an access path for `test`. The `@destroy_card` reference resolves locally.
- The null/non-null split covers every value of `nullable<Card>`.
  Both results are valid to inspect; the caller destroys only a non-null one.
- The destructor has no result state because `unit` contains no value.
  It consumes the card instead of lending access to it.
- The document lists returned [completion](../glossary.md#completion) as possible; it does not promise eventual
  termination. There is no runtime or validator result to inspect here.

## Check yourself

1. If creation reports allocation failure, does its `give(owned)` create a
   destruction obligation?
2. Why does `destroy_card` not have `valid($card, call)`?
3. Could you remove the destructor because it is only one dependency of the
   resource?

### Answers

1. No. The clause is conditional on non-null; null carries no obligation
   ([`C1`](../contracts.md#c1), [`C5`](../contracts.md#c5)).
2. The caller transfers a valid owned input at entry. `valid` describes
   the caller's continuing obligation for [borrowed inputs](../glossary.md#borrow)
   ([`C3`](../contracts.md#c3)).
3. No. The resource's declared lifecycle depends on it. A smaller surface
   still includes its whole [dependency closure](../glossary.md#dependency-closure)
   ([`L3`](../language.md#l3), [`C2`](../contracts.md#c2)).

## Invalid variant

In `destroy_card`, replace its `input($card, consume)` clause with the
following clause, leaving everything else as in the checkpoint.

Invalid — rejected under [`C2`](../contracts.md#c2).

<!-- ail-fragment -->
```ail
input($card, borrow);
```

The declared unique destructor no longer consumes its owned resource. Adding
borrow validity would not repair that lifecycle mismatch.

Return: [Describing a small API](README.md).
Next: [2. Lending access](02-lending.md).
