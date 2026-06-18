# 010-plan

**Kind:** planning

## Goal

Walk the design tree for the Swift-native method frontier and grow this grove's
task tree. Resolve the open questions the seed named (one at a time, grilling),
landing ADRs where a decision is durable, then decompose into build/verify leaves.

## Context

See the root `BRIEF.md` (charter) and the design-of-record spec
`docs/specs/2026-06-15-racket-trampoline.md`. The free-function/constant
trampoline mechanism is shipped + VM-verified for racket/chez/gerbil; this grove
generalises it from free functions to **methods** (receiver handle + by-name call).

## Open questions (from the seed — to grill)

1. **Recovery:** how are Swift-native methods surfaced as trampolinable decls
   (receiver type + labels + effects) from the digester into the IR? Today methods
   flow only to `native_dispatch` / `msgSend`.
2. **Correctness:** the latent-broken `msgSend` emission for `objc_exposed == false`
   methods (charter #4) — route to trampolines instead. Scope of the fix.
3. **@MainActor / actor isolation:** does an actor-isolated async method need its
   `operation` closure to hop **onto** its actor, not just deliver off-main?
4. **Sequencing:** racket-pioneer then chez/gerbil inherit (parent-grove pattern),
   or per-target? Static-FFI seam implications for chez (ADR-0017 no-Swift-dylib),
   gerbil's trampoline-only dylib (ADR-0029).
5. **Smoke candidate:** pick a real recovered async method (Foundation/URLSession,
   or a CoreML/CreateML async method).

## Done when

The open questions are resolved (decisions logged inline below; durable ones in
ADRs), `CONTEXT.md` carries any new terms, and the tree is grown with the next
leaves (build/verify), so `grove-llm pick` advances to real work.

## Decisions (running log)

### D1 — Receiver model: both populations in scope (user, 2026-06-18)

Swift-native methods (`objc_exposed == false`) split by the **exposure of the
receiver type**: **(A)** method on an `objc_exposed` receiver — the target already
holds the receiver as a live `id` (e.g. `URLSession.data(for:)`), no producer
needed; **(B)** method on a Swift-native (`s:`) receiver — the receiver is only
obtainable via an `AwValueBox`/`Unmanaged` handle, which some *other* trampoline
must produce (the "no in-residual producer" wall the parent grove hit for
value-struct params, spec §5c fork 4).

**Decision: both (A) and (B) are in scope from the start** (user chose "B" over
the recommended "bind A first, defer B with a count"). Maximal coverage, per the
`feedback-maximize-target-idiom-and-perf` charter ("defer nothing").

**Consequence (carried forward, not re-litigated):** (B) forces the
**handle-producer side** into scope — constructor/initializer/factory/property-getter
trampolines that *return* Swift-native receiver handles — because a method on a
pure-Swift type is useless without a way to obtain a receiver of that type. The
handle must round-trip as a receiver **in**, not only **out**. This is materially
larger than the (A)-only cut and reshapes the decomposition.

### D2 — Handle-producer model: initializers + unified bidirectional rep (user, 2026-06-18)

The producer side adds essentially **one** new decl kind to recover, the
**initializer**, and otherwise reuses already-shipped machinery:

- **(a) Initializers are the sole root producer.** An `init` trampoline is a
  `@_cdecl` that calls `Type(labels:)` and returns a boxed handle
  (`awRacketBox(value)` for a value type, `Unmanaged.passRetained(instance)` for a
  class). Standalone factory / `static`-property producers are **not** separately
  designed — they fall out of the existing return-boxing path (a method/property
  returning a Swift-native type boxes its return via the §3 taxonomy; handles chain).
- **(b) Unified bidirectional handle rep.** The receiver is the **same**
  `AwValueBox`/`Unmanaged` rep the return side produces, used in reverse: the
  `@_cdecl`'s first param is the opaque handle, the body unboxes to the concrete
  type (`awRacketUnbox(recv, as: Foo.self)` / `Unmanaged<Foo>.fromOpaque(recv)
  .takeUnretainedValue()`) and calls the method. No distinct "receiver token" type,
  no new lifetime model.
- **Soundness gate = the §5c oracle, unchanged:** unboxing requires spelling the
  concrete type, so the receiver type must be nameable & in-module ("name ∈ owning
  framework's struct/class set", threaded per-framework); cross-module / unnameable
  receivers stay soundly deferred-with-a-count.

**Recovery gap flagged:** `map_method` hardcodes `init_method: false`
(`declaration_mapping.rs:457`) — initializer recovery is a concrete build-leaf task.

### D3 — Value-type receiver mutation: write-back (user, 2026-06-18)

A `mutating` method on a value-type (`struct`) receiver mutates a *local copy*
inside the `@_cdecl` (because `AwValueBox.value: Any` is a copy), silently losing
the change — a correctness trap, not a coverage gap. (Class receivers are fine —
`Unmanaged` preserves reference identity.)

**Decision: write-back.** Make `AwValueBox.value` a `var`; a mutating-value-receiver
trampoline does `var v = unbox(recv); v.method(...); box.value = v`, so the
target's existing handle reflects the mutation (one stable identity). Consistent
with the "defer nothing" cut (D1). Box mutability is a thread-safety note only —
handles are single-threaded under the racket main-thread model.

**Weight is measure-first:** the §5c residual value-structs were opaque
framework objects (`MLTensor`, `SecCode`) with reference-ish semantics and few
public mutating methods, so the bucket may be small; the first build leaf sizes it.
**`consuming self` methods are deferred-with-count regardless** (they destroy the
receiver — the handle would dangle after the call); default/`borrowing self` rides
the unbox-copy path.

### D4 — Latent-broken msgSend fix: suppress + count the deferred bucket (user, 2026-06-18)

`emit_class.rs` routes **every** method through `objc_msgSend` with no `objc_exposed`
branch (`emit_class.rs:1196+`), so a Swift-native method msgSends a synthesized
selector the runtime never registered → `doesNotRecognizeSelector:` crash when
called (the charter-#4 latent break). The fix adds the branch, three dispositions:
`objc_exposed==true` → msgSend (unchanged); `false` & trampolinable → trampoline
entry; `false` & deferred → **suppress + count** (emit nothing, record a reason,
surface the count). Chosen over a raising stub (b) for **consistency** with the
shipped free-function deferral discipline (`Deferred`/`defer_counts`) and the
existing `is_supported_method` skip (partial method coverage is already the norm).
The non-negotiable core either way: **the broken `msgSend` must go** — suppression
is the floor of the charter-#4 fix. Per-target (each emitter's method emission).

### D5 — Async-method actor isolation: lean on `await`, capture the pointer (user, 2026-06-18)

`await receiver.method(args)` already hops onto the method's actor (custom actor
or `@MainActor`) by Swift language semantics, so the trampoline needs **no
actor-isolation machinery and no isolation-recovery facts** — the compiler routes
it. The one friction is `Sendable`: a non-Sendable class receiver can't be captured
in the `@Sendable` `operation` closure, but the **opaque handle pointer is Sendable**
(raw pointers are). So the generated async closure **captures the pointer, unboxes
inside**, `await`s the method (hops), and marshals the result to its Sendable C rep
inside the closure (the §3a result discipline). Closure shape:
`{ () async -> CRep in let recv = unbox(ptr); return marshal(await recv.method(args)) }`.
The **build leaf verifies Swift 6 Sendable-checking** compiles clean over the real
frameworks. **`@MainActor`-isolated *sync* methods** are a deferred measure-first
edge (safe only if the racket call originates on main — ADR-0014 usually ensures it;
assume-main or defer-with-count if off-main calls are reachable), not designed now.

### D6 — Sequencing: recovery factored out, then racket-pioneer → chez → gerbil (user, 2026-06-18)

Method **recovery** is genuinely shared (`collect → analyse`, the only cross-target
shared layer per ADR-0011) and **all-targets-blocking**, and is materially larger
than the parent grove's folded-in `swift_fn`-on-`Function` touch (spec §0a) — so it
gets its **own node** rather than being mis-scoped as "racket". Four-node spine:

1. **`020-method-recovery`** (shared pipeline, prerequisite): add `swift_fn` to
   `ir::Method`; apply `node_is_async` in `map_method`; recover **initializers**
   (`init_method` hardcoded `false` today); thread receiver-type exposure for the
   soundness gate.
2. **`030-racket`** (pioneer): method-trampoline codegen + runtime (receiver unbox,
   initializer producers, mutating write-back D3, async-via-`await` D5), smoke, full
   rerun + VM-verify. Pioneers the per-target design → new ADR ("0027-for-methods").
3. **`040-chez`** (inherit): port (own thin ADR), rerun + VM-verify. No new FFI seam
   (receiver = more pointer/scalar args over ADR-0028's shared-source-call path).
4. **`050-gerbil`** (inherit): port via the ADR-0029 linked-dylib path (own thin ADR),
   rerun + VM-verify.

Each target node decomposes lazily (build leaf → rerun+verify leaf) only when picked.

### D7 — Smoke: named async headline + measure-first population-B exemplar (user, 2026-06-18)

Two exemplars, mirroring §6a's two:
- **Headline async (population A): `URLSession.data(from:)` over a `file://`/bundled
  resource.** `URLSession` is ObjC-exposed but the `async` method is
  `objc_exposed == false` (async/await has no ObjC rep) — textbook A. Returns a
  **tuple** `(Data, URLResponse)`, so it also exercises tuple-return boxing (§3) atop
  receiver-as-`id` + async-via-`await` + main-thread completion. Deterministic (local
  source, no network). Proves the grove's headline done-bar. Build leaf confirms the
  exact symbol + that URLSession accepts the local source; falls back to another
  recovered async method if not (§6a "pick from the real residual").
- **Population-B novel-machinery exemplar: measure-first in `030`** — an initializer
  trampoline producing a Swift-native handle + a method called back through the unified
  rep (+ a `mutating` method if available, to exercise D3 write-back). Picked from the
  actual recovered residual once `020` lands (which Swift-native types have a clean init
  + dependency-light method is a measurement, not a guess).

## Notes
