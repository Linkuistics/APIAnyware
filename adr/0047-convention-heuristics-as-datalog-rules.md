# Convention heuristics are datalog rules, not imperative classifiers

**Relates to:** ADR-0046 (the spec format; supplies the `convention:<rule>` provenance source).

## Context

Semantic annotations come from four producers ranked by §28's precedence ladder
(`manual > accepted-LLM > platform convention rule > raw extraction > unknown`). The
**"platform convention rule"** tier is today **1,236 lines of imperative Rust** in
`platforms/macos/tools/annotate/src/heuristics.rs` — 59 naming-convention classifiers
(`selector.starts_with("set") && …`) that return flat `MethodAnnotation { source: Heuristic }`
values. Two problems: the rules are **opaque** (hard to read, extend, or audit), and the
imperative path **throws away derivation lineage** — you cannot ask *which* rule produced a
fact. Meanwhile the pipeline **already runs datalog** (the `ascent` crate; the `datalog` crate
exists precisely so consumer crates define `ascent!` programs — resolution and ownership
inference are already datalog).

## Decision

1. **Re-express the convention heuristics as declarative `ascent` (datalog) rules** over the
   `extracted.kdl` fact base, in the datalog layer — the same engine as resolution. The
   imperative `heuristics.rs` is retired.
2. **Compile-time** rules (not a runtime-loaded DSL). They live in version-controlled Rust;
   changing them is a normal pipeline rebuild (the "regenerate aggressively" habit). A
   runtime-loadable rule DSL is a possible later enhancement (would need a runtime datalog
   engine — out of scope).
3. Rules are **not** a persisted artifact. Their *derived facts* land in `resolved.kdl` stamped
   `source = "convention:<rule-name>"`, so **provenance falls out of the derivation trace**
   (ADR-0046 §4) rather than needing a separate bookkeeping layer.

## Consequences

- **Legibility + extensibility:** a convention reads as `weak_param(m,p) <-- selector_has_prefix(m,"set"),
  selector_contains(m,"Delegate"), last_param(m,p);` instead of buried imperative branches — the
  human-understandable, extensible form the decision sought.
- **Provenance for free:** the datalog engine knows which rule fired; the disagreement/precedence
  audit (ADR-0046, generalizing today's `validate` + `AnnotationDisagreement`) gets per-rule
  attribution at no extra cost.
- **One inference style:** conventions and resolution unify under `ascent`, removing the
  imperative/declarative split in the analysis pipeline.
- **Cost:** converting 1,236 lines of classifiers to rules is a substantial migration — its own
  child work leaf, sequenced after (or parallel to) the format cutover, with goldens-as-truth
  guarding equivalence (the rule set must reproduce the current classifications before extending).
- **Why this clears the ADR bar:** hard-to-reverse (rewrites the heuristics layer), surprising
  (datalog where one expects classifier functions), a real trade-off (compile-time legibility +
  provenance vs runtime extensibility, and a non-trivial migration vs leaving working code alone).
