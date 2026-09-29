# Describing a small API

> **Purpose:** tutorial — describe a synthetic API in complete AIL checkpoints, then change its contract.
> **Reader:** language designers new to [API binding](../glossary.md#binding) who can read C signatures.
> **Before this:** [Using an API across languages](../explanation/unsaid.md) and [A model of API behaviour and binding obligations](../explanation/model.md); the [contract explanation](../explanation/contracts.md) develops the notation.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [language and publication](../language.md#l1), [contracts](../contracts.md#c1), [access paths](../profiles.md#a2) and the [synthetic fixture catalogue](../profiles.md#f1) are canonical.

You will take the API author's role and describe an invented library. First
you will explain how a program creates and destroys a card. Then you will add
operations for reading its label, copying text and receiving notifications.
Finally, you will change who owns a returned label and trace what that change
requires elsewhere in the description.

Work through the [five parts](#the-five-parts) in order, starting with
[a package and one resource](01-lifetime.md). Each part identifies its new
material before presenting the complete example. If you are returning for the
change exercise, go directly to [the owned snapshot](05-access-and-change.md#guided-change-an-owned-snapshot).
The [overview's workflow map](../README.md#who-writes-and-uses-an-ail-description)
shows how API authors and tools would use the descriptions you write.

## What you will describe

### A card and its current label

Imagine a card displaying a short label such as `READY!!`. A program creates
the card, asks for its current label and eventually destroys the card. The
card is one of the model's [Entities that outlive a call](../explanation/model.md#entities):
its identity connects creation with later use and destruction. During
these operations the program is the [caller](../glossary.md#caller-and-callee)
and the library function is the callee.

Creation illustrates [How a call finishes](../explanation/model.md#outcomes)
and [Release responsibility](../explanation/model.md#responsibility). If it
succeeds, the program receives a card and becomes responsible for destroying it.
AIL calls that result [owned](../glossary.md#owned). If creation
returns null, allocation failed and there is nothing to destroy. The first
part records both results and names `destroy_card` as the operation that
takes over responsibility and destroys the card.

The card owns its current label. `current_label` lends the program access to
that label while the card keeps ownership. This is a [borrow](../glossary.md#borrow):
the program may use the label for a stated period. AIL describes that agreement;
it implies no Rust-style static checking or exclusivity.

[Validity](../explanation/model.md#validity) answers how long the program
can use the lent label. Two events end that access. Destroying the card ends
the label's lifetime.
Refreshing the card replaces its label, so the program stops using the old
label as soon as `refresh_card` begins. Ending access while the card remains
alive is [invalidation](../glossary.md#invalidation). Part 2 describes both
boundaries. A `Label` value is a [handle](../glossary.md#handle) identifying
the label; its type stays the same after refresh, so the caller also needs
the lifetime contract to know when it can use that handle.

### Copying text into the program's storage

Apply [Storage](../explanation/model.md#storage) to the next operation:
to obtain text, the program reserves eight bytes and passes their address to
`copy_text`. On success, the library writes seven nonzero UTF-8 code units
followed by a zero terminator. For `READY!!`, each visible character occupies
one code unit. Other UTF-8 text can use several code units for a character;
the contract counts code units. A refresh can choose another label of the
same length, and the exact spelling is left open.

To describe [How a call finishes](../explanation/model.md#outcomes), connect
the readable bytes to the status that the function returns. `copied` (`0`) means the program can read
the text. `unavailable` (`1`) means the program reads the status and leaves
the output bytes unread. Part 3 describes the storage required before the
call and what the library promises on each result.

### Receiving notifications and finishing with them

[Callbacks and their schedules](../explanation/model.md#callbacks) describe
the next relationship. The library accepts a function to receive label-change
numbers. A function supplied for the library to invoke is a [callback](../glossary.md#callback).
`watch_labels` stores a reference to this callback and returns a separate
`Watch` identifying the subscription. It may send notifications after
registration returns, and it may send none.

To end the subscription, the program calls `destroy_watch` from outside its
notification callback. When destruction returns, every callback invocation
has finished and that subscription can start no more. This condition is
[quiescence](../glossary.md#quiescence). Part 4 describes the retained
callback, the permitted notifications and that final boundary.

Each notification contains only a number. The subscription takes no `Card`
argument and retains no card. A program using a label still follows that
label's borrow contract, including its refresh cutoff.

### Changing the returned label

[Reaching the code](../explanation/model.md#access) connects an operation
to its implementation. Part 5 first explains how the description identifies
that code. It then introduces a separate API variant: `current_label` returns
an independent owned snapshot. This changes [Release responsibility](../explanation/model.md#responsibility).
The program can keep that snapshot after
refreshing or destroying its card. In exchange, it takes responsibility for
calling `destroy_label` on the snapshot. You will change the description and
follow every affected obligation.

The names, text length and possible failures above are choices for this
invented API. The examples use the synthetic fixture
[profile](../glossary.md#profile), catalogue and
[digest tokens](../glossary.md#digest-pin) defined by [`F1`](../profiles.md#f1).
The profile supplies rules for interpreting the examples, including an
abstract [ABI](../glossary.md#abi) for passing values and making calls.
Applying AIL to a real library would require evidence about its behaviour
and definitions of its actual calling mechanisms.

AIL supplies notation for these promises. Another API could use binary data,
different text lengths or a different notification protocol.
[Design choices](../explanation/choices.md) explains the distinction between
what an API promises and how AIL expresses it.

## The five parts

Apply [The published description](../explanation/model.md#description)
to gather these API facts. Each part supplies a complete
[package](../glossary.md#package): a named, versioned description of the
operations included so far. The first package
contains everything needed to create and destroy a card. Later packages add
the label, copying and subscription operations with their own complete
contracts. This lets you learn one group at a time while seeing all the facts
that group requires ([`L2–L3`](../language.md#l2)).

Here is the shape you will start with. The package contains the card type
and the functions that create and destroy cards.

Fragment — shows the first checkpoint's document and declaration structure.
The [complete lifetime package](../examples/tutorial/01-lifetime.ail) also
supplies publication, environment, provider and declaration contracts.

<!-- ail-example: ../examples/tutorial/reading-fragments.ail region=index-shell -->
```ail
language "0.1";
package tutorial::lifetime version "1" {
  resource Card { /* Resource contract omitted. */ }
  fn create_card() -> nullable<Card> { /* Call contract omitted. */ }
  fn destroy_card(card: Card) -> unit { /* Call contract omitted. */ }
}
```

This shell connects [Operations and their values](../explanation/model.md#operations)
to the persistent card. `Card` identifies the entity; creation returns its
handle or null, and destruction receives a handle with no result value.
The three [declarations](../glossary.md#declaration) share the package's
name and version ([`L1–L2`](../language.md#l1), [`L4`](../language.md#l4)).
Part 1 develops the [located card contracts](01-lifetime.md#steps).
For exact syntax, see [Package shell](../reference/notation.md#shell) in the grammar reference.

Use the map to open a part or its complete checkpoint file. The final row
includes both the assembled example and the separate ownership exercise.

| Part | What you will describe | Model concepts | Complete checkpoint |
|---|---|---|---|
| [1. A package and one resource](01-lifetime.md) | Create a card, handle allocation failure and destroy an owned card. | [Operations and their values](../explanation/model.md#operations); [How a call finishes](../explanation/model.md#outcomes); [Entities that outlive a call](../explanation/model.md#entities); [Release responsibility](../explanation/model.md#responsibility); [The published description](../explanation/model.md#description). | [Card lifetime](../examples/tutorial/01-lifetime.ail) |
| [2. Lending access](02-lending.md) | Lend a label until card destruction or an earlier refresh. | [Release responsibility](../explanation/model.md#responsibility); [Validity](../explanation/model.md#validity). | [Label lending](../examples/tutorial/02-lending.ail) |
| [3. Caller-supplied storage and failure](03-storage.md) | Copy text into eight bytes and say what is readable on each status. | [Storage](../explanation/model.md#storage); [How a call finishes](../explanation/model.md#outcomes). | [Text copying](../examples/tutorial/03-storage.ail) |
| [4. Callbacks and teardown](04-callbacks.md) | Store a callback, permit later notifications and finish all callback use. | [Where and when calls run](../explanation/model.md#execution); [Callbacks and their schedules](../explanation/model.md#callbacks). | [Subscription](../examples/tutorial/04-callbacks.ail) |
| [5. Reaching the code, and changing the contract](05-access-and-change.md) | Identify the implementation and give the caller an owned label snapshot. | [Reaching the code](../explanation/model.md#access); [Release responsibility](../explanation/model.md#responsibility). | [Finished package](../examples/tutorial/05-finished.ail) and [owned variant](../examples/tutorial/05-owned.ail) |

Each file has a different package name so it can be read independently.
Part 5's owned variant describes a deliberately different API contract.
Matching names such as `Card` in two packages remain distinct nominal types
because their package identities differ ([`L2`](../language.md#l2)).

Every function includes an [access path](../glossary.md#access-path) describing
how a tool reaches its code. In the first four parts, copy the supplied
synthetic symbol paths along with the other clauses. Part 5 develops their
meaning. They belong in each complete description from the start
([`A2`](../profiles.md#a2)).

## How to check your work

Apply [Writers, checkers and users](../explanation/model.md#agreement):
you supply the API facts, then inspect whether the description records them
consistently. Read each checkpoint as a document. Compare it with your
description and follow its references: for example, follow the card's `lifecycle` to its
destructor in [part 1's located resource example](01-lifetime.md#card-lifetime).
Use the expected observations to explain what a caller does at
each step. Answer the questions before opening the answers, then inspect the
invalid variant and the rule that rejects it.

The complete-package labels record inspection against the grammar and rules.
This exercise uses that same form of inspection; parser and semantic-validator
execution remain future work. Testing whether a library actually honours
its stated contract requires separate implementation evidence
([`C8`](../contracts.md#c8)).

The full packages keep every required [clause](../glossary.md#clause) visible,
including repeated facts. You can therefore judge both the meaning of the
contract and the work of writing it. Use each part's local links to move
between its steps, checkpoint and questions; use the explanations and rule
citations for deeper lookup.

Return: [API Interface Language](../README.md).
Next: [1. A package and one resource](01-lifetime.md).
