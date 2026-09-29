# Review tasks

> **Purpose:** review guide — use concrete tasks to assess how AIL expresses the API model.
> **Reader:** language designers with the orientation, or reviewers returning from the tutorial.
> **Before this:** [Reviewing AIL](README.md) introduces the six dimensions and feedback format. [The API model](../explanation/model.md) explains the concepts named below.
> **Status:** Draft 0.1 is a proposal under review through its specification
> and synthetic examples. Parser, validator and implementation development
> are future work.
> **Rules:** [L1–L6](../language.md#l1), [C1–C8](../contracts.md#c1) and [A1–A5 with F1](../profiles.md#a1) are canonical. The expected observations here are non-normative.

Choose one task and try its steps before reading the expected observations.
Each task supplies its own starting conditions. Record the step you reached
and the rule or example behind your conclusion; completing every task is
optional. Use the [clause-by-clause walkthroughs](walkthroughs.md) when you
want a longer reading of a [package](../glossary.md#package).

| Task | Model question |
|---|---|
| [Trace](#trace) | In the canvas example, which [declaration](../glossary.md#declaration) owns each fact about the position operation? |
| [Predict](#predict) | Can the [caller](../glossary.md#caller-and-callee) use the store's returned bytes after the call finishes? |
| [Change](#change) | What must a caller supply when the buffer copy gains a pointer input? |
| [Compare](#compare) | How do the earlier byte-store sketch and draft 0.1 express a view's lifetime? |
| [Stretch](#stretch) | When is [callback](../glossary.md#callback) state safe to release if cancellation only requests a stop? |
| [Author](#author) | What does closing the watch require and promise? |
| [Model fit](#model-fit) | How many forms must a reader follow to recover validity across the examples? |

The APIs are invented. The conformance packages use a synthetic
[profile](../glossary.md#profile), [ABI](../glossary.md#abi) catalogue and
[digest tokens](../glossary.md#digest-pin) ([F1](../profiles.md#f1)). The
canvas [import](../glossary.md#import) uses a placeholder digest, identified locally below.
Edits are paper or scratch-file exercises. Expected observations identify
rules to apply by inspection; they are not reports from a validator or a
running implementation.

<a id="trace"></a>

## Trace: locate the operation and the facts it uses

**Model question:** In the invented canvas API, where does a caller find
the type of the position result, and which canvas does the operation use?
[The published description](../explanation/model.md#description) locates the
declarations. [Operations and their values](../explanation/model.md#operations)
locates the receiver and result within the call.

**Goal:** distinguish an imported type from a local declaration, then follow
a [member](../glossary.md#member)'s nominal owner and [callable](../glossary.md#callable) [slots](../glossary.md#slot).

**Conditions:** use the fragment below and [L2](../language.md#l2).
`example::geometry`, version `1`, declares the record `Point`; the current
package declares `Canvas` and `position`. The packages are invented, and the
all-zero digest is a placeholder, not the hash of the geometry document.
A publishable package would need the exact dependency bytes and matching pin.

Fragment — the canvas package with its imported result type and local
receiver. Publication, nominal [lifecycle](../glossary.md#lifecycle), effects, [outcomes](../glossary.md#outcome), access and
[provider](../glossary.md#provider) definitions are omitted. [L2's two-package language-containment
view](../language.md#l2) shows the same containing relationships.

<!-- ail-example: ../examples/rule-reading/canvas.ail region=model -->
```ail
language "0.1";
package example::canvas version "1" {
  import example::geometry version "1"
    digest "sha256:0000000000000000000000000000000000000000000000000000000000000000"
    as Geometry;
  resource Canvas {
    // Lifetime and other nominal contracts omitted.
  }
  fn position(canvas: Canvas) -> Geometry::Point {
    member(@Canvas, instance);
    receiver($canvas);
    input($canvas, borrow);
    retain($canvas, none);
    valid($canvas, call);
    // Effects, outcomes, access and publication context omitted.
  }
}
```

The import gives the external package the local alias `Geometry`.
`member` associates the top-level `position` function with `Canvas`, and
`receiver` identifies its ordinary `canvas` parameter. The input [clauses](../glossary.md#clause)
say that the callee [borrows](../glossary.md#borrow) that canvas and stores no
reference. The caller keeps the canvas usable during the call
([L2](../language.md#l2), [L5](../language.md#l5),
[C3](../contracts.md#c3)). For exact syntax, see
[names and references](../reference/notation.md#names) and
[callables](../reference/notation.md#callable).

**Steps**

1. Write the package/version/declaration identity of `Canvas`, `position`
   and `Point`. Classify `@Canvas` and `@Geometry::Point` as local or imported.
2. Starting at `position`, follow its member owner, its receiver parameter
   and its result type. Decide whether the function is declared inside `Canvas`.
3. Locate `@position::canvas` and `@position::result`. Compare the first
   with `$canvas` in the function. Explain why `Geometry::Point` in the
   signature is written without `@`.
4. In the separate [object example](walkthroughs.md#count-a-property-refers-to-full-accessor-contracts),
   follow `count` to its owner and accessor functions. Locate
   `@write_count::value` and `@read_count::result` in the complete package.

**Expected observations**

`Canvas` and `position` belong to `example::canvas`, version `1`.
`Point` belongs to `example::geometry`, version `1`; `Geometry` is the
import alias, not part of the point's [canonical declaration identity](../glossary.md#canonical-identity).
`@Canvas` is local, while `@Geometry::Point` follows the import
([L2](../language.md#l2)).

The function is a sibling of `Canvas`. Its member clause associates it
with that type, and its receiver clause selects `canvas`. Both
`@position::canvas` and `@position::result` name slots of the local function;
the shared `::` spelling does not make them imported declarations.
`$canvas` is a [place](../glossary.md#place) in the enclosing invocation. Type names resolve by the
same local/imported rules without `@` ([L2](../language.md#l2),
[L5](../language.md#l5), [C1](../contracts.md#c1)).

In `example::objects`, `count`, `read_count` and `write_count` have the same
local `Counter` owner and instance kind. Their explicit receivers are
parameters of the accessor functions. The setter's `value` slot is a `u64`
input; the getter's result slot is a `u64` output. The property points to
those full call contracts ([L5](../language.md#l5)).

**Feedback prompt:** Which relationship in the canvas fragment or
[L2](../language.md#l2) was hardest to recover? Judge whether these forms
serve **Operations and their values** and **The published description**
consistently. Propose a different reference scheme or organization if it
would make the task clearer; [Q4](../explanation/choices.md#q4) remains open.

<a id="predict"></a>

## Predict: let a returned borrow expire too soon

**Model question:** After `view` in `example::buffers` returns, may the
caller still read the sixteen bytes it lends?
[Validity](../explanation/model.md#validity) relates the time of delivery to
the lifetime that keeps those bytes usable.

**Goal:** apply one mutation and identify the rejecting rule, while
distinguishing admissible syntax from a valid contract.

**Conditions:** start with [the complete buffer package](../examples/buffers.ail).
Its store is immutable and owns the viewed bytes. A
[borrow](../glossary.md#borrow) grants access for a stated period without
transferring a release duty. The original result is bounded by the store's
life, with no earlier invalidators.

Fragment — `view` in `example::buffers`, before the mutation. The complete
package supplies the omitted lifetime, effects, storage and access facts.

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

`valid($store, call)` covers the input during the invocation.
`give($result, borrow(owner($store)))` covers the returned bytes after
delivery. These are separate obligations ([C1](../contracts.md#c1),
[C3](../contracts.md#c3), [C5](../contracts.md#c5)). Exact syntax:
[clauses and their values](../reference/notation.md#clause).

**Steps**

1. In a scratch copy, replace only `borrow(owner($store))` with
   `borrow(call)` in the result's `give` clause. This is mutation N07.
2. Locate when `call` ends and when the recipient receives the result.
   Identify the rule that applies to this escaping borrow.
3. Explain why the original input clause can keep its `call` [region](../glossary.md#region).
   Then explain what the original empty invalidator list promises.

**Expected observations**

The replacement has the generic clause/value shape, but the contract is
invalid. The result escapes the call, so its borrow needs a region that
survives delivery. A conforming validator rejects N07 under
[C1](../contracts.md#c1) and [C5](../contracts.md#c5);
recognizing its syntax alone would not establish a valid contract ([L1](../language.md#l1)).

The borrowed input is needed during the call; its entry obligation can use
`call`. For the original output, the caller keeps the store alive
while reading its bytes. An empty invalidator list promises no earlier
invalidating operation, while the owner-lifetime bound still applies
([C3](../contracts.md#c3), [C5](../contracts.md#c5)).

**Feedback prompt:** Does the split between input and output facts help you
answer the **Validity** question? Cite a clause in this fragment or the
escaping-borrow rule in [C1](../contracts.md#c1), and propose an alternative
if the current arrangement obscures the result's lifetime. Compare your
observation with [Q5](../explanation/choices.md#q5).

<a id="change"></a>

## Change: add a borrowed pointer input

**Model question:** If `copy_bytes` also reads a four-byte tag, what storage
must its caller provide, and for how long?
[Storage](../explanation/model.md#storage) describes the bytes;
[Release responsibility](../explanation/model.md#responsibility) and
[Validity](../explanation/model.md#validity) describe access to them.

**Goal:** add a parameter and enumerate every new clause required for it.

**Conditions:** make a hypothetical version `2` of
[`example::buffers`](../examples/buffers.ail). Keep the original copy's
Boolean outcomes and destination promises. Add `tag: ptr<u8>` as its last
parameter. The invented new implementation reads exactly four initialized
binary bytes during the call, stores no tag reference, and changes none of
those bytes. The tag is disjoint from all other accessed memory. Its new
symbol is `fixture_store_copy_tagged`, using F1's synthetic `c` convention
and `symbol` mechanism. These are supplied exercise facts, not facts inferred
from the new type.

Fragment — the added input contract and revised access in the hypothetical
package. The original [copy function](walkthroughs.md#copy-bytes-readable-output-depends-on-success)
supplies the other input, effect and outcome clauses; a complete revised
package also needs its header, providers, environment, declarations and
updated surface description.

<!-- ail-example: ../examples/review/tasks.ail region=tagged-copy -->
```ail
package example::buffers version "2" {
  fn copy_bytes(store: Store, destination: mutptr<u8>, tag: ptr<u8>) -> bool {
    input($tag, borrow);
    retain($tag, none);
    valid($tag, call);
    direction($tag, in);
    aliasing($tag, disjoint);
    extent($tag, buffer(4, 4, elements));
    contents($tag, binary);
    // Existing input, effect and outcome clauses omitted.
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "fixture_store_copy_tagged");
      mapping(identity);
      compatibility(stable);
    }
  }
  // Header, providers, environment, Store and publication context omitted.
}
```

`$tag` selects the input pointer. Its storage contract requires four
readable initialized bytes, while its input contract leaves release with
the caller. The new [access path](../glossary.md#access-path) passes all three parameters in declaration
order ([C3–C4](../contracts.md#c3), [A2](../profiles.md#a2),
[F1](../profiles.md#f1)). Exact syntax: [callables](../reference/notation.md#callable),
[clauses](../reference/notation.md#clause) and [access](../reference/notation.md#access).

**Steps**

1. For each of the seven `$tag` clauses, name the exercise fact it records
   and its rule. Separate facts about the pointer from facts about storage.
2. Check whether either returned outcome needs a state or [ownership](../glossary.md#owned) clause
   for the tag. Check whether the function's existing mutation clause changes.
3. Compare the old and new access signatures. Explain why changing the
   semantic parameter list also requires an implementation path accepting it.
4. List what remains to assemble a complete version `2` package, using the
   original package as the inventory. Keep the original version `1` intact.

**Expected observations**

The seven new clauses are `input`, `retain`, `valid`, `direction`, `aliasing`,
`extent` and `contents`. The first three record a borrowed pointer with no
[retention](../glossary.md#retention) and validity through the call. `direction(in)` describes readable
input storage; disjointness forbids overlap with the other accessed memory.
The [extent](../glossary.md#buffer-extent) requires four initialized elements in capacity for four, and
binary [contents](../glossary.md#contents) add no terminator ([C3](../contracts.md#c3), [C4](../contracts.md#c4)).

The tag contains scalar bytes and is input-only. Its addition creates no
returned reference or writable pointee needing output `state` or `give`.
The existing outcomes still cover the Boolean result and destination bytes.
`mutation(arguments)` remains appropriate because the destination is written;
the tag's read-only pointer and input direction constrain its own storage
([C3–C5](../contracts.md#c3)).

The new symbol receives three explicit parameters; the old two-parameter
path cannot implement that signature unchanged. Identity [mapping](../glossary.md#mapping) requires
faithful lowering of the entire revised contract ([A2](../profiles.md#a2),
[F1](../profiles.md#f1)). The package still needs all original applicable
declarations and clauses, its environment and pinned providers, exports and
a surface description including the revised operation. The distinct package
version gives the revised declaration a distinct identity
([L2–L3](../language.md#l2)). No native implementation is supplied here.

**Feedback prompt:** Which parts of the added contract in
[C3–C4](../contracts.md#c3) are costly to author or easy to omit? Judge the
seven clauses by the **Storage** facts a [consumer](../glossary.md#consumer) needs, and propose a more
usable form if appropriate. Account for a case with a different length,
retention period or aliasing permission before treating a repeated value
as an implicit default.

<a id="compare"></a>

## Compare: express a view's lifetime in two designs

**Model question:** In the earlier byte-store sketch, what keeps `read`'s
bytes usable, and what ends that access? [Validity](../explanation/model.md#validity)
and [Release responsibility](../explanation/model.md#responsibility) supply
the questions against which to compare its notation with draft 0.1.

**Goal:** compare language choices while keeping differences between the
two invented APIs visible.

**Conditions:** the following is a fragment of the
[earlier design's syntax sketch](../../../docs/design/2026-09-22-interface-language.md#7-dedicated-syntax-direction),
not draft 0.1 syntax or a complete contract. Its surrounding sketch defines
`Store`, `replace` and `close`. The design leaves the placement of ownership
in types versus clauses open to a corpus-backed decision.

```text
interface example.byte_store version "1.0" language "0.1" {
    // Resource and other operations omitted from this extract.
    fn read(store: borrow Store) -> borrow bytes {
        lifetime result within store;
        invalidated result by replace(store), close(store);
    }
}
```

The sketch places borrowing in the signature and names lifetime and
[invalidation](../glossary.md#invalidation) within the function. For the current notation, use `view` in
[Predict](#predict): its signature supplies types, and its input and outcome
clauses supply borrowing. The current buffer API is immutable; the sketch's
replacement operation gives it an earlier invalidation event.
Use [the clause grammar](../reference/notation.md#clause) for draft 0.1,
and [the ownership comparison](../explanation/choices.md#expressing-ownership)
for the trade-off.

**Steps**

1. Write the shared promise in ordinary language, then name the event that
   occurs only in the sketch's mutable API.
2. Locate transfer, owner region and invalidation in each notation.
   Explain how draft 0.1 distinguishes owner destruction from earlier mutation.
3. List the other facts the sketch leaves unstated that the complete
   [`view`](../examples/buffers.ail) supplies.
4. Propose a form for the same contract that you would prefer, or explain
   why you would keep the current form. State where its ownership authority lives.

**Expected observations**

Both descriptions lend bytes whose use depends on a live store. The sketch
also names replacement as an invalidator. The empty invalidator list in
draft 0.1's immutable `view` describes different API behaviour; it is not
evidence that the newer language lost that capability.

In draft 0.1, `input` and `give` state transfer, `owner($store)` bounds the
output borrow, and `invalidated_by` names earlier invalidating operations.
Owner destruction already ends that region. Earlier invalidation occurs at
entry to a listed operation involving the owner and requires an appropriate
mutation contract ([C1](../contracts.md#c1), [C3](../contracts.md#c3),
[C5](../contracts.md#c5)).

The complete function also states [availability](../glossary.md#availability) and deprecation, retention,
entry validity, effects, [completion](../glossary.md#completion)/outcome and [output state](../glossary.md#output-state), extent and
contents, and access/compatibility facts. Comparing the sketch's brevity with
the complete function therefore mixes notation with omitted obligations
([L3–L5](../language.md#l3), [C3–C5](../contracts.md#c3), [A2](../profiles.md#a2)).
[Q3](../explanation/choices.md#q3) records the missing rationale for the
ownership placement; these examples do not supply the missing corpus evidence.

**Feedback prompt:** Using the sketch and `view`, which form better serves
**Validity** and **Release responsibility**, and why? Challenge the current
clause placement if warranted. In your alternative, show how two outcomes
could carry different returned obligations without giving the signature and
clauses conflicting authority ([C5](../contracts.md#c5)).

<a id="stretch"></a>

## Stretch: separate cancellation from completed teardown

**Model question:** If the subscription API's cancellation call returns
while a handler is still running, when may the caller discard callback state?
[Callbacks and their schedules](../explanation/model.md#callbacks) asks for
the event after which no invocation still needs that state.

**Goal:** identify what the existing core contract supplies and what an
acknowledged-cancellation protocol would need to add.

**Conditions:** begin with [`example::callbacks`](../examples/callbacks.ail).
Its destructor `unsubscribe` waits for [quiescence](../glossary.md#quiescence):
no callback is running or able to start when teardown returns. In the
hypothetical replacement API, `cancel` only requests a stop; a later
acknowledgement establishes that boundary. This is a different API contract.

Fragment — the original subscription's registration schedule. The complete
package supplies `Handler`, `Subscription`, the destructor and the omitted
callable contracts. `$result` is the returned subscription owner.

<!-- ail-example: ../examples/concepts/choices.ail region=callback -->
```ail
fn subscribe(handler: Handler) -> Subscription {
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
    quiescence(@unsubscribe);
  }
  // Effects, outcome and access omitted.
}
```

The retained callback reference and its permitted invocations share the
returned owner's lifetime. Its unique destructor is the named quiescence
boundary ([C2–C3](../contracts.md#c2), [C6](../contracts.md#c6)). For the two
lifetime arrangements, see [the callback schedule view](../explanation/contracts.md#callbacks).
For exact syntax, see [callback-use blocks](../reference/notation.md#callback-use).

**Steps**

1. Trace the original schedule through `Subscription`'s lifecycle to
   `unsubscribe`. Locate the precondition excluding teardown from the handler.
2. Sketch this hypothetical sequence in words: handler starts; `cancel`
   requests a stop and returns; handler finishes; acknowledgement arrives.
   Mark the earliest event that establishes safe release of callback state.
3. Explain why merely renaming the quiescence target to `@cancel` would
   misdescribe that sequence.
4. List the events, ordering and lifetime facts a profile would have to
   define. Identify which of those facts F1 actually supplies.

**Expected observations**

The original `Subscription` has a unique destructor `unsubscribe`.
`requires(outside_callback(@subscribe::handler))` prevents it from waiting
for the very invocation that called it. On return, quiescence holds; starting
teardown alone is insufficient ([C2](../contracts.md#c2),
[C3](../contracts.md#c3), [C6](../contracts.md#c6)).

In the hypothetical sequence, the acknowledgement is the promised boundary.
The current quiescence clause would instead assert that cancellation return
already ended every possible invocation. That false description could cause
a caller to release state while it is in use ([C6](../contracts.md#c6)).

The profile needs explicit cancellation and acknowledgement events, their
ordering relative to invocations, and rules for keeping and releasing the
callback [representation](../glossary.md#representation) and its [captures](../glossary.md#callback-captures).
It also needs to define how consumers observe those events and handle
teardown invoked from a callback. The exact protocol remains a design task.
F1 supplies owner-scoped retention and quiescent destruction, not this
acknowledged-cancellation extension ([A1](../profiles.md#a1),
[C6](../contracts.md#c6), [F1](../profiles.md#f1)).

**Feedback prompt:** Does the core/profile boundary in [C6](../contracts.md#c6)
give **Callbacks and their schedules** the right expressive scope? Use the
sequence above and the [pressure case](../conformance.md#pressure-cases-outside-the-synthetic-profile)
to argue for retaining it, changing it or replacing the design. Separate a
missing model concept from a missing language form or provider definition.

<a id="author"></a>

## Author: describe closing a watch

**Model question:** For `watch_close` in the
[small C header](../explanation/unsaid.md#a-small-api), who takes the release
duty, and what may the caller assume when the call returns?
[Entities that outlive a call](../explanation/model.md#entities) supplies
the watch's lifecycle; [Release responsibility](../explanation/model.md#responsibility)
describes this operation's transfer.

**Goal:** write one callable contract from stated API facts, then account
for the work its clauses require.

**Conditions:** use the following deliberately bounded lifetime-only case.
The watch is a unique [opaque resource](../glossary.md#opaque-resource) with `watch_close` as its destructor.
There are no stored callbacks in this exercise. The caller supplies a live
owned watch; closing [consumes](../glossary.md#consume) it at entry, retains nothing, and returns
synchronously with one successful unit completion. Entry may occur on any
[executor](../glossary.md#executor), independent uses of the same watch are serialized, and nested
[re-entry](../glossary.md#re-entrancy) is forbidden. The function is non-variadic and changes no live
input contents; destruction follows its lifecycle. This fixes one possible
contract rather than deriving those promises from C syntax.

```c
void watch_close(Watch *watch);
```

For this exercise's **Reaching the code** facts, assume F1's synthetic
`fixture` profile and `native` ABI aliases, environment `test`, and a
function symbol `watch_close` using the `c` convention with identity
mapping and stable fixture-domain compatibility. The public operation is
available in `test` and not deprecated. These are invented provider facts,
not a mapping of the full watch header's callback/context protocol.

**Steps**

1. In a scratch `review::watch_lifetime` package, write the function's
   signature and clauses from the conditions. Treat `Watch` as the declared
   opaque resource type; consult [L4](../language.md#l4) and
   [the callable grammar](../reference/notation.md#callable).
2. Supply the seven callable-effect clauses from [C3](../contracts.md#c3),
   then the input, outcome and access facts. Decide whether input `valid`,
   output `state` or `give` belongs in this particular contract.
3. Count clause statements, including those inside the outcome and access
   blocks. Exclude declarations, block headers and comments. Group the
   count by the model questions the statements answer.
4. Identify the package and resource facts still needed before this function
   could belong to a complete publication. Compare with the complete
   [buffer destructor](../examples/buffers.ail).

**Expected observations**

Fragment — one answer for the stated conditions. A complete package would
also supply the language header, surface and exports, pinned providers,
environment and `Watch` declaration with its lifetime, sharing, [isolation](../glossary.md#isolation),
availability, deprecation and interface-conformance list.

<!-- ail-example: ../examples/review/tasks.ail region=close -->
```ail
package review::watch_lifetime version "1" {
  fn watch_close(watch: Watch) -> unit {
    available([test]);
    deprecated(no);
    execution(sync);
    completions([returned]);
    executor(any);
    concurrency(serial);
    reentrancy(forbidden);
    mutation(none);
    variadic(false);
    input($watch, consume);
    retain($watch, none);
    outcome closed {
      when(returned, any);
      meaning(success);
    }
    access direct in [test] {
      abi(native, "c");
      via(fixture, "symbol", "watch_close");
      mapping(identity);
      compatibility(stable);
    }
  }
  // Header, providers, environment, Watch and publication context omitted.
}
```

`Watch` already denotes an opaque [handle](../glossary.md#handle); `ptr<Watch>` would instead
describe storage containing a handle ([L4](../language.md#l4)). Consumption
transfers the release obligation at entry and requires a valid owned input.
The separate `valid` clause applies to borrowed inputs. A unit result has
no output value needing `state` or `give`. Destruction ends dependent
borrows through lifecycle, and does not require `mutation(arguments)`
([C2–C3](../contracts.md#c2), [C5](../contracts.md#c5)).

There are 17 clause statements: two for availability/deprecation, seven for
callable effects, two for input transfer/retention, two inside the outcome
and four inside the access path. These groups cross model concepts: for
example, the effect clauses include both **How a call finishes** and
**Where and when calls run**. The count covers this function only
([L3](../language.md#l3), [L5](../language.md#l5),
[C3](../contracts.md#c3), [C5](../contracts.md#c5), [A2](../profiles.md#a2)).

Its supporting `Watch` needs `lifecycle(unique, @watch_close)` and nominal
sharing/isolation consistent with the unrestricted executor and unique
lifetime. The package also needs the publication and dependency facts listed
above ([L1–L5](../language.md#l1), [C2](../contracts.md#c2),
[A1](../profiles.md#a1)). Adding the original header's stored-callback
behaviour would require its own schedule, teardown and representation
account; this exercise does not supply one ([C6](../contracts.md#c6),
[A2](../profiles.md#a2)).

**Feedback prompt:** Which of the 17 statements helped you express the
watch's **Release responsibility**, and which made the whole operation hard
to author? Cite your fragment and [C3](../contracts.md#c3) or
[A2](../profiles.md#a2). Propose a different organization if useful, while
keeping the caller's release duty and implementation access recoverable.
Report what you had to look up as well as what you could infer.

<a id="model-fit"></a>

## Model fit: collect the forms that express validity

**Model question:** Across the store view, subscription and object data
examples, what tells the caller when borrowed access ends?
[Validity](../explanation/model.md#validity) is one concept, but input
validity, returned regions, mutation and callback teardown contribute
different parts of the answer.

**Goal:** collect the constructs that express validity in the three complete
conformance packages, and judge whether a reader can recover the concept
clearly and completely.

**Conditions:** use [`buffers.ail`](../examples/buffers.ail),
[`callbacks.ail`](../examples/callbacks.ail) and
[`objects.ail`](../examples/objects.ail). The earlier tasks locally show
input/owner validity and callback scheduling. The following extract locates
the remaining lifetime form on the object package's data declarations.

Fragment — two static borrows in `example::objects`. The complete package
supplies four-byte extents, binary contents, sharing/isolation, availability,
providers and access paths. A [region](../glossary.md#region) named `static`
lasts for the loaded API instance; F1 ends it at provider unload
([C1](../contracts.md#c1), [F1](../profiles.md#f1)).

<!-- ail-example: ../examples/review/tasks.ail region=static-borrows -->
```ail
package example::objects version "1" {
  constant fixed_bytes: ptr<u8> {
    give($result, borrow(static));
    invalidated_by($result, []);
    // Extent, contents, sharing, isolation, availability and access omitted.
  }
  global pointer_value: ptr<u8> {
    mutable(false);
    give($result, borrow(static));
    invalidated_by($result, []);
    // Extent, contents, sharing, isolation, availability and access omitted.
  }
  // Header, dependencies and remaining declarations omitted.
}
```

These clauses live directly in data declarations. Function outputs put
their borrowed-region clauses in outcomes. Both forms still identify a
lifetime bound and any earlier invalidators ([C5](../contracts.md#c5),
[C7](../contracts.md#c7)). Exact syntax: [declaration productions](../grammar.ebnf)
and [outcomes](../reference/notation.md#outcome).

**Steps**

1. Read every declaration in the three packages. Make a table of each form
   that contributes to validity, with at least one location and its rule.
   Include relationships supplied by another declaration, not just clauses
   with a lifetime word in their name.
2. Separate the direct lifetime statements from prerequisites and boundaries
   supplied by **Entities that outlive a call**, **How a call finishes** and
   **Callbacks and their schedules**. Note which facts are repeated and
   which answer different questions.
3. Check the table against the walkthroughs for
   [buffers](walkthroughs.md#buffers), [callbacks](walkthroughs.md#callbacks)
   and [objects](walkthroughs.md#objects). Identify a validity variant that
   these three packages do not exercise.
4. Judge the fit: can a person or tool recover the answer once and completely?
   Propose grouping, naming or model changes where the forms obstruct that task.

**Expected observations**

The following groups account for the lifetime forms in this bounded corpus.
They identify related concepts rather than treating every clause as another
spelling of **Validity**.

| Contribution | Locations and interpretation |
|---|---|
| Input validity | `valid(..., call)` on borrowed store, destination, handler and receiver inputs; consuming `destroy`/`unsubscribe` inputs instead need validity at entry ([C3](../contracts.md#c3)). |
| Returned borrow duration | `view` uses `give(..., borrow(owner($store)))`; the two object data declarations use `give(..., borrow(static))` ([C1](../contracts.md#c1), [C5](../contracts.md#c5), [C7](../contracts.md#c7)). |
| Earlier invalidation and changes | The output borrows all have empty `invalidated_by` lists. `mutation` describes permitted changes to live input state, including `copy_bytes`'s destination and `write_count`'s receiver; mutation alone does not declare a borrow invalidator ([C3](../contracts.md#c3), [C5](../contracts.md#c5)). |
| Owner end | `Store` and `Subscription` name unique destructors; `Counter` uses runtime reference counting. Owner regions end at destruction/final release, while the static data borrows end at F1 provider unload ([C1–C2](../contracts.md#c1), [F1](../profiles.md#f1)). |
| Checked release relationship | The `lifetime` [pattern](../glossary.md#pattern) declares typed resource and operation [roles](../glossary.md#role), with `law(releases, release, resource_type)`. The `store_lifetime` instance binds them to `Store` and `destroy`. This checks the existing destructor relationship; it creates no second release boundary or ownership authority ([L6](../language.md#l6)). |
| Readable output | Outcome `state` clauses establish usable outputs. In particular, failed `copy_bytes` leaves no readable destination elements; this is output state rather than a shorter owner lifetime ([C5](../contracts.md#c5)). |
| Saved callback use | `subscribe` retains the handler for `owner($result)` and gives its callback use that same scope. `quiescence(@unsubscribe)` and the destructor's `outside_callback` precondition establish safe teardown ([C3](../contracts.md#c3), [C6](../contracts.md#c6)). |

The examples therefore include call, owner and static durations but no
nonempty list of earlier invalidators. For that contrasting case, inspect
the tutorial's [borrow exercise](../tutorial/02-lending.md): refresh can
end a view before its owner dies. The supported construct and its required
owner/mutation relationship are already in [C5](../contracts.md#c5).
Other scheduling variants, such as acknowledged cancellation, still need
the extension discussed in [Stretch](#stretch).

**Feedback prompt:** Does the model concept **Validity** give you a useful
way to assemble these facts, or would you divide or connect the concepts
differently? Cite a row, a declaration or [C1](../contracts.md#c1), and
distinguish a model change from a notation change. Explain any duplicated,
missing or scattered authority you found; the table is a starting account
to challenge, not a required verdict.

## Record the result

Use [the feedback template](README.md#recording-feedback), including the
tasks and steps you actually attempted. A difficulty in one fragment does
not establish a result for the whole language, and finishing a paper task
does not establish runtime safety. Follow the relevant
[open question](../explanation/choices.md#open-questions) or
[reference entry](../reference/README.md) when you need to narrow the claim.

Return to [Reviewing AIL](README.md) or [the documentation map](../README.md#paths-through-the-documentation).
