# conventions-datalog-k21 — brief

**Kind:** node brief (was a work leaf; decomposed 2026-06-24 — the biggest single ws2 conversion)

## Goal

Retire the imperative **`platforms/macos/tools/annotate/src/heuristics.rs`** (1,238 lines) and
re-express the convention heuristics as declarative **`ascent` datalog rules** over the
`extracted.json` / linked fact base (k17 retreat — machine IR is JSON), in the datalog layer
(ADR-0047; PRD "Producers → files"). Derived facts land in `resolved.json` stamped
`source="convention:<rule>"`; datalog's derivation trace supplies the provenance.

## Settled design (do NOT re-grill)

- **ADR-0047** — convention heuristics as `ascent` rules; compile-time; derived facts stamped
  `source="convention:<rule>"`; runtime-loadable rules deferred.
- **PRD** `prd/2026-06-24-spec-format-data-model.md` "Producers → files" + ADR-0046 §4 provenance.
- **Same engine** as the existing `resolve` / `enrich` ascent programs — each is its own crate
  with a fact loader (`Framework` → base facts) + readback (derived facts → IR).

## Decomposition rationale (D4 — buildable + goldens-green at every step)

The conversion is large (new crate: ascent program + loader + readback; a provenance-carriage
data-model change; **four classifier facets** — parameter-ownership, block-invocation, threading,
error-pattern; retire 1,238 lines + ~40 unit tests; full-pipeline + emit-goldens regen). It does
not fit one focused session, so it is a node.

**Strategy — build then flip (keeps every intermediate commit trivially goldens-green):** build
the `ConventionProgram` **facet-by-facet, the pipeline left UNCHANGED** (heuristics.rs still drives
`annotate`), each facet gated by a **characterization test** asserting the new rule output equals
the legacy `heuristics.rs` output over real IR. Only the **final** child flips `annotate` from
heuristics.rs to the `ConventionProgram` atomically, retires heuristics.rs, finalizes the
`convention:<rule>` provenance stamping, and proves full-pipeline + emit-goldens equivalence.

## Planned children (grown lazily — only k22 exists now; later added on retire)

1. **`scaffold-ownership-k22`** *(live)* — new crate + ascent `ConventionProgram` + fact loader +
   readback; port the **parameter-ownership** facet (weak delegate/dataSource/observer; block →
   copy); characterization test vs `heuristics.rs`. Pipeline untouched. Establishes the pattern.
2. **block-invocation facet** — sync/async/stored selector patterns + `@property (copy)` block-setter
   → stored. (The gnarliest facet — most string patterns.)
3. **threading facet** — class `@MainActor`/`NS_SWIFT_UI_ACTOR` propagation, UIKit class list,
   UI selector list.
4. **error-pattern facet** — trailing `NSError**` out-param.
5. **flip + retire** — wire `annotate` to the `ConventionProgram`, retire `heuristics.rs`,
   finalize `source="convention:<rule>"` stamping + the per-rule disagreement/precedence audit
   (ADR-0046 §4), full-pipeline regen + emit-goldens green, `cargo fmt --all` + `style:`.

## Deferred decisions (settle in the leaves that need them, escalate if cross-workstream)

- **Provenance granularity** (`convention:<rule>`): `MethodAnnotation.source` is today a single
  method-level enum, but a method aggregates facets from several rules → per-fact provenance wants
  per-fact carriage (touching `ParamOwnership`/`BlockParamAnnotation` + the `.apiw` schema/writer +
  machine serde + emit consumers). k22 introduces a minimal carriage for the ownership facet and
  validates the *stamp shape*; the full per-fact rollout is finalized at the **flip** child. If it
  grows cross-workstream (ws5 LLM side-channel consumes provenance), escalate before the flip.
- **Crate home**: k22 chose **`platforms/macos/tools/conventions`** — the rules encode macOS
  Cocoa/ObjC naming conventions (UIKit list, `NSError`, `setDelegate:`), so they belong to the
  macOS platform, while still depending on `apianyware-datalog` + `ascent` ("in the datalog
  layer"). Mirrors the `resolve`/`enrich` ascent-consumer shape; revisit if a rule proves
  platform-neutral.

## Done when (node)

- The convention tier is `ascent` rules; `heuristics.rs` is removed (or reduced to non-rule glue).
- **Goldens prove equivalence**: the rule set reproduces the current classifications (no regression
  in annotated/resolved output, end-to-end via emit goldens).
- Each derived fact carries `source="convention:<rule>"` in `resolved.json`; the
  disagreement/precedence audit (ADR-0046 §4) attributes per rule.
- Full pipeline regenerates green; 71 suites + goldens pass; `cargo fmt --all` + `style:` if needed.

## Notes

Runtime-loadable rules remain a deferred enhancement (ADR-0047). After the last child retires, the
node likely has no live leaf → the retire-cascade asks before treating ws2 done.
