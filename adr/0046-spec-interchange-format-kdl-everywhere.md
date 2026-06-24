# The spec interchange format is KDL everywhere — a per-family extracted/annotations/resolved triad

**Status:** accepted

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
5. **The machine-side KDL is spike-gated.** The official `kdl` crate is document-model, not
   serde-derive; large-IR serialization (perf + serde-adapter maturity) is **unproven** and is
   proven on one real framework in the first implementation leaf **before** the full cutover.
   **JSON is the documented retreat** for `extracted`/`resolved` if the spike fails — the IR is
   serde-based, so the machine back-end is a swap; the hard-to-reverse choice is the *authored*
   KDL, which the evidence backs.

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
