# 010-design-and-spike

**Kind:** planning

## Goal
Grill the chez-specific design for adopting ADR-0010 (native lib is the binding)
+ ADR-0011 (hermetic isolation), backed by a code spike, then grow the node's
execution leaves lazily. Output: a chez design spec under `docs/specs/` + any
hard-to-reverse choices as ADR(s).

## Things to resolve (chez analogue of the racket grove's design leaf)
1. **Per-concern disposition.** For each chez runtime file and emitter surface:
   *stays Chez* (thin, idiomatic) / *moves into `APIAnywareChez`* / *already in
   Swift → drop the Chez fallback*. Start from what `APIAnywareChez` +
   `APIAnywareCommon` already cover (BlockBridge, DelegateBridge, GCPrevention,
   plus Common's MessageSend/StringConversion/StructMarshal/ClassLookup/Memory).
2. **Dispatch-relocation mechanism.** How a chez wrapper invokes a generic native
   dispatcher across the `foreign-procedure` seam (the chez analogue of the
   racket dispatch question). Spike + measure.
3. **Embedding direction.** Chez calls Swift *outbound* via `foreign-procedure`
   C-ABI, vs Swift embeds Chez's C API *inbound* (for callbacks/delegates).
   Decide per direction; mind chez's threading/lifetime model (ADR-0007).
4. **Self-containment (de-Common).** What of `APIAnywareCommon` chez absorbs into
   `APIAnywareChez`, and the `Package.swift` change to drop the dependency.

## Context
- Decisions are project-wide (ADR-0010/0011); this leaf settles the *chez*
  mechanics. Idiom posture: ADR-0005 (idiomatic Chez, not portable R6RS).
- **Reuse the racket grove's reasoning, not its code.** When
  `update-racket-to-9.2-and-use-ffi2`'s `040/010-design-and-spike` lands its
  design spec, read it — the dispatch-mechanism and embedding-direction analysis
  transfers conceptually (targets are isolated, so no shared code).

## Done when
- A chez design spec exists (`docs/specs/<date>-chez-native-binding-design.md`)
  with per-concern disposition, dispatch mechanism (spike evidence), embedding
  direction, and the de-Common plan.
- ADR(s) raised for hard-to-reverse choices.
- Execution leaves grown/sequenced (de-Common, native-lib build-up, emitter
  thin-shims, delete-Chez-fallbacks, regenerate; VM-verify per standing rule).

## Notes
- Spike = throwaway; keep out of shipped runtime.
- No ffi2/9.2 here — chez uses `foreign-procedure` (target-specific).
