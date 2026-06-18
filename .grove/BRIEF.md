# add-swift-native-method-coverage — brief

## Goal

Bind the **Swift-native method frontier** that the free-function/constant
trampoline (ADR-0027/0028/0029, parent grove `add-swift-native-api-coverage`)
does not reach. Measured 2026-06-16 over 284 enriched frameworks: **~3,181
Swift-native methods** (`objc_exposed == false` on classes/structs/protocols,
incl. **445 async**) are unbound today — they route through `native_dispatch`
(ObjC `msgSend`), which has **no entry** for a Swift-native method. Per the
founding charter's point #4 they are therefore **latently broken**, not merely
missing (a correctness hole, not just a coverage gap).

The core new machinery: **receiver-handle method trampolines** — a `@_cdecl`
taking an opaque receiver handle and calling `receiver.method(labels:)` by name,
generalising ADR-0027's free-function call-by-name — plus Swift-native **method
recovery** in collection/IR (today methods flow only to `native_dispatch`), then
propagation to chez/gerbil. `async` (the runtime-ready `AsyncBridge.swift` slice)
is one slice of this frontier, not a separable task.

## Done when

- Swift-native methods (`objc_exposed == false`) route to receiver-handle
  trampolines, **not** the broken `msgSend` path (closes charter #4 for methods).
- At least one **real recovered async method** resolves and runs end-to-end
  (a free function could not exercise async — none exist; spec §5b).
- The mechanism is propagated to all current targets per the parent grove's
  pattern (racket pioneer → chez → gerbil), each VM-verified.
- "Defer nothing, but be honest": any un-trampolinable method slice is recorded
  with a reason and surfaced as a count (the ADR-0027 §5 discipline).

This grove **gates `add-sbcl-clos-target`** (the sbcl Swift library becomes this
model's trampoline layer).

## Decomposition

Grown by the `010-plan` grilling (decisions D1–D7 in that leaf's running log):

- **`020-method-recovery`** — shared `collect → analyse` change (once, all-targets-
  blocking): `swift_fn` on `ir::Method`, async detection in `map_method`, initializer
  recovery, receiver-type exposure threading; measure the residual.
- **`030-racket`** — pioneer the receiver-handle method trampoline end-to-end
  (codegen, runtime, charter-#4 routing fix, smoke, rerun + VM-verify); writes the
  structural ADR generalising ADR-0027.
- **`040-chez`** — inherit the design (thin ADR over ADR-0028 path), rerun + VM-verify.
- **`050-gerbil`** — inherit (thin ADR over ADR-0029 dylib path), rerun + VM-verify;
  last target ⇒ grove ready to finish.

Receiver model (D1): both **population A** (objc-exposed receiver, no producer) and
**population B** (Swift-native receiver via a handle producer) are in scope.

## Residual measurement (leaf 020, 2026-06-18)

Measured over the 284-framework **collected** IR after the 020 recovery landed
(`swift_fn` on `ir::Method`; `methods` on `ir::Struct`; `self_kind` threaded).
A method is Swift-native iff it carries `swift_fn` (⇔ `objc_exposed == false`);
the owning type is population B iff its `objc_exposed == false`. Reproduce:
`SDKROOT=macosx ./target/debug/apianyware-macos-collect` then walk
`collection/ir/collected/*.json` (script in the 020 leaf's commit message / the
session transcript). 117 of 284 frameworks carry Swift-native methods.

- **Total Swift-native methods: 13,084** — by owner kind: **class 3,181**
  (this is exactly the charter's headline number — it had counted classes only),
  **struct 8,011** (previously *dropped entirely* by `map_struct` — the real
  recovery hole this leaf closed), **protocol 1,892**.
- **Initializers: 5,681** (3,639 on structs) — the population-B root producers (D2).
- **Async: 451** (charter est. 445) · **throwing: 2,202**.
- **Unbindable generic: 7,459** (57%) — every protocol requirement (`Self` is a
  generic parameter) plus the heavily-generic SwiftUI value types. `@_cdecl`
  cannot be generic ⇒ **deferred-with-count** (ADR-0027 §5 discipline).
- **Consuming `self`: 6** (`__Consuming`) — handle would dangle ⇒ **deferred-with-count** (D3).
- **⇒ Bindable estimate (non-generic, non-consuming): 5,620** — receiver split
  **A (objc owner) 672 : B (swift owner) 4,948** (B dominates, validating D1/D2).
  Among bindable: 1,963 inits · 282 async · 1,233 throwing · **259 mutating
  value-receivers** (D3 write-back) · by owner kind class 1,206 / struct 4,414 /
  protocol 0 (all protocol reqs are generic-deferred).

**Feeds 030 (D7):** the headline async exemplar (`URLSession.data(from:)`, pop A)
is among the 282 bindable-async; the pop-B novel-machinery exemplar (init producer
+ value-receiver method, ideally `mutating`) is pickable from the 4,414 bindable
struct methods / 259 mutating ones. Protocol-requirement trampolining is out of
this measurement's bindable cut (generic `Self`); 030/per-target may revisit via
conformance flattening (cf. gerbil grove leaf 120), recorded here as deferred.

**Receiver-type exposure threading (D1/D2) is structural, not a new field:**
methods stay nested under their owning `Class`/`Struct`/`Protocol`, so the owner's
`name` + `objc_exposed` (the A/B split and the §5c nameability gate) are reachable
at 030's classification time by iterating types-then-methods. No IR change needed
beyond surfacing struct methods.

## Pointers

- Design of record: `docs/specs/2026-06-15-racket-trampoline.md` (§3a runtime,
  §5b async, §5c value-struct params, §6 done-bar pattern).
- ADR-0025 (complete-API model + trampoline elision), ADR-0026 (`objc_exposed`
  boundary), ADR-0027/0028/0029 (per-target free-function trampoline structure).
- Already built + reused, do **not** redo: async detection (`mangled_is_async`),
  `AsyncBridge.swift` runtime (continuation core + blocking `aw-async-await`),
  `OpaqueHandle.swift` box/unbox, `ThrowsBridge.swift`, content-addressed
  entry+binding names.
- Parent grove's `done/` history carries the full free-function build.

## Notes

Seeded 2026-06-16 from `add-swift-native-api-coverage/040-racket-trampoline/
050-async-methods` after the scope grilling (user-confirmed "own grove, defer").
