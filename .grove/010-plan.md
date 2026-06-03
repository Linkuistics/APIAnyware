# 010-plan

**Kind:** planning

## Goal

Walk the Gerbil-target design tree via a grilling session and grow the grove's
decomposition. Resolve the genuinely-open, Gerbil-specific decisions (toolchain
pinning, FFI mechanism, dispatch strategy, object/idiom shape, lifetime model,
error model, distribution, sample-app/bundler approach), capturing terms in
`CONTEXT.md` inline and durable trade-offs as ADRs. Output: child leaves
(work/spike/research) under the root, ordered for execution.

## Context

Third target after `racket` + `chez`. The 9-step `docs/adding-a-language-target.md`
pattern is the spine; ADR-0010/0011 (native-lib-is-the-binding, hermetic
isolation) and ADR-0005 (maximal idiom) are inherited. Gerbil specifics that
make this NOT a copy of chez: compile-to-C via Gambit, native object/module
system, Gambit GC + `still`/wills, `gxc -exe` standalone build, `:std/foreign`
FFI conveniences.

## Done when

- Foundational Gerbil decisions settled (one-at-a-time grilling, recommended
  answers with evidence), recorded in a `## Decisions (running log)` below.
- `CONTEXT.md` updated inline with resolved Gerbil terms.
- ADRs raised for the durable / hard-to-reverse / surprising trade-offs.
- The tree is grown: ordered child leaves exist under the root (decompose this
  node if the build is large).
- A design spec drafted at `docs/specs/<date>-gerbil-target-design.md` if the
  increment is a genuine agreement point (per the guide's Step 1).

## Decisions (running log)

**Q1 — dispatch / native-binding strategy → DEFERRED to a FFI spike.** Did not
pre-commit to the chez (ADR-0015 direct dispatch) vs racket (ADR-0013 generated
native dispatch) fork. Rationale: ADR-0015 says the compiled-FFI-favours-direct
conclusion "may apply to future compiled-FFI targets" but is "target-specific" —
reasoning-by-analogy across compilers (Chez native compiler vs Gerbil→Gambit→C)
is exactly what it warns against. So the first work is a **FFI hello-world +
dispatch-cost spike**: prove Gerbil's `begin-ffi`/`define-c-lambda` reaches
`objc_msgSend` cleanly, then measure the Gambit crossing cost vs a native shim,
and let *those numbers* settle the dispatch model. Mirrors chez's own
`docs/research/2026-06-02-chez-dispatch-spike/`. → first leaf is a spike.

**Q2 — object/idiom model → DEFERRED to spike findings.** Did not pre-commit to
single-handle-struct + procedure-namespaces (the proven racket/chez shape) vs a
native `defclass`/`defmethod` hierarchy vs hybrid. Open precisely because Gerbil,
unlike Chez/Racket, *has* a first-class object system and ADR-0005 commands max
idiom — but generic-function dispatch cost is unknown on compiled Gerbil. → the
spike must also characterize `defmethod`/generic-function dispatch cost so this
fork is settled by numbers.

**Q2-followup — user steer: lean toward Gerbil's NATIVE OO.** The user wants the
spike to benchmark Gerbil's **dynamic dispatch** specifically, to *validate* a
provisional decision to use Gerbil's native object system (`defclass`/`defmethod`/
generic functions) rather than reusing the racket/chez single-handle-struct +
procedure-namespace API model. So Q2 is no longer a neutral defer: the working
hypothesis is native OO (ADR-0005 max-idiom), and the spike's job is to confirm
the dynamic-dispatch cost is acceptable (or to refute, if it is prohibitive). This
makes a Gerbil target genuinely *differ in API shape* from its Scheme siblings —
the first target to do so — which is exactly what hermetic isolation (ADR-0011)
and max-idiom (ADR-0005) were meant to license.

**Q2-resolution-direction — LAYER the OO model over the non-OO model (user
proposal; LLM concurs).** Leading Q2 design (to be validated by the spike and
finalized in 030): build the proven procedural core as the foundation — single
handle-struct + per-class procedure namespaces, the racket/chez shape, which the
spike should confirm compiles to a direct `objc_msgSend` floor — and layer a
native-OO interface (`defmethod`/generic functions) ON TOP as pure Scheme sugar
with **zero extra native cost** (it sits entirely above the FFI seam). Why this
beats either pure option: (a) it is ADR-0010's own thin-seam-over-fat-core shape;
(b) the dynamic-dispatch tax becomes **opt-in** — hot paths call procedures
directly, ergonomic sites use the veneer — so the benchmark is a *price tag*, not
a go/no-go gate; (c) it honours ADR-0005 max-idiom (a Gerbil programmer gets
`defmethod`) without the *foundation* mirroring the ObjC class graph.
- **Open sub-question for 030 (decide with spike data, not now):** does the OO
  veneer dispatch on generic functions specialized on the *single* handle struct
  (method-name resolution only; no class hierarchy to maintain) — LLM's lean — or
  a `defclass` hierarchy mirroring the ObjC class graph (richer; reintroduces
  graph-mirroring as a layer)?
- **Spike impact:** the dispatch benchmark must measure the **layering tax**
  specifically — direct procedure call (base) vs `defmethod`-over-procedure
  (veneer) — to put a number on the opt-in cost.

**Steer observed:** two consecutive "defer to spike" answers ⇒ stop grilling
design specifics now; commission a characterization spike, then re-grill the
deferred forks WITH evidence (a follow-up planning leaf), then build. Classic
grove lazy decomposition; matches the incremental-discovery philosophy.

**Q3 — spike scope → WIDE characterization spike.** One spike harness settles
all deferred forks + de-risks distribution: (1) FFI reachability
(`begin-ffi`/`define-c-lambda` → `objc_msgSend`/`objc_getClass`/
`sel_registerName`); (2) direct typed-msgSend vs native-shim dispatch cost,
simple shape + CGRect struct-return (settles Q1); (3) generic-function/`defmethod`
dispatch cost on compiled Gerbil (settles Q2); (4) CGRect struct-by-value return
over the FFI (`c-struct`); (5) `gxc -static -exe … -ld-options -framework AppKit`
yields a launchable self-contained binary (de-risks distribution). Marginal cost
of extra benchmarks in a stood-up harness is tiny; the forks interlock.

## Tree grown this session

- `020-ffi-dispatch-spike.md` — the wide characterization spike (work/spike leaf).
- `030-replan-from-spike.md` — follow-up **planning** leaf: re-grill the deferred
  Q1 (dispatch) and Q2 (object model) forks with spike evidence, write the design
  spec (`docs/specs/<date>-gerbil-target-design.md`), raise the durable ADRs, and
  decompose the build subtree (emitter, runtime, dylib, CLI, tests, the 7 apps +
  VM-verify, bundler, knowledge, README) — lazily, per the 9-step guide.

Build leaves are intentionally NOT created yet: Q1/Q2 shape the emitter and are
deferred to the spike, so decomposing the build now would be premature
(anti-pattern: the runaway tree).

## Notes
