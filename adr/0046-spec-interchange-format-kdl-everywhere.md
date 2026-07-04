# The spec interchange format is KDL everywhere — a per-family extracted/annotations/resolved triad

**Status:** accepted. KDL 2.0 is the format for the whole spec stack — the authored `.apiw` overlay
(format-preserving `kdl` crate) and the machine IR (`extracted.kdl` / `resolved.kdl`, a
non-preserving codec — §5).

**Supersedes (in part):** `REFACTOR.md` §29 (which specified a human DSL **plus** a
*YAML* canonical interchange) and §14's `extracted.yaml` / `resolved.yaml` file literals.
The split-format intent of §29 stands; the choice of *YAML* for the machine side does not.

**Raised by:** `structural-refactoring` grove, workstream 2 (`spec-format-k16`).

## Context

REFACTOR §29 calls for "a human-editable DSL and a canonical interchange format" — the DSL
"pleasant for humans", the YAML "stable and machine-consumable" — feeding
`extracted.{yaml} → annotations.apiw → resolved.{yaml} → generator`. Today the pipeline
emits **JSON** at phase-shaped, gitignored paths (`collection/ir/`, `analysis/ir/`); workstream 2
replaces that interchange. Two facts, surfaced during grilling, reframed the format choice:

1. **`serde_yaml` is archived/deprecated** (Mar 2024). Rust's canonical YAML-serde is dead;
   the survivors are contested forks (`serde_yml`, `serde_yaml_ng`, `serde_norway`). "YAML is
   the safe machine-serde choice" no longer holds.
2. **KDL 2.0 shipped** with an *actively-maintained official* Rust crate (`kdl`, document-model,
   format-preserving, `miette` diagnostics), serde adapters, a **KDL Schema Language**, and
   broad cross-language + editor support.

The load-bearing risk in adopting KDL was authoring reliability: the `.apiw` overlay is
**LLM-authored at scale**, and YAML's one advantage over JSON is authoring ergonomics. We
measured it (see *Consequences → Evidence*) rather than guessing.

## Decision

1. **KDL 2.0 is the single format for the whole spec stack** — authored *and* machine. There
   is no YAML interchange. JSON is retired from the interchange.
2. **Per-API-family triad** (REFACTOR §14 shape, KDL filenames), under
   `platforms/macos/api/<Framework>/`:
   - `extracted.kdl` — mechanical extraction facts (the datalog fact base). Machine-written.
   - `annotations.apiw` — the **one** authored semantic overlay (manual + accepted-LLM);
     today's committed `_llm-annotations/*.llm.json` fold into it (converted once).
   - `resolved.kdl` — the deterministic merged graph; the generator input (≈ today's `enriched`).
3. **The KDL Schema is the authoritative, language-neutral format contract** for all three
   artifacts, so non-Rust tools can validate/consume them; the Rust serde types are *one
   conforming implementation*, not the source of truth.
4. **Provenance/confidence are carried in the format** (the data model that *can express* them):
   every `resolved.kdl` fact carries `source ∈ {extraction, convention:<rule>, llm, manual}`;
   authored facts carry `confidence` as a coarse **enum `high|medium|low`** (not a float) plus a
   `provenance` (doc URL / rationale); precedence (`manual > accepted-LLM > convention >
   extraction > unknown`, §28) is applied deterministically in resolve, the **winner stamped and
   losers retained** as a `superseded-by` record; a fact with no producer is explicit `unknown`.
   The *workflow* over this (caching/regeneration/review-accept/diff) is workstream 5's.
5. **The machine IR uses a non-preserving KDL codec.** The format-preserving `kdl` document model
   parses the multi-MB IR ~80–100× slower than `serde_json` — right for authored `.apiw` (where
   diagnostics + layout matter), too heavy for the "regenerate aggressively" machine loop. A machine
   artifact is written once and read mechanically, so it needs **no** format preservation: the
   machine side (`extracted.kdl` / `resolved.kdl`) uses a hand-written **non-preserving
   JSON-in-KDL (JiK) codec** over `serde_json::Value` — measured at ~1.24–1.29× `serde_json` raw and
   ~2.4–3.2× on the full typed path, well within budget (spike:
   [`semantic/docs/research/2026-07-04-kdl-machine-codec-spike/`](../semantic/docs/research/2026-07-04-kdl-machine-codec-spike/README.md)).
   The codec is homed in `semantic/tools/spec-format` (with the KDL-Schema engine). The IR stays
   serde-`Value`-expressible, so the encoding remains a reversible back-end swap.

## Consequences

- **Two formats → one.** Mental model and tooling simplify to KDL + the `kdl` crate; the
  *machine* artifacts become human-readable, directly serving goldens-as-truth review.
- **Filenames change** from §14's `.yaml`: `extracted.kdl` / `annotations.apiw` / `resolved.kdl`.
- **Toolchain note:** `kdl` 6.7.1 needs rustc 1.95; this repo is on 1.93.1 → pin `kdl = "=6.3.4"`
  or bump the toolchain (decided at the parser leaf).
- **Evidence (cited):** the in-session LLM-authoring eval —
  [`semantic/docs/research/2026-06-24-kdl-authoring-eval/`](../semantic/docs/research/2026-06-24-kdl-authoring-eval/README.md).
  6 fresh subagents (2× KDL/YAML/JSON) authored the same 20 real-shape annotations; **6/6
  well-formed, fidelity clean**; escaping burden **KDL 0** (40 raw-strings) · YAML 34 · JSON 96.
  KDL raw strings (`#"…"#`) let models write quote/dash-heavy prose verbatim — *better* than YAML
  for the realistic content. Caveat: small sample (directional, not proof).
- **Why this clears the ADR bar:** hard-to-reverse for the authored layer (humans/LLMs write it),
  surprising (contradicts §29's YAML), a real trade-off (against a — now deprecated — YAML and the
  more-ubiquitous JSON). The machine layer's reversibility is the explicit JSON-retreat gate.
- The convention-heuristics-as-datalog decision (which supplies the `convention:<rule>` provenance)
  is **ADR-0047**.

## Update — per-fact provenance carriage deferred to ws5 (2026-06-24, leaf `flip-retire-k26`)

§4 above is the decided *carriage model*; this update records its **implementation status** after
the convention flip. The convention facets (`apianyware-conventions`, ADR-0047) *compute* a
per-fact/per-index `convention:<rule>` stamp, but the flip keeps it **off-disk**: `annotate`
assembles convention annotations **byte-identical to the legacy heuristic output** (`source =
Heuristic` at method level; no per-fact `source`, no `superseded-by`). The full §4 rollout —
per-fact `source` stamps on `ParamOwnership`/`BlockParamAnnotation` + per-method threading/error,
the `.apiw` schema/writer + machine serde extension, emit consumers, and the disagreement/precedence
audit (winner stamped + losers `superseded-by`) — is **workstream 5's** (it owns the
provenance/precedence *mechanism*; §4 line 54 already scopes the workflow to ws5, and no consumer of
per-fact provenance exists until ws5 builds one). This honours the seam **ws2 defines the carriage,
ws5 builds the mechanism** without speculatively reshaping the schema. Steer (user, k26): `annotate`
runs once per SDK update, so the carriage is kept minimal. Equivalence proven by goldens-as-truth
(Foundation `resolved.json` byte-identical pre/post-flip; emit goldens green on all four targets).
