# The target idiom catalogue & the `pattern_dispatch` seam (REFACTOR §21)

Each target carries an **idiom catalogue** — the per-target answer to:

> When the platform API docs say *X*, how does that appear in this target?

It is authored as `targets/<t>/idioms/catalogue.apiw` (KDL 2.0), validated against
[`schemas/spec-format/idioms.kdl-schema`](../../../schemas/spec-format/idioms.kdl-schema),
and parsed by the shared `apianyware-target-model` crate (`idioms/` submodule). The
catalogue is the authored knowledge layer over an already-built binding — it does **not**
re-port it. Per-target by design: each target authors *its own* idioms (the maximize-idiom
rule), because the same source concept looks different in each target's runtime.

## Two axes

The catalogue is keyed by a **§21 idiom category** — a *source-concept* axis (a shared,
25-token controlled vocabulary in `target-model`'s `vocab.rs`, kept in lockstep with
REFACTOR §21). A minority of categories also carry an **emit projection** keyed by a ws3
**pattern-kind** — a finer, *projection* axis. The two are orthogonal: one category may
project several kinds (e.g. `bracketed-use` projects both `bracket` and `paired-state`).

```kdl
idiom-catalogue "sbcl" {
    idiom "bracketed-use" {
        construct "with-macro expanding to unwind-protect"   // the §21 answer (open prose)
        projects "bracket"      { emit "scoped-resource"; name "with-bracket" }
        projects "paired-state" { emit "scoped-guard";    name "with-paired-state" }
    }
    idiom "string-encoding" {                                // documentation-only — no projection
        construct "NSString ↔ CL string conversion is exact"
    }
}
```

- `construct` — open prose: how the concept appears in *this* target (the human-facing §21
  answer). Required on every idiom.
- `projects "<kind>"` — for the categories with an emit projection, maps a ws3
  pattern-kind to the closed `EmitConstruct` taxonomy (`scoped-resource` / `builder-dsl` /
  `scoped-observer` / `iteration-adapter` / `result-wrapper` / `smart-constructor` /
  `scoped-guard`) and the generated identifier the construct uses.

## The data-driven dispatch seam

The catalogue is the **data** the shared `emit/pattern_dispatch::classify_pattern` reads
(it used to be a hardcoded Rust match with scheme-flavoured names baked in). The classifier:

1. keys on a pattern-instance's `kind`,
2. looks up the catalogue's kind → projection index (`IdiomCatalogue::projection_for`),
3. renders the authored `EmitConstruct` + name into the emitter's `IdiomaticConstruct`
   rendering interface — or **passes through** if no idiom projects the kind (structural
   relationships and class-level idioms like `delegate` / `target-action` are emitted as
   part of class generation, not as separate constructs).

`emit` depends on `target-model`, never the reverse: the `EmitConstruct` *taxonomy* is
authored target-model data; the `IdiomaticConstruct` *rendering* interface is the emitter's.

### Golden-neutral now; applying projection is deferred

Relocating the mapping from Rust into authored `.apiw` is **golden-neutral**:
`classify_pattern` has zero callers and every emitter is pattern-blind today, so no
generated output moves. *Applying* projection — wiring emitters to consume pattern-instances
and emit `with-bracket` / `make-foo` wrappers — **moves goldens in all four targets and
needs a per-target VM-verify**, and would compete with each target's already-shipped
hand-tuned idiom. That is a clearly-scoped, golden-INTENTIONAL follow-on (a late ws6 child
or a future grove), not this layer's work. The eight emit-relevant kinds currently project
uniform `with-*` / `make-*` / `-sequence` names across the scheme family (they share the
convention); the model permits a future non-Lisp target to author its own.

## The per-target catalogues

| Target | Catalogue | Docs |
|---|---|---|
| racket | [`targets/racket/idioms/catalogue.apiw`](../../racket/idioms/catalogue.apiw) | [`racket/idioms/docs/`](../../racket/idioms/docs/idiom-map.md) |
| chez   | [`targets/chez/idioms/catalogue.apiw`](../../chez/idioms/catalogue.apiw)     | [`chez/idioms/docs/`](../../chez/idioms/docs/idiom-map.md) |
| gerbil | [`targets/gerbil/idioms/catalogue.apiw`](../../gerbil/idioms/catalogue.apiw) | [`gerbil/idioms/docs/`](../../gerbil/idioms/docs/idiom-map.md) |
| sbcl   | [`targets/sbcl/idioms/catalogue.apiw`](../../sbcl/idioms/catalogue.apiw)     | [`sbcl/idioms/docs/`](../../sbcl/idioms/docs/idiom-map.md) |

The `.apiw` catalogue is the source of truth; the per-target `idioms/docs/idiom-map.md` is
the maintained human rendering. A generator that produces the rendering from the catalogue
is a deferred thin-CLI concern (ws6 D5).
