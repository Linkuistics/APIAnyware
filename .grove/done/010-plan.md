# 010-plan

**Kind:** planning

## Goal

Found the grove: record the complete-API binding model durably (ADR + CONTEXT +
README), then grill the open realization questions and **grow the tree** into the
work leaves that land the IR extension, the trampoline mechanism, and the
per-target pipeline rerun + re-verify.

## Context

Founding charter incorporated from inbox (2026-06-15), refining ADR-0010/0011.
Perimeter traced this session — see root `BRIEF.md` Notes. Key reframing: the
drop is narrow (top-level `s:` funcs/constants only); Swift *types* are already
retained but `source` is dead metadata, so the direct-vs-trampoline boundary is
currently *accidental* (every class emits `objc_msgSend` bindings regardless of
whether the ObjC runtime can reach it).

## Open realization questions (from charter, to grill)

1. Exact **direct-vs-trampoline boundary** — which constructs each target reaches
   directly vs needs a trampoline for; the pointer-constant rule.
2. **IR extensions** for Swift-native shapes; how far to model (bindable subset
   vs full Swift type system: value types, associated-type protocols, async,
   generics).
3. How the **Swift trampoline library is built per target** (hermetic
   per-impl-from-shared-source vs shared substrate — ADR-0011 fork sbcl-030 also
   flagged).
4. Per-target **re-binding + pipeline rerun + re-verification** plan.

## Done when

- Model recorded (ADR refining 0010 + 3 CONTEXT terms + README preamble).
- Open questions grilled; tree grown into ordered child leaves with briefs.

## Decisions (running log)

**D1 — Frontier posture: mechanism first, frontier grows (2026-06-15).** This
grove builds the trampoline *mechanism* and makes `source` load-bearing, binding
the **clearest residual now** — top-level `s:` functions/constants + pointer-valued
constants — proven **end-to-end on one target**. The richer Swift frontier (value
types → generics → async → associated-type protocols) extends **leaf-by-leaf** as
the grove discovers real cost; it is *not* pre-committed now. Honours grove's
incremental-discovery philosophy. ⇒ later questions: which target to pioneer on;
how the IR represents the boundary; how the trampoline library is built per target.

**D2 — Pioneer target: racket (2026-06-15).** The D1 vertical slice (IR change →
Swift trampoline → emitter → rerun → VM-verify) is proven first on **racket** —
deepest existing Swift native library (`libAPIAnywareRacket`, ADR-0013), reference
target, least friction. Grounding fact: **racket and chez ship Swift dylibs
(`APIAnywareRacket`/`APIAnywareChez`); gerbil does NOT** (ObjC-in-gsc, ADR-0017) —
so a Swift-native trampoline (only Swift can call the Swift ABI) is the
architecturally hard case for gerbil, sequenced last. All three targets remain
in-grove scope (charter "Done when" = rerun every target before sbcl resumes).

**D3 — Record the model first, leaf 020 (2026-06-15).** The user-confirmed
abstract model (complete-API + trampoline elision) is recorded **up front** in
ADR-0025 (refining ADR-0010) + README preamble, before any code —
charter's "founding recording acts" framing. Implementation-specific decisions
(IR field shape — 030; trampoline structure — 040) get their **own** later
ADRs/specs as they are designed, so the founding ADR stays at the stable
model level and need not wait on or drift with implementation.

**N1 — Gerbil Swift-lib may *help* compile time (user, 2026-06-15).** The
no-Swift-dylib fork for gerbil (070) is **not purely a cost**: moving native code
into a Swift dylib could offload work out of the `gsc` compile and **ease gerbil's
notorious build times** (cf. ADR-0023 generics 5h→8.4min; ADR-0017 precompilation
amortisation). ⇒ 070 must weigh the Swift trampoline as a *possible build-time win*,
not just a deviation from ADR-0017. Recorded into the 070 brief.

## Notes
