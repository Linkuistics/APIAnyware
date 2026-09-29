# Reviewing AIL

> **Purpose:** review guide — judge how well AIL describes API behaviour and [binding](../glossary.md#binding) obligations, and record concrete feedback.
> **Reader:** language designers who have read the orientation; API authors and tool implementers can use the same tasks.
> **Before this:** [the overview](../README.md) and [the API model](../explanation/model.md). [Using an API across languages](../explanation/unsaid.md) explains the domain through a small C API.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [L1–L6](../language.md#l1), [C1–C8](../contracts.md#c1) and [A1–A5 with F1](../profiles.md#a1) are canonical. This guide is non-normative.

## What this review is for

AIL is a tool for writing down the [API model](../explanation/model.md).
A useful review asks whether a person can state what [callers](../glossary.md#caller-and-callee) need to know,
and whether another person or tool can recover those facts accurately.
Feedback can challenge the model's distinctions, the language's way of
expressing them, or the documentation that connects the two. The examples
make the current design inspectable; they leave its merits open to judgement.

For example, [Validity](../explanation/model.md#validity) asks how long a
caller may use bytes lent by a store. Compare access that lasts until the
store dies with access that a refresh operation ends sooner. AIL records
the lifetime bound and earlier invalidating operations separately
([C1](../contracts.md#c1), [C5](../contracts.md#c5)).

Fragment — `view` in the invented `example::buffers` [package](../glossary.md#package). The
[complete package](../examples/buffers.ail) supplies `Store`, its destructor,
publication context and the omitted [callable](../glossary.md#callable) facts. Its
[profile](../glossary.md#profile), [ABI](../glossary.md#abi) catalogue and
[digest tokens](../glossary.md#digest-pin) are synthetic ([F1](../profiles.md#f1)).

<!-- ail-example: ../examples/concepts/choices.ail region=borrow -->
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
  // Retention, remaining effects, extent, contents and access omitted.
}
```

Here `store` is the local function's input, and `$result` addresses its
returned pointer. The caller keeps the input usable during the call.
To use the returned bytes, the caller keeps the store alive for the result's
owner [region](../glossary.md#region). The empty invalidator list promises no
earlier [invalidation](../glossary.md#invalidation).
These [clauses](../glossary.md#clause) answer related questions at different moments
([C1](../contracts.md#c1), [C3](../contracts.md#c3), [C5](../contracts.md#c5)).
Whether their placement helps a reader find that whole answer is a review
question. The glossary explains [places](../glossary.md#place) and
[outcomes](../glossary.md#outcome); the [place](../reference/notation.md#places)
and [outcome](../reference/notation.md#outcome) grammar is available for exact lookup.

Use these two rows to keep the input's call duration separate from the
returned view's owner duration when judging the clause placement.

| Value in `view` | What keeps it usable | When that obligation or permission ends |
|---|---|---|
| Input `store` | The caller keeps the handle valid | The input's `valid(..., call)` obligation lasts through the call |
| Returned bytes | The caller keeps the owning store alive | The borrow ends when the owner is destroyed; the empty list promises no earlier invalidator |

Choose a route through the guide:

- [Read the conformance examples](walkthroughs.md) for clause-by-clause
  readings of the buffer, [callback](../glossary.md#callback) and object packages, grouped by model concept.
- [Try a review task](tasks.md) to trace, predict, change, compare, stretch,
  author or assess the fit between a model concept and its notation.
- Use [the reference indexes](../reference/README.md) when you need a clause,
  applicability rule or rejection case, then return to the task.

## The six dimensions

Use the dimensions as different questions about the same work. Record the
example and the step that led to your judgement. A successful trace can still
reveal an awkward design; a failed trace can reveal a documentation problem,
a language problem, or a missing distinction in the model.

### Syntax and readability

For [Validity](../explanation/model.md#validity), can a reader find the
facts that determine when access ends without having to interpret unrelated
clauses? The `view` fragment above separates input validity from the
returned [borrow](../glossary.md#borrow), and the full function places other facts around both.

After [Predict](tasks.md#predict), identify the words or placement in
[`view`](../examples/buffers.ail) that made the lifetime clear or misleading.
How would you arrange the same facts differently? Check your alternative
against [C1](../contracts.md#c1) and [C5](../contracts.md#c5), including the
case where an operation ends the borrow before its owner dies.

### Conceptual consistency

[Operations and their values](../explanation/model.md#operations) gives each
callable its own parameters and result. [The published description](../explanation/model.md#description)
locates [declarations](../glossary.md#declaration) in packages. A reader needs to distinguish a reference
to another package from a reference to another operation's parameter.

In [Trace](tasks.md#trace), compare the [imported](../glossary.md#import) point type with the canvas
[member](../glossary.md#member)'s receiver and result. Which forms in [L2](../language.md#l2) and
[C1](../contracts.md#c1) express one recognisable relationship, and which
invite a different interpretation? Propose a naming or reference scheme if
the current one conflates concepts. [Q4](../explanation/choices.md#q4)
records the open question about these spellings.

### Expressive scope

For [Callbacks and their schedules](../explanation/model.md#callbacks), a
caller needs to know when callback state is no longer in use. Compare a
destructor that waits for every invocation to finish with cancellation
that returns before a later acknowledgement. These need different accounts
of the boundary at which state can be released.

Use [Stretch](tasks.md#stretch) and the callback
[pressure case](../conformance.md#pressure-cases-outside-the-synthetic-profile)
to judge [C6](../contracts.md#c6)'s boundary between core and profile-defined
protocols. Which facts can draft 0.1 express, and which need more semantics?
Would you move that boundary, change the model, or choose a different language
design? Contrast this with a refresh-invalidated view, which already has a
core form ([C5](../contracts.md#c5)).

### Authoring burden

For [Storage](../explanation/model.md#storage), adding one pointer input
requires facts about its storage as well as the pointer value. For
[Release responsibility](../explanation/model.md#responsibility), even a
small release operation also needs its surrounding [binding contract](../glossary.md#binding-contract).

Try [Change](tasks.md#change) or [Author](tasks.md#author). Separate clauses
that contribute distinct facts from repetitions that add work. Using
[C3–C5](../contracts.md#c3) and the resulting fragment, identify what you
would combine, derive or make easier to write. Explain how a [consumer](../glossary.md#consumer) would
still recover the fact, and how an author would state an exceptional case.
Clause counts locate the work; they do not by themselves measure difficulty.

### Discoverability

A reviewer asking “who releases this value?” starts from
[Release responsibility](../explanation/model.md#responsibility), while a
reviewer encountering a clause starts from its notation. Both need a route
to the same meaning and its applicable rules.

Starting at the [model-to-notation map](../explanation/model.md#from-the-model-to-ail),
find who releases the store created in [`buffers.ail`](../examples/buffers.ail).
Then start at that example's output clause and find the model concept and
[C5](../contracts.md#c5). Where did either route require guessing? Cite the
page or rule that lost you, and suggest a route, term or language change.
The [Model fit task](tasks.md#model-fit) extends this check across examples.

### Fitness for producers and consumers

[Writers, checkers and users](../explanation/model.md#agreement) asks whether
an analysis tool can emit the description and a binding generator or renderer
can recover the same facts. [Reaching the code](../explanation/model.md#access)
adds a practical test: the object getter has two [access paths](../glossary.md#access-path) that both need
to preserve its contract.

Inspect [the getter's two paths](walkthroughs.md#read-count-one-member-two-ways-to-call-it)
and [Two views of one contract](../conformance.md#two-views-of-one-contract).
Which facts would your proposed [producer](../glossary.md#producer) have evidence to write? Which
would each consumer need to recover? Identify anything [A2](../profiles.md#a2)
or [A5](../profiles.md#a5) makes difficult, ambiguous or unnecessarily costly.
Describe a better way to express those facts if one is warranted. Distinguish an
unsupported consumer operation from an incomplete API description.

## Recording feedback

Use one record per observation. Include the point you reached if you could
not finish a task; an unfinished task is useful evidence too.

```text
Dimension:
Location (rule, example/declaration or page/heading):
Task and extent attempted:
Observation (what you read, tried or could not determine):
Why it matters (for which caller, author or tool):
Alternative (optional):
```

“This design is wrong” is a legitimate conclusion. Tie it to the contract
or reader task it fails, and separate the observed difficulty from your
proposed remedy. You can report an ambiguity without supplying a replacement
design. If a wording change is enough, identify the wording; if the model or
language needs to change, state the distinction it should express.

## Known open questions

The [open-question register](../explanation/choices.md#open-questions)
currently includes normative presentation, [dependency closure](../glossary.md#dependency-closure) versus
[callback captures](../glossary.md#callback-captures),
the rationale for [ownership](../glossary.md#owned) clauses, reference spelling, entry versus output
validity, and rule-citation precision. Add evidence to those questions or
challenge another choice. Their presence records uncertainty, not an answer
the review is expected to endorse.

## Limits

These tasks support inspection of a proposal. The APIs, fixture
[profile](../glossary.md#profile), [ABI](../glossary.md#abi) catalogue and
[digest tokens](../glossary.md#digest-pin) are synthetic. They establish no
facts about real operating-system APIs ([F1](../profiles.md#f1)).
The [verification record](../conformance.md#verification-record) describes
historical static checks; it supplies no shipped parser, semantic validator,
native fixture or binding generator to run.

You can inspect syntax, identify the rule a conforming validator would apply,
and reason about the declared behaviour. Implementation truth, runtime safety,
coverage of real [providers](../glossary.md#provider) and authoring cost at production scale need further
evidence ([C8](../contracts.md#c8), [A1](../profiles.md#a1)).
The expected observations in [the tasks](tasks.md) are readings to compare
with your own, not tool diagnostics or proof that the design is suitable.

Continue to [Review tasks](tasks.md), or return to
[the documentation map](../README.md#paths-through-the-documentation).
