# 050-async-methods

**Kind:** planning (frontier — scope to be grilled)

## Goal

Bring **async** Swift-native APIs into the racket binding. The async runtime
substrate is already built and idle (`AsyncBridge.swift`: `awRacketAsyncDispatch`,
`AwAsyncOutcome`, main-thread delivery, 040/010); the chosen racket surface is a
**continuation core + a blocking `aw-async-await` wrapper** (user, 040/040/020).
What is missing is the *recovery* of async decls and the codegen that drives the
runtime — and crucially, the async surface lives on **methods/actors**, not the
top-level free functions the current trampoline machinery handles.

## Context

- **Why this exists (040/040/020 kick-back, spec §5b):** the `deferred_async`
  *free-function* bucket measured **empty** — 0 async free functions across all
  284 frameworks (confirmed three ways: enriched IR, resolved IR over 12,046
  funcs, mangled-name `Ya` scan). `async` is a method/actor effect, structurally
  outside the top-level-`s:`-`Func` residual the trampoline recovers. So the real
  async surface is methods, and reaching it is a **larger frontier than the
  current free-function/constant trampoline** (ADR-0027): it needs async-method
  *recovery* in collection/IR, not just codegen.
- **Already landed (do not redo):** async **detection** is fixed
  (`extract-swift/declaration_mapping.rs::node_is_async` / `mangled_is_async` —
  the digester emits no `async` field, so detection is from the mangled-name
  marker). So an async decl, once recovered, will be correctly flagged
  `swift_fn.is_async`. The runtime is ready (spec §3a). The blocker is upstream:
  async methods are not currently recovered as trampolinable decls at all.

## Done when

*(to be set by the grilling — this is a planning leaf)*

## Notes — open questions for the grilling

- **Recovery:** how are Swift-native async *methods* surfaced from the digester
  into the IR, and against what call mechanism do they trampoline? Methods today
  go through `native_dispatch` (ObjC-only); a Swift-native async method has no
  ObjC entry. Does this reuse the call-by-name `@_cdecl` mechanism (ADR-0027)
  bound to an *instance handle* receiver, or something new?
- **`@MainActor` / actor isolation:** many async APIs are actor-isolated. The
  `MainActor.run` delivery hop interacts with this — does an actor-isolated async
  method need its `operation` closure to hop *onto* its actor, not just deliver
  *off* it? (spec §3a flags the off-main marshalling constraint.)
- **Scope / sequencing:** racket-pioneer like the rest of 040, then chez (060) /
  gerbil (070) inherit? Or is this big enough to be its own root-level grove? Does
  it gate grove-finish, or is it consciously deferred to a future grove /
  `add-sbcl-clos-target`? Decide in the grilling (grove is for incremental
  discovery — growing scope here is expected, not scope-creep).
- **Smoke candidate:** pick a real recovered async method to prove end-to-end
  (the free-function leaf could not — none exist). Likely a Foundation/URLSession
  or CreateML async method.
- **Nice-to-have, non-gating:** an upstream feature request to `swift-api-digester`
  for a structured `async` field would make `mangled_is_async` belt-and-suspenders
  — but the mangling stays the authoritative floor regardless (spec §5b).
