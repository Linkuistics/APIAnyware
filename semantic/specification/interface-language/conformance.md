# Conformance corpus and implementation obligations

This is an acceptance specification for future implementations. The examples
have no native implementation and use the synthetic catalogue in
[F1](profiles.md#f1-synthetic-fixture-catalogue). They assert contracts of invented
APIs, not facts about similarly shaped platform APIs. A production resolver must
not accept the fixture catalogue's test digest tokens.

## Positive specifications

| File | Required interpretation |
|---|---|
| [buffers.ail](examples/buffers.ail) | Nullable resource creation has two exhaustive outcomes. Successful creation produces one destruction obligation. View borrows sixteen bytes until store destruction. Copy writes sixteen bytes on success and produces unreadable output on failure. Typed pattern binding identifies the actual destructor. |
| [callbacks.ail](examples/callbacks.ail) | Registration retains a callback whose captures may cross executors. Zero or more notifications may start after registration returns. Destruction blocks until quiescence; it cannot be called within that callback. Closure invocation, registration schedule and token ownership are separate contracts. |
| [objects.ail](examples/objects.ail) | Object lifetime uses runtime retain/release. Main-thread property accessors have custom selectors. The getter has message and source-build alternatives preserving the same contract. An array symbol address differs from loading a pointer variable. Source sendability does not stand for thread safety. |

These are complete examples within their declared finite fixture surfaces. They
do not establish production Apple, C, Rust, Zig, CLR or Wayland provider support.
Patterns add no hidden fallback behaviour: `store_lifetime` agrees with the
already specified lifecycle.

## Rejection mutations

Each mutation starts from the specified positive example unless described as a
small independent input. Apply only that mutation. Except N11, which tests truth
against an implementation, a validator must reject for the stated rule, not crash
or silently repair the input. Diagnostics can include
additional causally related failures. Rule IDs are normative; diagnostic wording
and machine-code spelling are implementation choices.

| ID | Mutation / input | Required rejection |
|---|---|---|
| N01 | Change `nullable<Store>` to `unknown` in buffers. | L3/L4: unresolved type, no unknown contract type. |
| N02 | Delete `give($result, owned)` in `create.created`. | C5: valid reference output lacks ownership. |
| N03 | Add another parameter named `store` to `view`. | L2: duplicate parameter name. |
| N04 | Rename Store to `u8`. | L2/L4: reserved core type name. |
| N05 | Delete the null outcome of `create`. | C5: uncovered nullable discriminator. |
| N06 | Give both `create` outcomes `nonnull($result)`. | C5: overlap and missing null case. |
| N07 | Change the view's output to `borrow(call)`. | C1/C5: escaped borrow expires at delivery. |
| N08 | Change view's owner to `$absent`. | C1/L2: unresolved place. |
| N09 | Delete `lifecycle` on Store. | C2: no release protocol for owned handles. |
| N10 | Point Store lifecycle to `@view`. | C2: destructor signature/consumption mismatch. |
| N11 | Mark failed copy output valid, while documenting that nothing initializes it. | Authoring/implementation contract contradiction; prose cannot negate `state(valid)`. A syntax validator alone cannot detect a lying implementation; an implementation conformance test must. |
| N12 | Use `when(returned, equal($destination[], 0))` in failed copy while retaining `state($destination[], invalid)`. | C5: invalid, non-scalar discriminator; also does not share the successful outcome's discriminator. |
| N13 | Change destination to `ptr<u8>` while retaining `direction(out)`. | C4: output requires writable pointer. |
| N14 | Change buffer length/capacity from `16,16` to `17,16`. | C4: extent inequality. |
| N15 | Change callback scope to `call` while retaining `timing(after_return)`. | C6: impossible schedule/scope. |
| N16 | Delete callback `quiescence`. | C6: no complete teardown guarantee. |
| N17 | Change callback count to `count(2,1)`. | C6: impossible bounds. |
| N18 | Delete unsubscribe's `outside_callback` requirement. | C6: blocking quiescence lacks deadlock exclusion or supported reentrant protocol. |
| N19 | Set Handler `sharing(confined)` with `isolation(none)`. | C2: missing confinement executor. |
| N20 | Duplicate one `input` for the same slot. | L5: duplicate keyed clause; separate slots are allowed. |
| N21 | Bind lifetime's type role to `@destroy`. | L6: wrong participant kind. |
| N22 | Delete one role binding. | L6: incomplete binding, including optional/many roles. |
| N23 | Replace `abi(native,"c")` with `abi(missing,"c")`. | L2/A2: unresolved ABI alias. |
| N24 | Change a path's environment list to a nonexistent name. | L3/A2: unresolved configuration. |
| N25 | Delete write_count's only access path. | A2: declaration availability has no callable path. |
| N26 | Replace source getter compatibility with `compatibility(artifact,"compiler-1")` without a resolution artifact manifest. | A4: compiler name is not resolved build identity. |
| N27 | Add `fixture::invented(true)`. | L1/A1: unknown normative vocabulary. |
| N28 | Import two documents with the same package/version and different valid digests. | L2: conflicting identity in resolution closure. |
| N29 | Supply the same profile identifier/version under two aliases with different digests. | L2: conflicting provider identity. |
| N30 | Change a fixture call to `execution(async)` without adding a provider that defines it. | C3/F1: unsupported required semantics; not an unknown fact. |
| N31 | Add a reference leaf inside a record result without its `give` clause. | C1/C5: aggregate shape does not satisfy recursive ownership. |
| N32 | Produce an `out` pointer-to-pointer using `give($out.*,borrow(call))`. | C1: writable pointee borrows must also survive delivery. |
| N33 | Reuse an outcome name within one callable. | L2: outcome identity collision. |

N11 deliberately distinguishes document validity from truth about implementation.
It is not a mechanically decidable publication rule, and a future suite must not
mislabel it as a parser failure. A changed contract may be syntactically and
internally valid while being false of the API. Likewise, N14 with dynamic lengths
creates runtime obligations; it is statically rejected only when contradictory
constants make it unsatisfiable.

## Runtime contract tests to implement later

Synthetic native implementations should exercise both permitted and violating
traces. At minimum: retain a view past owner destruction; invoke callbacks before
an `after_return` boundary; begin or continue one after quiescent destruction;
perform independent overlap forbidden by serial concurrency; perform permitted
nested re-entry; fail an output operation without initializing its out buffer;
read a zero-length NUL string whose capacity is one; and access a positive-capacity
output buffer. The last two require accessible storage even when length is zero.

Each test needs a known implementation and observation mechanism; this document
does not claim those tests exist or that a static checker proves native safety.

## Pressure cases outside the synthetic profile

These cases are mandatory design probes before full adoption. Refusal under draft
0.1's supplied fixture profile is the expected result, not a partial valid package.

| Mechanism | Required future extension or complete contract |
|---|---|
| Swift generic family and concrete instantiation | Full type parameters, constraints, substitution, source compiler resolution and separate instantiation identity. `is_generic` alone fails. |
| Swift async/throws/value receiver | Suspension/delivery, cancellation, thrown type/ABI, receiver mutation/consumption and actor isolation. |
| Objective-C optional requirement | Receiver capability test and guarded invocation, independently of platform availability. |
| Error-out with success/failure validity | Actual native signature, exhaustive discriminator, per-outcome pointee validity/ownership; nullability alone fails. Core can express simple partitions once a real provider exists. |
| CF/OS opaque handle | Authoritative acquire/release protocol, independently of ObjC naming or reference counting. |
| Rust/Zig native ABI | Build artifact or source recipe plus representation provider; compiler pin alone fails. |
| CLR/WinRT/COM projections | Runtime/dispatch contract and explicit mapping; success HRESULT information loss creates a distinct declaration. |
| Wayland object version | Negotiated per-object capability, request/event lifecycle and wire provider; installed library version alone fails. |
| Variadic/inline/macro callable | Complete argument schema or source invocation, including absent versus erased macro distinction. |
| Callback destroy notifier or acknowledged cancellation | Named events and quiescence ordering; cancellation return must not be presumed to finish callbacks. |
| Mutable borrow invalidation | Every earlier invalidating operation and owner association; omission of known invalidators is false authority. |
| Open enums, unsigned cases, packed records and unions | Exact value domains and supported representation schema; signed i64 storage cannot truncate a wider unsigned value. |
| Rich pattern laws | Typed participants and operand-bearing ownership/lifetime/error/buffer laws; prose/tokens alone fail. |

## Two views of one contract

For `example::buffers` version `1`, `view`, a documentation renderer can produce:

> Returns a read-only view of sixteen bytes. The caller keeps `store` alive during
> the call and while using the returned view. The view becomes invalid when the
> store is destroyed. The call transfers no ownership, stores no reference to the
> store, and permits nested re-entry but requires independent uses of the same
> store to be serialized.

A machine/LLM view of the same facts could use this **illustrative projection**,
not a normative JSON serialization:

```json
{
  "identity": ["example::buffers", "1", "view"],
  "input": {"store": {"transfer": "borrow", "retention": "none", "validFor": "call"}},
  "result": {"type": "ptr<u8>", "length": 16, "capacity": 16, "units": "elements",
    "transfer": "borrow", "owner": "store", "earlierInvalidators": []},
  "executor": "any", "concurrency": "serial", "reentrancy": "allowed",
  "outcomes": [{"completion": "returned", "condition": "any", "meaning": "success"}],
  "contractReference": ["example::buffers", "1", "view"]
}
```

This excerpt is intentionally accompanied by its reference to the complete
contract. A complete machine model must also expose availability, source/access
paths and their provider pins, effects and all other normative clauses. It must
not present an excerpt as a self-contained authoritative package. A target may
wrap this borrow in a scoped abstraction, but must label that wrapper as its own
restriction and preserve the original contract in its API view.

## Parser, validator and round-trip obligations

Future implementations must separately report: lexical/syntax failure; identity
and closure failure; type/contract failure; unsupported provider; unresolved
representation; and consumer target infeasibility. There is one authoritative
publication standard, not a weaker documentation-only validity profile.

The parser must retain source spans, all declarations, profile payloads, docs and
navigation. An authoring round trip must retain comments and presentation either
in a concrete syntax tree or alongside the semantic model. Semantic parse/print/
parse equality follows A5 and need not preserve whitespace. A canonical serializer
must specify ordering and escaping before claiming deterministic byte identity;
this draft defines semantic equality, not a canonical byte format.

Validators must resolve the entire pinned closure, check every required fact,
scope and conflict, verify outcome partitions and ownership/lifetime references,
and validate all access paths for all declared environments. A provider unsupported
by one consumer must not be silently discarded. Diagnostics should identify the
declaration, rule, related slot/path and minimal missing or conflicting information.

Source-origin data may help explain a diagnostic but cannot determine authority.
Manual and third-party packages undergo the same checks as generated packages.

## Verification record

This draft has received bounded independent reviews of identity/syntax/provider
rules and lifetime/callback/buffer rules. Findings were reconciled in the rule
text and regression mutations. The baseline inventory was independently checked
against all seven source files and their main-workspace differences.

On 23 September 2026, `python3 /private/tmp/api-interface-draft-check.py` ran a
disposable generic EBNF recognizer against the published grammar: all three
examples were accepted, and each example with its package closing delimiter
removed was rejected. All 70 expanded grammar productions resolved. The script
also checked 41 local targets across nine Markdown files, balanced fences,
table column counts and trailing whitespace,
and found every one of 243 public field-name occurrences from the seven baseline
files in the inventory. That last check is lexical; the source audit supplies the
field-to-rule reasoning. The scratch script is not a shipped parser or test suite.

Both reviewers subsequently confirmed that their six syntax/identity/provider
findings and four lifetime/buffer/callback findings were closed. These were bounded
repair checks, not a proof of whole-language consistency. The checks do not
execute the semantic rejection mutations or validate provider implementations.

No production parser, semantic validator, native fixture implementation
or binding generator is present; no executable semantic conformance pass is
claimed. The future pressure cases are an adoption checklist, not proof that
every future language is already expressible.
