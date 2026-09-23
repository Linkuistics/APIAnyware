# 3. Caller-supplied storage and failure

> **Purpose:** tutorial — describe text copying with separate status and output validity.
> **Reader:** language designers new to API binding.
> **Before this:** [2. Lending access](02-lending.md).
> **Status:** draft 0.1, a proposal under review; no parser, validator or implementation exists.
> **Rules:** [`L4–L5`](../language.md#l4), [`C1–C5`](../contracts.md#c1) and [`A2–A4`](../profiles.md#a2) are canonical.

## Goal

Add `copy_text`, which writes a label's text into caller storage. At the
checkpoint, explain what the caller can read after success and after failure.

## The domain obligation

The caller allocates enough disjoint storage, and reads its output only when
the copy succeeds ([buffers](../explanation/contracts.md#buffers-and-strings)
and [outcome states](../explanation/contracts.md#every-way-a-call-can-end)).

## Steps

1. **To make failure observable, add a status result to the C-shaped sketch.**
   The synthetic API can report either a successful copy or unavailable text.
   This header conveys no host representation guarantee.

   ```c
   typedef enum CopyStatus {
       copied = 0,
       unavailable = 1
   } CopyStatus;
   CopyStatus copy_text(Label *label, unsigned char *destination);
   ```

   On success the caller reads seven UTF-8 code units and their terminating
   zero. On failure the caller reads the status but no output bytes.
   A failed call need not preserve the destination's old contents.

2. **For exactly those two status values, declare a closed enum.** Use
   `enum CopyStatus: i32`, `values(closed)`, cases `0` and `1`,
   `sharing(value)` and `isolation(none)`, plus availability and
   deprecation. The two values define the entire
   [discriminator](../glossary.md#discriminator) domain in the outcomes.
   An open enum would also admit every other `i32` value
   ([`L4`](../language.md#l4), [`C2`](../contracts.md#c2),
   [`C5`](../contracts.md#c5)).

3. **For the call's temporary access, borrow both inputs without retention.**
   Use `Label` and `mutptr<u8>`, with `input(borrow)`,
   `retain(none)` and `valid(call)` on each named slot, as below.
   If the label came from `current_label`, keep its card alive and prevent
   refresh throughout this use. The label's earlier borrow contract still
   applies ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3),
   [`C5`](../contracts.md#c5)).

4. **For the writable buffer, specify shape and contents separately.** Write
   `direction($destination, out)`,
   `aliasing($destination, disjoint)`,
   `extent($destination, buffer(7, 8, elements))` and
   `contents($destination, text("utf-8", nul))`.
   [Extent](../glossary.md#buffer-extent) records seven initialized text
   elements on a valid output and capacity for eight. The eighth code unit
   holds the terminator, which the length excludes.
   Before entry, allocate all eight bytes; no initialized input contents
   are needed for this `out` buffer. Disjoint storage does not overlap
   other memory accessed in the call ([`C3–C4`](../contracts.md#c3)).
   Set `mutation(arguments)` because the callee writes that storage.

5. **For each possible status, state what is safe to observe.** Split
   returned completion using `equal($result, 0)` and
   `equal($result, 1)`. Mark `$result` valid in both outcomes.
   Mark `$destination[]` valid on success and invalid on failure.
   The `[]` [place](../glossary.md#place) selects buffer elements;
   `.*` would select the pointee of an `extent(one)` pointer.
   In summary (non-normative; [`C1`](../contracts.md#c1),
   [`C5`](../contracts.md#c5)): invalid output conveys no initialized
   elements and cannot be inspected. `meaning(failure)` classifies the
   returned status; it does not turn it into an exception.

6. **To publish the expanded subset, add `CopyStatus` and `copy_text`
   to the exports and describe copying in the surface.** Keep all earlier
   declarations, and give `copy_text` its explicit effects and synthetic
   symbol path. The `mutptr<u8>` pointer itself is borrowed from the
   caller; writing scalar bytes creates no new reference ownership
   ([`L3`](../language.md#l3), [`C1`](../contracts.md#c1),
   [`C3`](../contracts.md#c3), [`A2`](../profiles.md#a2)).

## Checkpoint package

The synthetic fixture profile, catalogue and digest tokens are defined by
[`F1`](../profiles.md#f1). Read the complete [checkpoint file](../examples/tutorial/03-storage.ail)
alongside your work.

Complete package — admitted by the grammar and complete under draft 0.1,
checked by inspection.

<!-- ail-example: ../examples/tutorial/03-storage.ail region=checkpoint -->
```ail
language "0.1";
package tutorial::storage version "1" {
  surface("Synthetic label-card API release 1: Card lifetime, label lending, refresh and text copying; other operations excluded.");
  exports([@Card, @create_card, @destroy_card, @Label, @destroy_label, @current_label, @refresh_card, @CopyStatus, @copy_text]);
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
}
```

## Expected observations

In summary (non-normative; [`L4`](../language.md#l4),
[`C3–C5`](../contracts.md#c3)):

- Status `0` gives valid text, with seven nonzero UTF-8 code units and
  a final zero within the eight-element capacity.
- Status `1` is still valid to read. The output buffer provides no
  initialized elements on that outcome; even looking for a terminator
  would read invalid output.
- Failure does not invalidate the destination pointer or transfer the
  caller's allocation. `state($destination[], invalid)` describes the
  output elements, not the ownership of the caller's storage.
- The two outcomes exhaust the closed enum. No native computation is
  needed to decide whether a third status is admitted by the declaration.
- The caller provides capacity even when copying fails. Neither the
  possibility of failure nor a small readable length reduces that precondition.

## Check yourself

1. Is a seven-byte destination enough for this operation?
2. After status `1`, can a caller read the old bytes because the operation failed?
3. Why does the callee not supply `give($destination[], owned)` on success?

### Answers

1. No. Seven text elements plus the terminator require capacity eight
   ([`C4`](../contracts.md#c4)).
2. No. The failed output is invalid; it has no readable initialized elements.
   The declaration does not promise unchanged storage
   ([`C5`](../contracts.md#c5)).
3. The elements are scalar `u8` values, not reference leaves. The caller
   already owns the allocation and lends its pointer during the call
   ([`C1`](../contracts.md#c1), [`C3`](../contracts.md#c3),
   [`C5`](../contracts.md#c5)).

## Invalid variant

In `copy_text`, replace its `extent` clause with the following clause;
keep `contents($destination, text("utf-8", nul))`.

Invalid — rejected under [`C4`](../contracts.md#c4).

<!-- ail-fragment -->
```ail
extent($destination, buffer(7, 7, elements));
```

The length still excludes the terminator, so capacity seven leaves no room
for the required final zero.

Return: [Describing a small API](README.md).
Next: [4. Callbacks and teardown](04-callbacks.md).

