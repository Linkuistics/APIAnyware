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

## Decisions (running log)

**D1 — Dispatch posture is measure-first (no prior lean).** Unlike racket
(which pre-decided "generate typed native dispatch entries" because its FFI
crossing was interpreted/macro-heavy), chez's `foreign-procedure` already
compiles to a *direct* typed `objc_msgSend` call. We do **not** pre-judge
whether to relocate dispatch into a generated native entry. The spike's
measured numbers alone decide between (a) keep direct `foreign-procedure`
objc_msgSend at call sites vs (b) route through a generated native typed entry.
Grilling settles only the spike's shape and its decision rule, not the outcome.
*(racket analogue: 2026-05-31-racket-native-binding-design.md §2, which we reuse
as reasoning only — chez's baseline is materially different.)*

**D2 — Spike is two-part, self-contained on chez's own runtime.**
*Part A (hop isolation):* direct typed `foreign-procedure objc_msgSend` vs a
thin native `aw_chez_send_<sig>` shim (forwards to objc_msgSend, opaque args) vs
libffi-generic (escape-hatch reference for un-typable sigs), across four ABI
shapes: scalar return, `id→id`, struct return (NSRect), 2×float.
*Part B (marshalling payoff):* string-in/out method, struct-return method, and
a collection method (`list→NSArray`) — *(chez-side coerce + direct call)* vs
*(native entry doing the coercion)*.
*Decision rule:* keep dispatch direct unless Part A shows the native shim is not
slower on the simple shapes (scalar/id/float); move marshalling native
per-method wherever Part B shows a material win (racket's Depth-0/1/2 spectrum,
§3). Numbers → `docs/research/<date>-chez-dispatch-spike/FINDINGS.md`. Spike is
throwaway; this spec + ADR(s) are the durable record.

**D3 — Embedding direction: stay outbound; spike probes the foreign-thread
hazard.** `foreign-procedure` out; `foreign-callable` trampolines for callback
creation behind the native bridges (`DelegateBridge`/`BlockBridge`); foreign-
thread safety owned natively. **Reject** Swift-embeds-Chez-C-API inbound (larger
surface, same foreign-thread activation problem one level down, no evidence
needed) — chez analogue of racket ADR-0014. The spike adds a **foreign-thread
callback probe**: fire a chez `foreign-callable` from a GCD worker thread to
determine empirically whether chez needs `Sactivate_thread`, a mandatory
main-thread bounce, or both (chez analogue of the ffi2-callback-SIGILL finding
that resolved racket's biggest open question). Result feeds the lifetime/
threading model already in ADR-0007.

**D4 — De-Common plan; chez turns out the lights.** Racket already de-shared on
`main` (its Package.swift target has no `APIAnywareCommon` dep), so chez is the
last *real* consumer. Plan: absorb the 4 Common files chez uses — `ClassLookup`,
`MemoryManagement`, `AutoreleasePool`, `StringConversion` (~82 lines) — into
`APIAnywareChez`, folded into one `ChezRuntime.swift`. Do **not** carry
`MessageSend`/`StructMarshal`/`ObservationBridge` (chez uses none; they die with
the directory). **Rename `aw_common_*` → `aw_chez_*`** (8 symbols; update
`ffi.sls` + `runtime/README.md` only) for honest hermetic naming. Drop the
`APIAnywareCommon` dependency in `Package.swift`. Then **delete
`APIAnywareCommon` + the inert Gerbil stub + its Package.swift target** (this
grove turns out the lights — confirm Gerbil is truly inert at execution time).
*Sequencing caveat:* this worktree predates racket's de-share, so the de-Common
execution leaf must **merge `main` first** to edit against the real
Package.swift.

**D5 — Spike verdict (the central, surprising result).** Spike built + measured
(`docs/research/2026-06-02-chez-dispatch-spike/`, `FINDINGS.md`). Chez's typed
`foreign-procedure` is **already at the native dispatch floor** (~6 ns simple,
~10.5 ns struct); the native shim is equal on simple shapes and ~3× slower on
struct returns; native marshalling saves ≤12% on strings and *loses* on
collections. **→ keep dispatch + marshalling in Scheme** (ADR-0015) — relocating
either would add a hop and violate ADR-0010's perf goal. The inverse of racket,
whose interpreted FFI made native relocation a 2–8× win. Foreign-thread probe:
a `foreign-callable` from any unregistered OS thread **crashes** (pthread + real
GCD worker), but `Sactivate_thread` (threaded Chez) makes both safe **→ outbound,
trampolines `Sactivate_thread`-wrap background callbacks** (ADR-0016); main-thread
bounce is a UI rule, not a safety rule. Net: chez is already largely
ADR-0010-compliant; the real work is ADR-0011 de-Common + the ADR-0016 deepening.

**D6 — ADRs raised + execution leaves grown.** ADR-0015 (direct dispatch +
Scheme marshalling) and ADR-0016 (outbound callbacks + thread activation) — both
0015/0016 to avoid clashing with main's racket ADRs 0013/0014. Design spec:
`docs/specs/2026-06-02-chez-native-binding-design.md`. Execution leaves grown as
root-level siblings: **020** de-Common + turn out the lights, **030**
background-thread callback safety (ADR-0016 wiring), **040** regenerate +
VM-verify every chez sample app. No dispatch/marshalling execution leaf (D5: the
emitter is unchanged).
