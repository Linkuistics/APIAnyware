# The racket trampoline structure: call-by-name re-export, complete marshalling to the C-ABI limit

Decides the **per-target** mechanism that ADR-0026 left to the first implementor:
how `libAPIAnywareRacket` vends C-ABI **trampolines** for the Swift-native
residual (`objc_exposed == false`), and how the racket emitter binds them.
Refines **ADR-0025** (the complete-API binding model and trampoline elision),
governed by **ADR-0011** (the trampoline layer is per-target — this ADR is
racket-only; chez/gerbil get their own in 060/070) and **ADR-0010** (the native
library *is* the binding). Extends the generated-Swift mechanism of **ADR-0013**
(typed native dispatch) to a second problem.

This is the design decision of `040-racket-trampoline`. It is consumed by 040's
build leaves and re-verified end-to-end in 050.

## Context

030 made the boundary an explicit IR fact: every retained declaration carries
`objc_exposed` (ADR-0026), and top-level `s:` funcs/constants are now *retained*
(no longer dropped) so they reach the emitter. But the racket emitter does not
yet *act* on the fact — `emit_functions.rs` / `emit_constants.rs` still emit
`get-ffi-obj '<sym> _fw-lib` (a bind against the **framework dylib**) for
everything. For a Swift-native symbol that is a dangling bind: the `s:` symbol is
not a C export of the framework; it is reachable only across the Swift ABI.

What the IR gives us for a residual decl (verified against
`map_top_level_function` / `map_top_level_constant` in
`collection/crates/extract-swift/src/declaration_mapping.rs`): the **bare Swift
name** + **argument labels** (parsed from `printed_name`), digester-normalized
**param/return TypeRefs**, the owning **module** (recoverable from the enclosing
`Framework`, not carried on the node), and the mangled **`s:` USR** (in
`doc_refs`). Name yes, module-by-context, mangled-symbol available — that
asymmetry is what makes "how does the trampoline call the API" a real fork.

The user directive for this grove (memory `feedback-maximize-target-idiom-and-perf`,
restated when grilling 040): **maximize native idiom and completeness over
minimizing work** — "a complete implementation, defer nothing". This ADR records
the boundary at which "complete" meets what a flat C ABI can express.

## Decision

### 1. Generated `@_cdecl` trampolines, **called by name**

`apianyware-generate` emits a new, gitignored
`swift/Sources/APIAnywareRacket/Generated/Trampolines.swift` in a **global pass**
(one file across all frameworks, like the dispatch table —
`run_racket_native_dispatch`), then `swift build` compiles it into the dylib. The
build order `generate → swift build` already holds (the `.rkt` bindings and
`Generated/Dispatch.swift` require it).

Each residual decl becomes one `@_cdecl` Swift function that **`import`s the
owning framework module and calls the API by its reconstructed name + argument
labels**. swiftc type-checks the call:

```swift
import Foundation

@_cdecl("aw_racket_swift_Foundation_foo")
func aw_racket_swift_Foundation_foo(_ x: Int) -> Int {
  return foo(x)   // type-checked by the Swift compiler
}
```

**Rejected — bind the mangled `s:` symbol** via `@_silgen_name`/`dlsym` and a
hand-cast `@convention(c)` shape (the `objc_msgSend` dispatch trick). It would
avoid needing a valid Swift source expression, but it forces us to hand-replicate
the Swift calling convention per signature (self register, error register,
indirect returns, ownership) with no compiler check — brittle and unverifiable.
Call-by-name lets the Swift compiler own ABI correctness; we only own the C
boundary of the `@_cdecl`.

### 2. Complete marshalling **to the limit of the C ABI** — defer nothing

Every Swift type that *can* cross a flat C ABI does; nothing is silently skipped.

- **Value types via Foundation bridging, reusing the existing runtime.** `String`
  → `NSString`, `Array` → `NSArray`, `Dictionary` → `NSDictionary`, `Set` →
  `NSSet`, NSNumber-able scalars — the trampoline returns the bridged `id`, which
  the **racket runtime already converts** (`aw_racket_nsstring_to_string`,
  `aw_racket_nsarray_get_all`, `aw_racket_nsdictionary_get_all`, …). This
  maximizes reuse and keeps the new surface small.
  *Rejected — a fresh length-prefixed C serialization for every value type:*
  duplicates machinery the runtime already has, on both sides.
- **Non-bridgeable Swift structs & payload enums → opaque heap-boxed handles**
  with generated field-accessor + `free` trampolines (a payload enum also gets a
  tag accessor).
- **Class instances / existentials / opaque `some P` returns → opaque retained
  handles** (`Unmanaged`), routed through Swift-side dynamic dispatch.
- **`async` → a continuation/callback trampoline.** **`throws` → a trailing
  error out-param** (the shape the dispatch table already uses for `error_out`).
- **Generic free functions are genuinely unbindable** — no concrete symbol exists
  without monomorphization and `@_cdecl` cannot be generic. They are **recorded
  with a reason and the count surfaced**, never silently dropped, and revisited
  if a real API needs one.
  *Rejected — monomorphize at statically-observed instantiations:* combinatorial,
  covers only the type-arguments the IR happens to see, uncertain payoff.

### 3. The emitter binds trampolines against `libAPIAnywareRacket`

For a retained decl, the racket emitter derives the boundary from `objc_exposed`
(ADR-0026 §3) and the type shape:

- `objc_exposed == true` → **bind directly**, unchanged (`get-ffi-obj '<sym>
  _fw-lib`, `objc_msgSend`, literal/dlsym).
- `objc_exposed == false`, trampolinable → **bind the trampoline**:
  `get-ffi-obj 'aw_racket_swift_… _aw-lib` (where `_aw-lib` loads
  `libAPIAnywareRacket`) plus the racket-side coercion for the marshalled rep.
  Pointer-valued Swift constants route through a constant trampoline returning the
  global's address.
- `objc_exposed == false`, an unbindable generic free function → **emit nothing**,
  record it.

## Consequences

- **A new gitignored generated artifact**, `Generated/Trampolines.swift`, written
  by `generate` before `swift build` (global pass, mirroring the dispatch table).
- **The racket native lib gains a marshalling-runtime layer** (box/handle/async/
  throws infra + the value bridges that aren't already there). Per ADR-0011 this
  is racket-local and shares no substrate with chez/gerbil.
- **Emitters act on `objc_exposed` for the first time** — 030 only *carried* it;
  `emit_functions.rs` / `emit_constants.rs` now branch on it, and the broken
  `get-ffi-obj … _fw-lib` bind for Swift-native symbols is replaced.
- **A new diagnostic reason for unbindable generic free functions**, with a
  surfaced count (the "defer nothing, but say what truly can't be bound" clause).
- **Racket-only.** chez (060) and gerbil (070) decide their own trampoline
  structure; the per-target-vs-shared-source question (ADR-0011) stays deferred,
  revisited only if duplication bites.
- The implementation-level contract — artifact path, naming + overload
  disambiguation, the full Swift-type → C-ABI → racket-coercion taxonomy, the
  native-runtime additions, build wiring, the emitter decision tree, and the
  smoke/done-bar — is in `targets/racket/docs/design/2026-06-15-racket-trampoline.md`.

See `CONTEXT.md` (*Trampoline*, *Opaque handle*, *Unbindable residual*) for the
glossary, ADR-0026 for the `objc_exposed` fact this consumes, ADR-0013 for the
generated-Swift mechanism it extends, and the design spec for the how.
