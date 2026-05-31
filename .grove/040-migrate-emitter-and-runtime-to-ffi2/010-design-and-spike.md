# 010-design-and-spike

**Kind:** planning

## Goal
Resolve the load-bearing design for the racket target's move to "native library
*is* the binding" (ADR-0010) + hermetic isolation (ADR-0011), backed by a code
spike, then **grow/insert the node's execution leaves** (020–050 are a seeded
backbone — reshape them as the spike resolves; insert a dispatch-into-native
leaf). Output: a design spec under `docs/specs/` + any hard-to-reverse choices
captured as ADR(s).

## Three things to resolve (each needs an answer before execution leaves firm up)

1. **Per-concern disposition.** For each runtime file
   (`generation/targets/racket/runtime/*.rkt`) and each emitter surface, classify:
   *stays Racket* (thin, idiomatic) / *moves into the racket native lib* /
   *already in Swift → delete the pure-Racket fallback*. The 020 research doc's
   §5 table is the starting point; this leaf makes it concrete and exhaustive.
2. **Dispatch-relocation mechanism (the crux).** Today the emitter writes
   `tell`/typed-`objc_msgSend` per-class in Racket; ffi2 has *no* ObjC layer
   (020). How does a Racket class-method wrapper invoke a **generic native
   dispatcher** across the thin ffi2 seam? Spike the realistic options —
   NSInvocation, libffi, a table of typed entry points, or a marshalled
   arg-list + type-tags protocol — and **measure** (dispatch is the hot path).
3. **Embedding direction.** *Outbound:* Racket calls Swift via ffi2 C-ABI; Swift
   stays Racket-agnostic on opaque pointers (today's `aw_*` pattern). *Inbound:*
   Swift links the **Racket CS C embedding API** and manipulates Racket values /
   closures / GC directly — most relevant for callbacks & delegates, and it must
   confront 020's finding that `_cprocedure` callbacks **SIGILL from a non-main
   OS thread on Racket CS** and `#:async-apply` deadlocks under
   `nsapplication-run`. Decide per direction-of-call; likely an **ADR**.

## Context
- Decisions already made (node BRIEF): pursue ADR-0010 fully; hermetic isolation
  (ADR-0011); dissolve `APIAnywareCommon` now (all three targets self-contained,
  must stay green).
- Existing native layer to mine: `swift/Sources/APIAnywareCommon/` (MessageSend,
  StringConversion, StructMarshal, ClassLookup, MemoryManagement, AutoreleasePool,
  ObservationBridge) + `APIAnywareRacket/` (BlockBridge, DelegateBridge,
  GCPrevention, RacketFFI). Dissolution rehomes the Common pieces into each lib.
- 020 research: `docs/research/2026-05-31-racket-9.2-ffi2-migration.md`.

## Done when
- A design spec (`docs/specs/<date>-racket-native-binding-design.md`) states the
  per-concern disposition, the chosen dispatch mechanism (with spike evidence /
  numbers), and the embedding direction.
- ADR(s) raised for the hard-to-reverse mechanism/embedding choices.
- The node's execution leaves (020–050) are reshaped and a dispatch-into-native
  leaf inserted, sequenced by dependency (`grove-llm leaf-insert`/`leaf-add`).

## Notes
- This is a *spike* — throwaway code to get numbers/feasibility, not the real
  migration. Keep it out of the shipped runtime; capture findings in the spec.
- Bias toward the maximal-idiom + native-performance directive (node BRIEF): a
  fat native core behind a thin static ffi2 seam.
