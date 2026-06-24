# spec-format-k16 — brief

**Kind:** node brief (was a planning leaf; grilling complete 2026-06-24 — decomposed)

## Goal

**Workstream 2** of the `structural-refactoring` grove: realize the **spec format / data
model** — the `.apiw` DSL + KDL interchange that replaces the JSON enriched IR. The **design
is settled** (grilling complete); the child leaves **implement** it. This is the spine
workstreams 3 (semantic), 4 (platform), 5 (LLM side-channel), 6 (target) consume.

## Settled design (the children build to this — do NOT re-grill)

- **PRD:** [`prd/2026-06-24-spec-format-data-model.md`](../../../prd/2026-06-24-spec-format-data-model.md) — the design spec.
- **ADR-0046** (amended by k17) — KDL is the **authored** overlay format; per-family triad
  `extracted.json`/`annotations.apiw`/`resolved.json` (machine side is JSON since the k17
  no-go/retreat — see running-log **H**); provenance/confidence carried in-format.
- **ADR-0047** — convention heuristics are `ascent` datalog rules (retire imperative `heuristics.rs`).
- **Evidence:** [`semantic/docs/research/2026-06-24-kdl-authoring-eval/`](../../../semantic/docs/research/2026-06-24-kdl-authoring-eval/README.md) — LLM KDL-authoring eval.
- **Glossary:** `CONTEXT.md` → "Spec format / data model" section (spec triad, KDL interchange,
  `linked` rename, convention rule, provenance stamp).

## Decomposition (staged; each buildable + goldens-green; D4)

ws2 **owns** the `analysis/ir/` → `platforms/macos/api/` relocation (reassigned from ws4 —
format+location are one op over gitignored artifacts; ws4 inherits the populated tree).

1. **`kdl-serde-spike-k17`** ✅ *(done 2026-06-24 — **NO-GO**, JSON retreat invoked; running-log H)* —
   gated: KDL machine-serde + large-IR perf. Result: lossless but ~80–100× slower parse → machine
   IR stays JSON; authored `.apiw` stays KDL.
2. **`spec-format-crate-k18`** — `semantic/tools/spec-format`: `.apiw` KDL parser + machine-IR
   `serde_json` (status quo, per k17 retreat) + converters (`_llm-annotations`→`annotations.apiw`).
3. **`kdl-schema-k19`** — KDL Schema for **`annotations.apiw`** → `schemas/spec-format/`; machine
   `extracted.json`/`resolved.json` get JSON Schema (or defer to ws8).
4. **`pipeline-cutover-k20`** — rewire pipeline to the triad at per-family paths (machine `.json`);
   4→3; rename `resolved`→`linked`; fold `_llm-annotations`→`annotations.apiw`.
5. **`conventions-datalog-k21`** — retire `heuristics.rs` for ascent rules (ADR-0047).

After k21 retires, ws2 likely has no live leaf → the retire-cascade asks before treating
workstream 2 done. Discharges the `TODO (workstream 2)` markers in the placeholder READMEs.

## Context (inherited — see `grove-llm brief-chain`)

The skeleton (`skeleton-k2`) is complete: five-domain tree, internal rename, docs co-located,
pipeline building + 71 test suites green. Content rewrites land **in place** in the new tree.
Background still worth reading: `REFACTOR.md` §29/§28/§14/§13/§12/§30/§7.1; `CONTEXT.md`;
root `BRIEF.md` (nine-workstream decomposition + Skeleton outcomes). Keep `cargo fmt --all` +
standalone `style:` commits in mind as code lands.

## Decisions (running log)

Appended as each grilling question settles (driving.md running-log pattern). The PRD at the
end is the human-facing synthesis; this log is the audit trail.

### A — Artifact / pipeline model *(settled 2026-06-24)*

