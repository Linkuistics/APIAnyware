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

## Decisions (running log)

### D0 — Dispatch strategy: spike-decide first (settled 2026-05-31)
**Decision.** Do not pre-commit to conservative-hybrid vs aggressive-relocation
of outbound ObjC dispatch. Build the throwaway spike *first*, measure, and let
the numbers choose. **Recommended by Claude, chosen by the user.**

**Why.** The node BRIEF and the 020 research are in tension: the BRIEF calls
dispatch "a prime candidate to relocate into the native lib"; 020 says "the
migration is narrower than the title implies." The performance case for
relocation is genuinely unknown, because relocating dispatch makes *every*
method call cross the ffi2↔`ffi/unsafe` seam — paying the `ptr_t<->cpointer`
pointer-representation tax (020 §2) on the hot path. Today's generated dispatch
(`tell`/typed `objc_msgSend` via `get-ffi-obj`) runs entirely Racket-side with no
seam crossing. So relocation could be net-negative; only measurement settles it.
This also matches the leaf's explicit "design-AND-spike" framing and avoids the
`driving.md` "pre-baked answer" anti-pattern.

**Grounding read this session (code as-is):**
- *Outbound dispatch* — `MessageSend.swift` (Common) exposes a *fixed, curated*
  table of typed `aw_common_msg_*` entry points (ptr/void/bool/uint/int/dbl +
  rect/point/size/range struct returns, 0–2 ptr args). Bulk generated dispatch
  in `emit_class.rs` is in-Racket `tell`/`objc_msgSend`. (Exact split of who
  calls which — `DispatchStrategy` in `method_filter.rs` — to confirm in spike.)
- *Inbound callbacks* — already ~80% native: `DelegateBridge.swift` (dynamic
  class + IMP trampolines void/bool/id/int/long × 0–3 args + per-instance
  dispatch table + dealloc cleanup), `BlockBridge.swift` (global-block ABI +
  copy/dispose refcount), `GCPrevention.swift` (callback pinning). Racket side
  only mints a `_cprocedure`/`function-ptr` and registers it.
- *The SIGILL artifact* — that minted `function-ptr` is what SIGILLs when ObjC
  invokes it from a foreign OS thread on Racket CS; `main-thread.rkt` sidesteps
  via `dispatch_async_f` (fn-ptr GCD variant) onto the main thread.
- *Fallbacks to delete (ADR-0010)* — every runtime file branches on
  `swift-available?` with a pure-Racket fallback (`make-delegate/racket`,
  pure-Racket block ABI, `tell …retain` vs `swift:retain`).

**Spike must answer (drives D1 dispatch-mechanism, D2 embedding-direction):**
1. Generic native dispatcher (NSInvocation / libffi / typed-entry-table /
   marshalled arg-list+type-tags) per-call cost **vs** today's in-Racket `tell`,
   *including* the ffi2↔`ffi/unsafe` bridging tax. (the crux / hot path)
2. Does `ffi2-callback`'s atomic-mode model change the foreign-thread SIGILL /
   `#:async-apply`-deadlock situation? (biggest unknown; gates embedding
   direction for callbacks/delegates)
3. Confirm ffi2 gaps flagged by 020: `ctype-sizeof` equivalent, `ptr-equal?` /
   null-check forms.

**Provisioning.** ffi2 is not installed (`raco pkg install ffi2-lib` needed —
020 §4). The spike provisions it; 030 owns making that durable.
*Update:* ffi2-lib was **already installed** by the retired leaf 030 — `(require
ffi2)` loads; no install needed (my `raco pkg install` attempt was redundant and
correctly blocked by the supply-chain guard).

### Spike completed (2026-05-31) — full results in
`docs/research/2026-05-31-racket-ffi2-spike/FINDINGS.md` (+ repro harness).

**Headline numbers.**
- *Dispatch* (send `-hash`, N=3M): in-Racket `tell` ~110 ns/call; **native typed
  via ffi2 (SEL cached) ~20 ns/call — 5.4× faster**; native NSInvocation generic
  ~660 ns/call — **6× slower**; selector-string-per-call ~86 ns. → typed native
  dispatch is fast, generic dispatch is not; SEL caching essential.
- *Callbacks* (020's biggest unknown): foreign-thread invocation **SIGILLs for
  both `_cprocedure` and ffi2** (callback never fires). ffi2 callbacks also have a
  **void-return bug** (the dominant delegate shape). → ffi2 callbacks are **not
  viable** for our callback layer; foreign-thread safety must be a **native
  trampoline bounce** (today's `main-thread.rkt` model).
- *Disposition*: `aw_common_msg_*` (MessageSend.swift) is **dead code** (no
  callers); runtime uses native only for autorelease/retain/class/string +
  block/delegate/GC, never dispatch. `ffi2-sizeof` exists (closes 020 gap). `->`
  collides between ffi2 & ffi/unsafe (rename must be on ffi/unsafe's side).

### D1 / D2 — follow-up spikes done (2026-05-31)

**D1 libffi follow-up (user-requested).** libffi is a **viable generic native
dispatcher**: ~39 ns/call CIF-cached — 2.3× faster than `tell` (~90 ns), ~17×
faster than NSInvocation (~680 ns), and *one* generic function (no per-signature
typed-entry library). Ranking: typed-native 20 < libffi 39 < tell 90 ≪
NSInvocation 680. CIF-cache saves only ~10 ns here. → a generic dispatcher is now
on the table; its appeal is **architectural** (thin Racket seam per ADR-0010),
not perf (dispatch isn't the GUI bottleneck).

**D2 void-callback follow-up (user-requested).** Root-caused: ffi2's
`build-ffi2-procedure` (`core.rkt:986`) applies `(ffi2-type-c->racket void_t)`
which is `#f` → "not a procedure: #f" for any void-returning callout-with-callback.
**Every** void-callback spelling fails (`diag4.rkt`); only non-void works. It's an
**upstream ffi2 bug**; combined with the foreign-thread SIGILL (which ffi2 does
*not* fix), ffi2 callbacks are **unusable** for our void-dominant callback layer.
Don't block on an upstream fix.

→ Both decisions now have complete evidence. Re-presenting D1/D2 as final calls.
