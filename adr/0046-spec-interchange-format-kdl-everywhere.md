# The spec interchange format is KDL everywhere — a per-family extracted/annotations/resolved triad

**Status:** accepted — **amended 2026-06-24**: the machine-side spike (§5) returned **no-go**;
the documented **JSON retreat is invoked** for `extracted`/`resolved`. Authored `annotations.apiw`
stays KDL. See *Update — spike outcome* below. The title's "everywhere" now reads as "KDL
**where humans write**".

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
     **[amended → `extracted.json`, see Update]**
   - `annotations.apiw` — the **one** authored semantic overlay (manual + accepted-LLM);
     today's committed `_llm-annotations/*.llm.json` fold into it (converted once). **[stays KDL]**
   - `resolved.kdl` — the deterministic merged graph; the generator input (≈ today's `enriched`).
     **[amended → `resolved.json`, see Update]**
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

## Update — spike outcome (2026-06-24, leaf `kdl-serde-spike-k17`)

The §5 machine-side spike ran on two real frameworks (AppKit 12.7 MB, Foundation 8.7 MB,
extracted-shape IR) via a generic, bijective `serde_json::Value ⇄ kdl::KdlDocument` bridge over
the official `kdl` crate (=6.3.4). Full method + numbers:
[`semantic/docs/research/2026-06-24-kdl-machine-serde-spike/`](../semantic/docs/research/2026-06-24-kdl-machine-serde-spike/README.md).

**Findings:**
- **Correctness ✅** — the IR round-trips JSON↔KDL **losslessly** (structural equality on both
  frameworks). The data model *is* expressible in KDL 2.0. One library footgun surfaced: the
  `kdl` crate emits the strings `null`/`true`/`false`/`nan`/`inf`/`-inf` **bare** and then its own
  parser rejects them — a round-trip-safety defect a production writer must force-quote around.
- **Performance ❌** — the official document-model crate (the only production-grade KDL-2.0 path;
  `serde_kdl` is abandoned on KDL 1.0, the `*-kdl` derive crates are 0.x non-serde) **parses
  ~80–100× slower than `serde_json`** (AppKit 1795 ms vs 23 ms; Foundation 1205 ms vs 12 ms) and
  emits ~20–28× slower. Size is a wash (~1.06× gzipped). The cost is format-preservation (owned
  span + whitespace per node) — right for authored files, far too heavy for bulk machine IR under
  "regenerate aggressively" (≈200 frameworks × several parses/run: seconds → minutes).

**Decision — NO-GO for machine KDL; JSON retreat invoked.** `extracted.json` and `resolved.json`
stay JSON (status-quo `serde_json`; the back-end is a swap, the IR is serde-based). **Authored
`annotations.apiw` stays KDL** — small, human/LLM-authored, eval-backed, the genuinely
hard-to-reverse choice — unaffected. The triad is now `extracted.json` / `annotations.apiw` /
`resolved.json`. Downstream leaves adjusted: k18 (serde stays `serde_json`; crate still ships the
`.apiw` KDL parser + `_llm-annotations`→`annotations.apiw` converter), k19 (KDL Schema covers
`.apiw`; machine artifacts get JSON Schema or defer to ws8), k20 (cutover writes `.json` machine
files), k21 (datalog fact base is `extracted.json`, derived facts stamped into `resolved.json`).