**Adopt REFACTOR §14's three-file triad as the on-disk interchange.** Per API family
(`platforms/macos/api/<Framework>/`): `extracted.yaml` (mechanical facts; ≈ today's
`collected.json`) + `annotations.apiw` (authored + LLM semantic overlay; absorbs today's
`_llm-annotations/*.llm.json` + Rust heuristics) + `resolved.yaml` (deterministic merged
graph, the generator input; ≈ today's `enriched.json`). Today's intermediate pipeline stages
— datalog cross-ref `resolved` and `annotated` — become **in-process stages**, not on-disk
artifacts. **Consequence:** the pipeline-stage name `resolved` (datalog, `analysis/ir/resolved`)
**collides** with §29's `resolved.yaml` (final merged graph = today's `enriched`); the datalog
stage must be **renamed** (candidate: `linked` / `cross-resolved`) so the glossary carries one
meaning of "resolved". Glossary update deferred until the rename term is chosen (see later Q).

### B — Format / syntax: **KDL 2.0, single format for the whole stack** *(settled 2026-06-24)*

**One format everywhere** (user's proposal, after interrogation): authored overlay
`annotations.apiw`, pattern-kinds, and app-kinds are **KDL 2.0**; the machine artifacts
become `extracted.kdl` / `resolved.kdl` (also KDL) — **superseding §14/§29's `.yaml` literals**
on the user's authority as REFACTOR's author. Reverses the opening two-format (KDL+YAML)
recommendation. Evidence:
- **Ecosystem (verified, web):** KDL 2.0 shipped; official maintained `kdl` Rust crate
  (document-model, format-preserving, miette diagnostics); serde adapters exist
  (`serde_kdl`/`serde-kdl`); a **KDL Schema Language** (KDL-in-KDL, JSON-Schema-inspired)
  exists for ws8; broad cross-language + editor support. **Counter-fact that flipped the
  call:** `serde_yaml` was *archived/deprecated* (Mar 2024) — YAML's serde lineage is dead/
  fragmented, so "YAML = safe machine format" no longer holds.
- **LLM-authoring eval (empirical, scratchpad `eval/`, 2026-06-24):** 6 fresh subagents
  (2× KDL / 2× YAML / 2× JSON) authored the **same 20 real-shape method annotations** from
  the same neutral facts+vocab; validated with the real `kdl` crate + PyYAML + json.
  **Result: 6/6 well-formed; selector + type fidelity 6/6 clean.** Escaping burden:
  **KDL 0** escapes (40 raw-string `#"…"#` uses) · YAML 34 `\"` · JSON 96 `\"`. KDL raw
  strings let the model write quote/dash/arrow-heavy rationale prose verbatim — *better*
  than YAML for the realistic content, refuting the worry that KDL might be worse than YAML
  for LLM authoring. Caveat logged: small sample (one model, one task), directional not proof.

**Gated risk:** the official `kdl` crate is *document-model*, not serde-derive — the
**machine-side serialization** of the large IR (perf + serde adapter maturity) is **unproven**
and is **gated on a spike** in the first implementation leaf; **JSON is the documented retreat**
for `extracted`/`resolved` if the spike fails (the whole IR is serde-based, so the machine
back-end stays swappable — the hard-to-reverse choice is the *authored* KDL, which the eval
backs). **Toolchain note for impl:** `kdl` 6.7.1 needs rustc 1.95; this repo is on rustc 1.93.1
→ pin `kdl = "=6.3.4"` (used by the validator) or bump the toolchain.

**Raises an ADR** (KDL-everywhere supersedes §29's YAML; hard-to-reverse authored layer,
surprising, real trade-off) — to be written at leaf finish (next number: **ADR-0046**). The
eval harness + outputs are the ADR's rationale source; capture as a co-located research doc.

### C — Producer→file mapping + conventions as datalog *(settled 2026-06-24)*

**Producer→file (Option A):** `extracted.kdl` = pure mechanical extraction (the datalog
*fact base*). `annotations.apiw` = ONE authored semantic overlay holding **manual + accepted-LLM**
facts; the committed `_llm-annotations/*.llm.json` **fold into it** (converted once → KDL).
`resolved.kdl` = the deterministic merge (fact base ⊕ rule-derived facts, then overlay applied
by §28 precedence), every fact **provenance-stamped**; the generator input.

**Conventions as datalog (user steer):** the **1,236-line imperative `annotate/heuristics.rs`**
(59 naming-convention classifiers) is **re-expressed as declarative ascent rules** in the
datalog layer — same engine as the existing resolution/ownership ascent programs — making the
"platform convention rule" precedence tier legible + extensible. Rules are **not** a persisted
artifact; their *derived facts* land in `resolved.kdl` stamped with the deriving rule.
**Provenance falls out of the derivation trace** — this pre-answers much of D (datalog knows
which rule produced which fact; the imperative path throws that lineage away).

**Rule authoring surface = compile-time ascent** (recompile to change), not a runtime-loaded
DSL. Legible declarative rules in version-controlled Rust; changing them is a normal pipeline
rebuild (the "regenerate aggressively" habit). Runtime-loadable rules noted as a possible later
enhancement (would need a runtime datalog engine — out of scope now).

**Consequence / work:** converting `heuristics.rs` → ascent rules is a substantial child leaf
(its own). Likely an ADR (conventions-as-datalog, unifying with resolution; legibility +
provenance trade-off vs imperative) — **ADR-0047** candidate, or folded into the data-model ADR.

### D — Provenance / precedence / confidence: format carries, ws5 owns workflow *(settled 2026-06-24)*

**Seam:** **ws2 defines the carriage** (the data model that *can express* provenance/precedence/
confidence); **ws5 builds the mechanism** (caching, regeneration, the propose→review→accept
workflow, diff tooling) reading/writing this format. ws2 fixes:
1. **Per-fact provenance stamp** in `resolved.kdl`: `source` ∈ {extraction, `convention:<rule>`,
   llm, manual} — the `convention:<rule>` lineage supplied free by the datalog derivation (C).
2. **Confidence = coarse enum `high|medium|low`** (NOT a float — avoids false precision in LLM
   self-assessment; legible) on authored facts in `annotations.apiw`, alongside a `provenance`
   (doc URL / rationale). Confidence is **new** (today's `_llm-annotations` carry only `source`).
3. **Deterministic precedence** applied in resolve per §28's ladder (`manual > accepted-LLM >
   convention > extraction > unknown`); on disagreement the **winner is stamped and losers
   retained** as a `superseded-by` record (auditable; generalizes today's `AnnotationDisagreement`
   + `validate` disagreement-flagging).
4. **Unknowns explicit** — no producer ⇒ `unknown`, never silently defaulted (§28).
5. **Presence = in-effect** (today's model): `annotations.apiw` is the committed overlay that's
   consumed; no separate ws2 "accept" gate — the richer accept workflow is ws5.

### E — Migration: co-move, staged, ws2 owns relocation *(settled 2026-06-24)*

Old IR paths are gitignored/regenerable and `_llm-annotations` already lives at
`platforms/macos/api/`, so format+location are **one operation** → **ws2 takes over ws4's
relocation TODO** and lands the KDL triad directly at `platforms/macos/api/<Framework>/`; ws4
inherits the populated tree and keeps platform *content*. **Staged** child leaves (spike →
parser/serde → schema → cutover → conventions-datalog), pipeline green + goldens intact at each
step (D4). Not big-bang (a 4-change goldens regression is hard to localize).

### F — Schema: language-neutral KDL Schema contract *(settled 2026-06-24)*

Per user steer ("a schema is useful for *other languages*, not our Rust serde types"): the schema
is the **authoritative, language-neutral contract** for all three artifacts (Rust types are one
*conforming impl*, not the truth). Mechanism = the **KDL Schema Language** (KDL-in-KDL) — coherent
for KDL artifacts, no JSON projection. Authored in ws2 → `schemas/spec-format/`; ws8 owns
validation tooling/CI + schemas for the *other* artifacts. (JSON-Schema-over-projection rejected:
reintroduces JSON; every consumer must reproduce the projection.)

### G — Crate home: new `semantic/tools/spec-format` *(settled 2026-06-24)*

A dedicated crate houses the `.apiw` parser + IR-as-KDL serde + schema validation + converters
(json→kdl, `_llm-annotations`→`annotations.apiw`); depends on `apianyware-types` + `kdl`. Keeps the
foundational `types` crate **dependency-light** (no `kdl` in it). Shared machinery under its domain
per the crate-home convention.

### Closeout *(2026-06-24)*

Grilling complete (A–G). Produced: PRD `prd/2026-06-24-spec-format-data-model.md`, ADR-0046,
ADR-0047, research doc `semantic/docs/research/2026-06-24-kdl-authoring-eval/`, `CONTEXT.md`
"Spec format / data model" section + `platforms/` `.yaml`→`.kdl` fix. Decomposed into k17–k21.
Leaf `spec-format-k16` converted to this node.

### H — Machine-KDL spike outcome: **NO-GO → JSON retreat** *(k17, 2026-06-24)*

Spike (`kdl-serde-spike-k17`) gated ADR-0046 §5. Real input: regenerated AppKit (12.7 MB) +
Foundation (8.7 MB) extracted-shape IR via the live extractor. Probe: a generic, bijective
`serde_json::Value ⇄ kdl::KdlDocument` bridge (canonical JSON-in-KDL) over the official `kdl`
crate (=6.3.4) — chosen because `Framework → serde_json::Value` already works, sidestepping the
IR's one serde landmine (`TypeRef` = `flatten` + internally-tagged enum). Full evidence:
`semantic/docs/research/2026-06-24-kdl-machine-serde-spike/`.

**Numbers (release, arm64):**

| | AppKit | Foundation |
|-|--:|--:|
| json parse / **kdl parse** | 23 ms / **1795 ms** | 12 ms / **1205 ms** |
| KDL/JSON parse ratio | **~77×** | **~104×** |
| json emit / kdl serialize | 12 ms / 279 ms (~23×) | 7 ms / 190 ms (~28×) |
| size kdl ÷ pretty-json / gzip | 1.21× / 1.06× | 1.22× / 1.06× |

**Findings.** (1) **Correctness ✅** — IR round-trips JSON↔KDL **losslessly** (structural equality,
both frameworks). One library footgun: the `kdl` crate emits the strings `null`/`true`/`false`/
`nan`/`inf`/`-inf` **bare**, then its own parser rejects them — a write-side round-trip defect a
production writer must force-quote around (real IR has a selector `"null"`, params `"true"`/
`"false"`/`"nan"`). (2) **Performance ❌** — the official document-model crate (the *only*
production-grade KDL-2.0 path; `serde_kdl` is abandoned on KDL 1.0, the `*-kdl` derive crates are
0.x non-serde) parses ~80–100× slower than `serde_json`; format-preservation overhead is right for
authored files, far too heavy for bulk machine IR under "regenerate aggressively". (3) **Size** —
a wash (~1.06× gzipped).

**Decision.** Machine `extracted`/`resolved` **stay JSON** (`extracted.json`/`resolved.json`;
status-quo `serde_json`, a back-end swap since the IR is serde-based). Authored `annotations.apiw`
**stays KDL** (small, eval-backed, hard-to-reverse). Propagated: ADR-0046 Status + "Update —
spike outcome"; `CONTEXT.md` triad/KDL-interchange/convention/provenance entries; PRD status note;
k18/k19/k20/k21 leaf briefs adjusted; spike code is throwaway (scratchpad), not in-tree — its
source archived in the research doc for reproducibility.
