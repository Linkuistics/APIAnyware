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
