# Convention heuristics are datalog rules, not imperative classifiers

**Relates to:** ADR-0046 (the spec format; supplies the `convention:<rule>` provenance source).

## Context

Semantic annotations come from four producers ranked by §28's precedence ladder
(`manual > extraction > accepted-LLM > platform convention rule > unknown` since the
`declared-fact-precedence-k87` re-rank — see §4). The
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
4. **A declared fact produces at the `Extraction` tier, and Extraction outranks the LLM.** The
   convention tier exists to derive what the headers do **not** declare. Where a fact *is* declared —
   `@property (weak)`, `(copy)`, `(strong)` — it is **extracted**, carried on the IR declaration, and
   fed to a rule whose **sole premises are compiler declarations**; such a rule produces at the
   **`Extraction` tier** (`source: extraction`, its rule name still riding in `SlotProvenance::rules` —
   the `source` states the *evidence class*, the rule stamp keeps the derivation trace). Membership is
   mechanical: *could the rule fire on a corpus with all names stripped?* `weak-property-attribute`
   (premises: declared ownership attribute + declared object type) and `block-copy-property-setter`
   (premises: declared `(copy)` + declared block-typed param) pass; the name sniffs
   (`weak-delegate-param`, the block-invocation substring tables) stay Convention — the **fallback for
   the undeclared case**, not a substitute for reading the declaration. §28's ladder is accordingly
   **`manual > extraction > accepted-LLM > convention > unknown`** (settled
   `declared-fact-precedence-k87`, 2026-07-13): evidence classes strongest-first — a human, the
   compiler, accepted prose, a naming pattern. The LLM proposes facts where the compiler is silent; it
   never decides truth against a declaration (REFACTOR §28's own posture).

## Consequences

- **Legibility + extensibility:** a convention reads as `weak_param(m,p) <-- selector_has_prefix(m,"set"),
  selector_contains(m,"Delegate"), last_param(m,p);` instead of buried imperative branches — the
  human-understandable, extensible form the decision sought. (That very rule is now the *fallback* arm
  per §4: where the property declares `weak`, the declared-attribute rule fires instead, at the
  Extraction tier.)
- **Provenance for free:** the datalog engine knows which rule fired; the disagreement/precedence
  audit (ADR-0046, generalizing today's `validate` + `AnnotationDisagreement`) gets per-rule
  attribution at no extra cost.
- **One inference style:** conventions and resolution unify under `ascent`, removing the
  imperative/declarative split in the analysis pipeline.
- **§4 bounds the tier's ambition, and shrinks it.** Every fact the header declares is one the
  convention tier must *stop* guessing — so §4 is a standing instruction to check, for each facet,
  whether libclang already has the answer. It found one immediately: the extractor was calling
  `get_objc_attributes()` and keeping only `.copy`, discarding `weak`/`strong`/`assign`/
  `unsafe_retained`, while `weak_param` sniffed for the substring `delegate`. §4 initially ordered
  rules only *within* the convention tier; once k82's measurement showed the LLM tier superseding
  declared facts, `declared-fact-precedence-k87` promoted the declaration-premised rules out of it
  onto the re-ranked Extraction tier (see the measurement bullet below).
- **The ownership facet is the worked example of §4** *(realised `property-ownership-ir-k82`,
  2026-07-11)*. `ir::Property` now carries the declared qualifier as an `Option<OwnershipKind>` — the
  four ObjC semantics over their six spellings (`strong`≡`retain`, `assign`≡`unsafe_unretained`) — and
  the facet resolves each parameter through a **producer cascade**: the declared attribute (the
  Extraction tier, since k87), then the delegate/observer name sniff, then the block-copy default
  (Convention). Two things the rule set needed that the naming tier never had:
  - **A type gate.** The declared-attribute rule fires only on an **object-typed** property. ObjC lets
    `@property (assign) NSInteger tag;` say `assign` about a scalar, where "ownership" is a category
    error (15 such declarations across AppKit + Foundation, including three `Class` properties —
    counted in the pass log, not dropped silently).
  - **The retain axis is one decision.** "Does the receiver retain this argument?" is answered *no* by
    both `weak` and `assign`, so every reader must test the axis, not one spelling of it. `enrich` was
    testing `== Weak`; on a corpus that now distinguishes them, that would have silently dropped the 17
    pre-ARC delegate slots (`NSXMLParser`, `NSStream`, `NSFileManager`, …) whose headers spell it
    `assign`.
- **What reading the declaration actually bought** (AppKit + Foundation, measured): 907 slots now carry
  a declared-attribute fact (`copy` 586, `strong` 252, `weak` 44, `unsafe_unretained` 25) against 29
  surviving name-sniffed ones. It **corrected** 18 slots the sniff had wrong — 17 where `assign` was
  called `weak`, and one that matters: **`NSURLSessionTask.setDelegate:` is declared `strong`**, and the
  pipeline had been telling every target the framework does *not* retain its delegate, purely because
  the parameter is called `delegate`. It also **found** slots the sniff could never see: every
  `setTarget:` is `@property (weak) id target`, so the whole target/action family had *no* ownership
  fact at all and ADR-0059 §6's associate-or-skip was taking its default arm blind.
- **§28 vs the declaration — measured, and the ladder re-ranked** *(settled
  `declared-fact-precedence-k87`, 2026-07-13)*. The question §4 left open (may a prose-derived LLM
  fact override a **declared** one?) was answered on data. Across AppKit + Foundation (2026-07-11)
  the two producers contradicted on **17** ownership slots — every one `llm=weak` over a declared
  `assign`, both **non-retaining**, so no consumer-visible value ever depended on the inversion; and
  the one slot where the declaration genuinely flips the answer (`NSURLSessionTask`, `strong`)
  carried no LLM annotation. The inversion was nonetheless closed rather than left latent, for three
  reasons. It is **structural, not ownership-specific**: `block-copy-property-setter` is
  declaration-premised and the LLM's primary yield *is* block facts, so the same shape sat open in
  the facet where the LLM is most active. The **provenance blemish was live**: on 470 LLM-annotated
  ownership slots `resolved.kdl` credited the prose for a fact the compiler states outright,
  poisoning every downstream reading of LLM value-add (the `analysis.md` yield tables, ADR-0050's
  staleness/regeneration workflow). And the re-rank is **golden-neutral, measured**: the 17 value
  flips are intra-axis and every consumer reads the retain axis. A future **cross-axis**
  contradiction (a prose `weak` over a declared `strong`) now auto-resolves in the compiler's favour
  and is recorded as a `superseded-by` disagreement by the audit — no bespoke tripwire. The
  declaration-covered LLM ownership facts in the overlays are pruned after a prose-only measurement
  (`llm-ownership-prune`; ADR-0050's charter — the overlay is for facts only Apple's prose knows).
- **Cost:** converting 1,236 lines of classifiers to rules is a substantial migration —
  sequenced after the format cutover, with goldens-as-truth
  guarding equivalence (the rule set must reproduce the current classifications before extending).
- **Why this clears the ADR bar:** hard-to-reverse (rewrites the heuristics layer), surprising
  (datalog where one expects classifier functions), a real trade-off (compile-time legibility +
  provenance vs runtime extensibility, and a non-trivial migration vs leaving working code alone).
