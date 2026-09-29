# 5. Reaching the code, and changing the contract

> **Purpose:** tutorial — read the finished [package](../glossary.md#package)'s [access paths](../glossary.md#access-path) and change a [borrowed](../glossary.md#borrow) label into an [owned](../glossary.md#owned) snapshot.
> **Reader:** language designers new to [API binding](../glossary.md#binding).
> **Before this:** [4. Callbacks and teardown](04-callbacks.md).
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [`L2–L5`](../language.md#l2), [`C1–C6`](../contracts.md#c1), [`A1–A5`](../profiles.md#a1) and the synthetic catalogue [`F1`](../profiles.md#f1) are canonical.

## Goal

Explain how a tool would reach the implementation of `current_label` using
its `access` block. Then change the operation to return an independent
owned label. The result type stays `Label`, but the
[caller](../glossary.md#caller-and-callee) takes on a new responsibility:
destroying that result.

Start with the [access steps](#steps). If you are ready to make the change,
go directly to [the owned-snapshot exercise](#guided-change-an-owned-snapshot),
which follows the [complete finished package](#checkpoint-package).
The [expected observations](#expected-observations) trace the edits, and
the [questions](#check-yourself) test their consequences.

The examples use the invented label-card API and the synthetic fixture
[profile](../glossary.md#profile), catalogue and [digest tokens](../glossary.md#digest-pin)
defined by [`F1`](../profiles.md#f1). This part explains the access clauses
already present in parts 1–4, then creates a separate API variant for the
ownership exercise.

<a id="the-domain-obligation"></a>

## The model

For [Reaching the code](../explanation/model.md#access), follow how a tool calls
the implementation of `current_label`. The access path names that code and
the machine-level definitions needed to pass a card and receive a label.
The implementation fulfils the operation's whole contract, including the
result's ownership.

In the exercise, change [Release responsibility](../explanation/model.md#responsibility):
the caller receives an independent label and becomes responsible for
destroying it. That changes the result's [Validity](../explanation/model.md#validity)
relationship with the card: refresh and card destruction end use of the
original borrow, while the snapshot has its own lifetime. At the checkpoint,
you can trace a contract to its implementation. After the exercise, you can
explain how the new responsibility changes the result clauses, which
destructor fulfils it and why a different implementation is needed.

## Steps

### 1. Identify the operation and its implementation

Apply [Reaching the code](../explanation/model.md#access) to `current_label`:
find the implementation that supplies its borrowed result. First identify
the operation within [The published description](../explanation/model.md#description),
then follow its access path to the symbol.

Fragment — shows `current_label`'s access path. The
[complete checkpoint](#checkpoint-package) also supplies publication,
provider and environment declarations, resources and the function's contract.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=access-path -->
```ail
package tutorial::finished version "1" {
  fn current_label(card: Card) -> Label {
    // Input, effects and outcomes omitted.
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_current_label");
      mapping(identity);
      compatibility(stable);
    }
  }
}
```

The package declares `current_label`; that function owns both the contract
and its access path. `Card` and `Label` name local resource types without `@`
([`L2`](../language.md#l2), [`A2`](../profiles.md#a2)).

For the block's syntax and railroad, see the
[access-path grammar](../reference/notation.md#access).
[`A2`](../profiles.md#a2) supplies the required clauses and the rule that
paths cover every environment where the function is available.

Find `current_label` in the [finished file](../examples/tutorial/05-finished.ail)
or [checkpoint below](#checkpoint-package). A tool identifies this operation
by package name `tutorial::finished`, version `"1"` and declaration name
`current_label`. Together these are its
[canonical identity](../glossary.md#canonical-identity) ([`L2`](../language.md#l2)).

Now find `access direct in [test]` inside that function. `direct` is the
local name of one way to call it, and `[test]` identifies the
[environment](../glossary.md#environment) where that way applies. The
[`via`](../reference/clauses-access.md#via) clause names `fixture_current_label` as the linker symbol to reach.
The tool uses one name to identify the contract and another to locate its
implementation ([`A2`](../profiles.md#a2)).

### 2. Follow the definitions that govern the call

For [Reaching the code](../explanation/model.md#access), identify the
definitions that tell a tool how to make this call. The path uses aliases
introduced at package level; they select catalogues of calling and
representation rules.

Fragment — shows provider selections in `tutorial::finished`. The
[complete checkpoint](#checkpoint-package) also supplies the environment,
publication clauses and declarations. These are synthetic pins from
[`F1`](../profiles.md#f1).

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=access-dependencies -->
```ail
package tutorial::finished version "1" {
  use profile fixture = "example.fixture" version "1" digest "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
  use abi native = "example.fixture-abi" version "1" digest "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
}
```

Follow `fixture` and `native` to their `use` declarations at the top of
the package. `fixture` selects the profile defining the `symbol` mechanism.
`native` selects an [ABI entry](../glossary.md#abi-entry), whose rules
describe how to pass the card and return the label. The
[provider](../glossary.md#provider) supplies those definitions
([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

Read [`abi(native, "c")`](../reference/clauses-access.md#abi) as selecting the `c`
[calling convention](../glossary.md#calling-convention) within that entry.
A calling convention specifies the call protocol; the ABI entry also
defines [representations](../glossary.md#representation) for the values being
passed. For this fixture, resource handles have a specified 64-bit
representation ([`A1`](../profiles.md#a1), [`F1`](../profiles.md#f1)).

Read [`via(fixture, "symbol", "fixture_current_label")`](../reference/clauses-access.md#via) as asking the
[consumer](../glossary.md#consumer) to use the fixture's function-symbol
mechanism with that exact name. The mechanism keeps all declared parameters
explicit. Compare these facts with [`F1`](../profiles.md#f1), which defines
the synthetic catalogue.

### 3. Check how the path preserves the contract

Continue [Reaching the code](../explanation/model.md#access) by checking
that the path accounts for the declared call and keeps its values compatible.
Read [`mapping(identity)`](../reference/clauses-access.md#mapping) next. A [mapping](../glossary.md#mapping) describes
how the consumer passes the declared inputs through the selected path. It
also accounts for the results and the ways the call can finish, its
[completions](../glossary.md#completion).
The fixture defines faithful identity mapping for its
symbol mechanism and `c` convention. The consumer can pass the `Card` and
receive the `Label` according to that definition ([`A2`](../profiles.md#a2),
[`F1`](../profiles.md#f1)).

The selected implementation also fulfils the behaviour described in the
function body.
For this operation it lends the card's label, and refresh ends that borrow.
Matching a parameter and result type is only part of fulfilling the whole
operation ([`A2`](../profiles.md#a2)).

Finally, read [`compatibility(stable)`](../reference/clauses-access.md#compatibility). The provider guarantees compatible
representations across its stated [compatibility domain](../glossary.md#compatibility-domain).
Here that domain is the synthetic fixture. A real library would need a
provider guarantee covering its actual environments and representations
([`A4`](../profiles.md#a4), [`F1`](../profiles.md#f1)).

Use this table to connect each clause in `current_label`'s `direct` path to
the fact a tool needs when arranging the call. The rows summarize this
synthetic example (non-normative; [`A2–A4`](../profiles.md#a2),
[`F1`](../profiles.md#f1)).

| Clause | What it tells the tool |
|---|---|
| [`abi(native, "c")`](../reference/clauses-access.md#abi) | Use the `c` calling convention in the selected ABI definition. |
| [`via(fixture, "symbol", "fixture_current_label")`](../reference/clauses-access.md#via) | Reach the function through this exact synthetic symbol. |
| `mapping(identity)` | Pass the declared card and receive the label using the provider's identity mapping. |
| `compatibility(stable)` | Rely on the provider's representation guarantee within its stated domain. |

### 4. Check the other declarations' access facts

Apply [Reaching the code](../explanation/model.md#access) to the rest of
the package. Check a path for each function the program calls, then the
representation of the callback value it supplies to the library. The callback
carries those facts directly in its declaration; compare their location
with the function's nested access block in step 1.

Fragment — shows the callback's calling facts in `tutorial::finished`.
The [complete checkpoint](#checkpoint-package) also supplies the callback's
contracts and the surrounding package and provider declarations.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=access-callback -->
```ail
callback LabelChanged(change: u64) -> unit {
  callback_abi(native, "c");
  representation(fixture, "closure");
}
```

For every function, find a path covering `test` and read its four clauses:
[`abi`](../reference/clauses-access.md#abi), [`via`](../reference/clauses-access.md#via), [`mapping`](../reference/clauses-access.md#mapping) and [`compatibility`](../reference/clauses-access.md#compatibility). Each function had these clauses
from the checkpoint that introduced it. For the callback `LabelChanged`,
find [`callback_abi`](../reference/clauses-access.md#callback_abi) and [`representation`](../reference/clauses-access.md#representation) instead: the program supplies that
callable value for the library to invoke ([`A2`](../profiles.md#a2)).

You have now followed a contract to the definitions needed to call its
implementation. Continue to the [ownership exercise](#guided-change-an-owned-snapshot)
to change who destroys the returned label and select the implementation
that supplies it.
The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
places this consumer task in the wider use of an AIL description.

## Checkpoint package

The finished package collects the API from parts 1–4 under the identity
`tutorial::finished`. Compare the complete [finished file](../examples/tutorial/05-finished.ail)
with your work, then continue to [the guided change](#guided-change-an-owned-snapshot).
The synthetic fixture profile, catalogue and digest tokens remain those
defined by [`F1`](../profiles.md#f1).

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

Change [Release responsibility](../explanation/model.md#responsibility)
for the result of `current_label`. Follow that change from the caller's
actions through the published contract to the implementation that fulfils it.

#### 1. Compare what the caller does with each result

Compare [Release responsibility](../explanation/model.md#responsibility)
and [Validity](../explanation/model.md#validity) in the two cases.
Begin with the existing borrow. A program obtains the card's label and uses
it while keeping the card alive. Before refreshing or destroying the card,
it finishes using that label. The card keeps ownership of the label, so the
program has no label-destruction obligation
([`C1–C2`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

Now consider an independent snapshot. The program obtains an owned label
whose lifetime is independent of the card. It can keep using the snapshot
after refresh or card destruction. When finished, it calls `destroy_label`
once to discharge its own obligation ([`C2`](../contracts.md#c2), [`C5`](../contracts.md#c5)).

The type spelling `Label` can occur in either contract. The operation's
[`give`](../reference/clauses-outcomes.md#give) clause tells the caller whether it receives a borrow or an owned
result. Borrowing states the agreement about access; it implies no
Rust-style static checking or exclusivity.

The owned version is a different synthetic API promise. Whenever the
operation completes, it successfully supplies a non-null snapshot. This
exercise preserves that successful-return contract and adds no failure
result. Providing such a snapshot is an obligation of the imagined
implementation; AIL itself supplies neither an allocation guarantee nor an
eventual-return guarantee ([`C3`](../contracts.md#c3), [`C8`](../contracts.md#c8)).

Read across each row to compare what the program can do with a borrowed
label and an owned snapshot at the same event (non-normative;
[`C1–C3`](../contracts.md#c1), [`C5`](../contracts.md#c5)). Each column
describes its own package; the matching type spellings still identify
distinct nominal types ([`L2`](../language.md#l2)).

| Event or obligation | Borrow in `tutorial::finished` | Owned snapshot in `tutorial::owned` |
|---|---|---|
| During `current_label` | Keep the input card valid for the call. | Keep the input card valid for the call. |
| Successful return | Receive access to the card's non-null label. The card keeps ownership. | Receive a non-null snapshot and responsibility for destroying it. |
| `refresh_card` entry | Stop using the old label; the card remains alive. | Keep using the snapshot until finished with it. |
| Card destruction | Stop using the label because its card has been destroyed. | Keep using the snapshot until finished with it. |
| Finishing with the label | Leave its destruction to the card; this borrow cannot be passed to `destroy_label`. | Call `destroy_label` once. The library takes responsibility at entry and destroys the snapshot before returning. |

Refreshing or destroying the card leaves the snapshot's destruction with
the program. Its independent lifetime permits longer use and carries that
continuing responsibility.

#### 2. Give the changed API a separate package

For [The published description](../explanation/model.md#description), give
the changed contract its own package identity. The variant keeps the label's
[lifecycle](../glossary.md#lifecycle) declaration: as one of the
[Entities that outlive a call](../explanation/model.md#entities),
the snapshot needs a defined way for its new owner to release it.

Fragment — shows the owned variant's package context. The
[complete owned package](../examples/tutorial/05-owned.ail) also supplies
exports, dependencies, the environment and every declaration contract.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=owned-shell -->
```ail
language "0.1";
package tutorial::owned version "1" {
  surface("Synthetic label-card API owned-snapshot variant release 1: Card lifetime, owned label snapshots, refresh, text copying and independent label-change notifications; other operations excluded.");
  resource Label {
    lifecycle(unique, @destroy_label);
    // Other nominal contracts omitted.
  }
  fn destroy_label(label: Label) -> unit {
    input($label, consume);
    // Remaining call contract omitted.
  }
  // Other declarations omitted.
}
```

Copy the finished checkpoint and use `package tutorial::owned version "1"`.
Describe the owned-snapshot variant in [surface](../glossary.md#surface).
Keep the [exports](../glossary.md#exports): the package already contains
`Label` and `destroy_label`, so it has the declarations needed to explain
the new responsibility ([`L2–L3`](../language.md#l2)).

The new package name gives all its declarations distinct canonical
identities. Read the variants separately: a `Label` declared by one belongs
to that package, even though the other uses the same local spelling
([`L2`](../language.md#l2)).

#### 3. Give the caller ownership of the `current_label` result

Express the new [Release responsibility](../explanation/model.md#responsibility)
in the returned outcome, and remove the old borrow's
[Validity](../explanation/model.md#validity) cutoff. Read the result clauses
in their containing operation before changing them. The first fragment is
the existing contract; the second is the exercise's replacement.

Fragment — shows the borrowed result in `tutorial::finished`. The
[complete finished package](../examples/tutorial/05-finished.ail) also
supplies input clauses, effects, access and surrounding declarations.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=change-borrow -->
```ail
fn current_label(card: Card) -> Label {
  outcome lent {
    when(returned, any);
    meaning(success);
    state($result, valid);
    give($result, borrow(owner($card)));
    invalidated_by($result, [@refresh_card]);
  }
}
```

Fragment — shows the owned result in `tutorial::owned`. The
[complete owned package](../examples/tutorial/05-owned.ail) also supplies
input clauses, effects, access and surrounding declarations.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=change-owned -->
```ail
fn current_label(card: Card) -> Label {
  outcome supplied {
    when(returned, any);
    meaning(success);
    state($result, valid);
    give($result, owned);
  }
}
```

In each fragment `$result` selects that function's returned label.
The borrow uses `$card` to name its owner and `@refresh_card` to name the
operation that ends access early. The owned result carries its own
destruction obligation ([`C1–C2`](../contracts.md#c1), [`C5`](../contracts.md#c5)).

In the returned [outcome](../glossary.md#outcome), replace
[`give($result, borrow(owner($card)))`](../reference/clauses-outcomes.md#give) with `give($result, owned)`.
Remove [`invalidated_by($result, [@refresh_card])`](../reference/clauses-outcomes.md#invalidated_by), which described the
earlier cutoff for the borrow. The result is now an independent owned label
with its own destruction obligation ([`C2`](../contracts.md#c2), [`C5`](../contracts.md#c5)).

Rename the outcome from `lent` to `supplied` to describe the new result.
Keep [`when(returned, any)`](../reference/clauses-outcomes.md#when), [`meaning(success)`](../reference/clauses-outcomes.md#meaning) and [`state($result, valid)`](../reference/clauses-outcomes.md#state).
The operation still has one successful case covering every returned result
([`C5`](../contracts.md#c5)).

Keep the card's input clauses: `input($card, borrow)`, `retain($card, none)`
and `valid($card, call)`. The library still needs a usable card while
producing the snapshot. The result's new ownership changes what happens
after return; the caller still satisfies the existing input conditions
([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

#### 4. Select the implementation that supplies the snapshot

Return to [Reaching the code](../explanation/model.md#access): select an
implementation that supplies the newly promised ownership. The changed
symbol stays inside `current_label`'s access path.

Fragment — shows the owned variant's access block in `tutorial::owned`.
The [complete owned package](../examples/tutorial/05-owned.ail) also supplies
the function contract and its package, provider and environment declarations.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=owned-access -->
```ail
fn current_label(card: Card) -> Label {
  access direct in [test] {
    abi(native, "c");
    via(fixture, "symbol", "fixture_current_label_owned");
    mapping(identity);
    compatibility(stable);
  }
}
```

In [`via`](../reference/clauses-access.md#via), replace `fixture_current_label` with
`fixture_current_label_owned`. The new synthetic symbol identifies the
implementation specified to produce an independent owned result. The
original symbol's borrowing behaviour would leave the new contract
unfulfilled, despite having the same signature ([`A2`](../profiles.md#a2)).

Keep [`abi`](../reference/clauses-access.md#abi), [`mapping`](../reference/clauses-access.md#mapping) and [`compatibility`](../reference/clauses-access.md#compatibility). The parameter and result types
still use the fixture's resource-handle representation. The implementation
reached by the changed symbol supplies the independently owned snapshot
([`A2–A4`](../profiles.md#a2), [`F1`](../profiles.md#f1)).

#### 5. Compare your changed operation

Check [Release responsibility](../explanation/model.md#responsibility)
from end to end: the returned obligation, the label's destructor and the
implementation supplying the snapshot. Use the complete
[owned-snapshot file](../examples/tutorial/05-owned.ail)
as the answer to the exercise. It contains the changed package identity and
surface as well as every declaration and the synthetic dependencies.
The extract below lets you compare `current_label`'s input and output directly.

Fragment — shows the owned-snapshot `current_label`. The complete
[owned package](../examples/tutorial/05-owned.ail) also supplies the package
header, environment, synthetic profile and ABI pins, resource declarations
and other operations.

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

Trace these changes in the finished and owned files. The following is a
non-normative inspection guide; the linked rules supply the exact requirements.

**The package identifies a different contract.** Its new name gives local
types and operations new canonical identities. Its surface now describes
the independent snapshot. The existing export list still includes the
label's destructor ([`L2–L3`](../language.md#l2)).

**The result brings a responsibility the caller can discharge.**
[`give(owned)`](../reference/clauses-outcomes.md#give) transfers one destruction obligation. The existing
`lifecycle(unique, @destroy_label)` names how the caller fulfils it.
`destroy_label` still consumes a non-null label, returns `unit` and has
one successful returned outcome. A resource value is already a handle, so
this edit needs no pointer extent or allocator contract
([`L4`](../language.md#l4), [`C2–C5`](../contracts.md#c2)).

**The input conditions and returned success remain the same.**
`current_label` borrows the card for the call and retains none of it.
The non-null result is valid and successful whenever the operation returns.
The outcome name changes to `supplied`, while `any` still covers the whole
returned case ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**Refresh affects the card's current label.** The owned snapshot has its
own lifetime, so the earlier borrow's [`invalidated_by`](../reference/clauses-outcomes.md#invalidated_by) clause is removed.
`refresh_card` continues to mutate its card. Supplying a snapshot can leave
the card's externally visible contents unchanged, so `current_label` keeps
`mutation(none)` and its other effects ([`C3`](../contracts.md#c3), [`C5`](../contracts.md#c5)).

**The remaining declarations keep their roles.** `copy_text` still takes a
valid label for its call and describes the same buffer and status results.
The independent watch still manages callback use. Common clauses such as
availability and deprecation stay in their original scopes, and each
resource keeps its sharing and isolation facts
([`L3`](../language.md#l3), [`L5`](../language.md#l5), [`C2–C6`](../contracts.md#c2)).

**The new symbol selects the snapshot implementation.** The fixture provider
and signature mapping stay the same, while [`via`](../reference/clauses-access.md#via) names the code that supplies
the independently owned result.
A documentation or machine view of this package likewise describes an owned
result and its destruction responsibility ([`A2–A5`](../profiles.md#a2),
[`F1`](../profiles.md#f1)).

You can trace these differences by reading the two files. Establishing that
an actual implementation meets either contract would require separate
evidence ([`C8`](../contracts.md#c8)).

## Check yourself

1. After refreshing the card in the owned variant, what does the caller
   still owe for the snapshot?
2. Does [`mapping(identity)`](../reference/clauses-access.md#mapping) allow the original borrowing symbol to serve
   the owned contract?
3. Does receiving an owned result relax the requirement to supply a valid card?

### Answers

1. The caller still owes one call to `destroy_label` when finished with
   the snapshot, including after card refresh or destruction
   ([`C2`](../contracts.md#c2), [`C5`](../contracts.md#c5)).
2. The selected path implements the whole contract. Identity mapping
   preserves that contract; it cannot turn the original borrowed value
   into an independent owned snapshot. This example selects another
   synthetic symbol ([`A2`](../profiles.md#a2)).
3. The caller still supplies a card valid for the call, as stated by
   `valid($card, call)` ([`C3`](../contracts.md#c3)).

## Invalid variant

In the owned variant's `current_label`, delete [`give($result, owned)`](../reference/clauses-outcomes.md#give) and
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

The caller needs the output ownership clause to learn its responsibility
for this result. The label's lifecycle explains how an owner releases it;
`give` explains whether this call supplies ownership or a borrow. Removing
that clause leaves a required fact unanswered.

Return: [Describing a small API](README.md).
Next: [Reviewing AIL](../review/README.md) connects the contracts you have written
to six review dimensions and a feedback template. To try another ownership design,
[compare a view's lifetime in two designs](../review/tasks.md#compare). To follow
how validity is stated across the conformance packages,
[trace validity across the model](../review/tasks.md#model-fit).
