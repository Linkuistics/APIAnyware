# schema-validation-k149 — brief

## Goal

**Workstream 8 — schemas + validation** (root BRIEF decomposition #8: `schemas/` —
"formal validation of every artifact"). Deliver the missing validation layer over the
already-authored artifacts: a **machine-IR schema** (format TBD by the spike below), a
**single validation mechanism** over every artifact, and the **`schemas/docs/`
validation-model prose** — plus, if the spike passes, migrate the machine IR
`extracted.json`/`resolved.json` to **KDL** (user steer D1) so validation collapses to one
schema language. Golden-neutral by default (emit goldens unmoved); flag loudly if any
decision moves goldens.

ws8 is **not** re-authoring the twelve `.apiw` KDL-Schemas that already exist under
`schemas/spec-format/` — ws2–ws6 authored those + their in-crate validators. ws8 adds the
machine layer + the mechanism + the coherent home.

## Done when

Every child leaf is retired and:
- the machine-IR **format decision** (KDL vs JSON) is made on the spike's real numbers and
  recorded in an ADR that supersedes the ADR-0046 k17 Update;
- the machine IR has a **schema** (KDL-Schema reusing the existing generic engine if the
  spike passes; otherwise the JSON-Schema-or-defer call is settled);
- there is **one validation mechanism** covering every authored artifact + the machine IR
  (rationalizing `validate_apiw` + `lint-annotations` + the per-crate registry tests into a
  coherent story — the CI question is open, see child `02`);
- the `schemas/` domain has its **validation-model prose** (`schemas/docs/`);
- emit goldens are unmoved (or any movement is explicitly justified).

## Decomposition

Two children, because the entire downstream shape **forks on one measurement**:

1. **`01-machine-format-spike-k150`** (work/spike) — the go/no-go gate. Measures a
   machine-oriented (non-format-preserving) KDL codec against `serde_json` on the real IR,
   reports numbers, recommends. **The user decides go/no-go on the numbers** (D2). This is
   the only *risk* in ws8; it runs first so the build is planned with the risk resolved.
2. **`02-build-plan-k151`** (planning) — runs *after* the spike. Fixes the machine-IR format
   decision, then grills the still-open questions (below) and grows the concrete build leaves
   (machine-IR schema · unified validation mechanism · `schemas/docs/` prose · CI). Deferred
   here because one-schema-language-vs-two, and whether there is an IR-migration to build and
   document, both depend on the spike outcome — pre-spawning build leaves now would be
   speculative (lazy materialization).

## Open questions deferred to child `02` (post-spike planning)

Decide *with* the user then; do not pre-answer:

- **Where does validation run** — CI gate, pre-commit, pipeline step? Note **no CI exists
  today** (`.github/workflows/` absent), so this is net-new infrastructure, not a
  rationalization of an existing gate. Unify `validate_apiw` + `lint-annotations` into one
  `apianyware-validate`-style command, or leave federated?
- **Is `schemas/` a passive catalogue or an active tool home?** The generic KDL-Schema
  engine already lives in `semantic/tools/spec-format`; does `schemas/` get a `tools/` crate
  at all, or stay a catalogue + docs?
- **Derived-report schemas** — does any machine report (conformance coverage,
  capability/representability derivation) get committed + schema'd, or stay on-demand
  (ws6/ws7 kept coverage derived, index points at it)?
- **Machine-IR schema shape** — if the spike passes, a machine-KDL-Schema over the IR reusing
  `validate_against_schema`; if it fails, the original "author a machine JSON Schema at all?"
  question (the ws7 D3 "IF a real consumer materializes" test likely resolves it to *defer*).

## Standing ws8 seams (from the root BRIEF — brief-chain context)

Every prior workstream deferred a concrete slice here:

- **Machine schema for the derived IR.** ws2–ws6 each authored their `.apiw` KDL-Schema + a
  focused in-crate validator, leaving ws8 the machine schema for `extracted.json` /
  `resolved.json` + any derived machine report. (D1 reopens whether that machine IR should
  even stay JSON.)
- **Validation tooling/CI.** Today validation is per-artifact, in-crate + on-demand `make`.
  ws8 owns unifying it ("formal validation of *every* artifact").
- **AppSpec is explicitly NOT ws8's (ws7 D1, ADR-0052).** `#lang app-spec` is the external
  AppSpec project's format; AppSpec owns its own reader/validation. The "ws8 owns the machine
  schema" seam does **not** extend to AppSpec data — there is no grove-authored AppSpec
  artifact for ws8 to schema. Do not reintroduce it.

## Pointers

- `REFACTOR.md` §8 (domains), §29 (spec format), §45.13 (obvious-home criterion — already met
  structurally), §47 (end state).
- ADR-0046 (spec interchange format; the **k17 Update** is what D1 reopens) + ADR-0047.
- `CONTEXT.md` "Spec format / data model" (the machine-IR-is-JSON facts + the _Avoid_ note D1
  challenges); constraint 4 (machine IR gitignored + recomputable).
- The existing generic engine: `semantic/tools/spec-format/src/schema.rs`
  (`validate_against_schema`) + the twelve `schemas/spec-format/*.kdl-schema` + their per-crate
  `validate_*` wrappers + `tests/*_registry.rs`.
- k17's spike report: `semantic/docs/research/2026-06-24-kdl-machine-serde-spike/` (the method
  `01` mirrors) and the authoring eval `…/2026-06-24-kdl-authoring-eval/`.

## Decisions (running log)

**D1 — Machine IR format is spike-gated back toward KDL (conditionally reverses the k17
NO-GO).** User steer (2026-07-04): *"I would rather move the json documents we produce to be
KDL … conditionally, depending on achievable performance."* This reopens ADR-0046's k17 JSON
retreat, but **only for the machine IR** (`extracted.json` / `resolved.json`) and **only if a
fresh perf measurement clears a bar**. Grounding facts surfaced in grilling:
- k17's NO-GO was **purely performance** — the spike proved the IR round-trips JSON↔KDL
  *losslessly* (the data model IS expressible in KDL 2.0). The blocker was the **format-preserving
  document-model `kdl` crate** measuring ~80–100× slower than `serde_json` (AppKit 12.7 MB:
  1795 ms vs 23 ms; Foundation: 1205 ms vs 12 ms), too heavy for [[regenerate_pipeline_aggressively]].
- A machine artifact (written once, read back mechanically) needs **no** format preservation, so
  the k17 measurement doesn't bind a **machine-oriented** (non-preserving) KDL codec — a path k17
  never measured (it noted `serde_kdl` was abandoned on KDL 1.0, the derive crates 0.x non-serde).
- **Why this matters for ws8:** if the machine IR becomes KDL, "formal validation of every
  artifact" collapses to **one schema language** (KDL-Schema) + the **generic engine that already
  exists** (`apianyware-spec-format::validate_against_schema`) — the machine-JSON-Schema seam
  disappears and is replaced by a machine-KDL-Schema that reuses proven code. If it stays JSON, the
  original Q1 (author a machine JSON Schema at all?) is back on the table.
- **Consequence:** ws8's first child is a **perf spike** (mirror k17's method: same AppKit+Foundation
  fixtures, apples-to-apples), go/no-go, landing in an ADR that supersedes the k17 Update. Everything
  downstream (schema shape, `schemas/` home, validation umbrella, prose, CI) forks on its outcome.

**D2 — The perf bar is "measure & decide" against a soft target.** User steer (2026-07-04):
the spike **reports real numbers**; the user makes the final go/no-go on the numbers (not a
hard pre-committed ceiling). Soft target: **machine-KDL parse within ~5× `serde_json`**, keeping
the full-corpus IR round-trip in the low seconds. The spike deliverable is a comparison table
(serde_json vs machine-KDL codec(s), on AppKit + Foundation, parse + emit) + a full-corpus
extrapolation + an incremental generate-loop delta + a recommendation against the soft target.
Scope of "the json documents we produce" = **`extracted.json` + `resolved.json`** only (per-family,
`platforms/macos/api/<F>/`, gitignored, ~153 families); the `.methods.json`/`.llm.json` files are
transient LLM-pipeline intermediates, out of scope.

**D3 — GO: the machine IR un-retreats to KDL (spike `machine-format-spike-k150`; user D2
call 2026-07-04).** The spike measured the path k17 never tested — a machine-oriented
(non-format-preserving) JiK codec over `serde_json::Value`. Numbers (report:
`semantic/docs/research/2026-07-04-kdl-machine-codec-spike/`):
- **raw codec (text↔Value): ~1.24–1.29× `serde_json`**; production **typed** path via the cheapest
  impl (Value-bridge): **~2.4–2.5× read / ~2.9–3.2× write** — all under the D2 ≤5× bar with ~2×
  headroom. k17's document-model path re-confirmed at **~84×** (the tax was format-preservation, not
  KDL). Full 4-target regenerate delta ≈ **+2.2 s** at a ~400 MB corpus (vs *minutes* for k17's path).
- **correctness settled + extended**: lossless round-trip on **both** `extracted` AND `resolved`
  (k17 only tested `extracted`); emitted text is **spec-valid KDL 2.0**. Size a wash.
- **no ecosystem crate clears the bar** (serde bridges route through the doc-model; `knus` needs a
  full non-serde IR re-derive) → the codec is a **hand-written ~300-line module, already prototyped
  + validated** in the spike.
- **The user's go/no-go is GO.** Consequences fixed for `02-build-plan-k151`: (a) machine IR format
  = KDL (filenames likely `extracted.kdl`/`resolved.kdl`); (b) codec homes in
  `semantic/tools/spec-format`; (c) the machine schema is a **KDL-Schema reusing
  `validate_against_schema`** — the machine-JSON-Schema seam every prior workstream deferred here
  **dissolves**, one schema language; (d) the migration is **golden-neutral at the emit layer**
  (generator reads the same typed `Framework`; only on-disk encoding changes) — the hard invariant
  the cutover leaf must hold; (e) raise the draft ADR
  (`…/ADR-DRAFT-supersede-k17-machine-kdl.md`) as a real ADR superseding the ADR-0046 k17 Update.
  Implementation depth (Value-bridge vs native serde JiK format, ~1.3–1.5×) is `02`'s call on the
  headroom numbers.

**State of the current tree (established by exploration, not yet a decision):**
- The KDL-Schema **engine is already shared** (`validate_against_schema`); every producing crate
  (`app-kinds`, `platform-manifest`, `platform-tests`, all six `target-model` submodules,
  `patterns`, `spec-format`) delegates to it + layers semantic checks the generic engine can't state.
- Authored-`.apiw` validation is **already comprehensive** via each crate's `tests/*_registry.rs`
  (loads + validates every real authored file). Missing: a machine-IR schema, a single tree-walking
  validation command, and the `schemas/docs/` validation-model prose.
- **No CI exists** (`.github/workflows/` absent) — validation runs via `cargo test` + on-demand
  `make lint-annotations`. So "CI gating" would be **net-new infrastructure**, a real scope call.

## Notes

- Kin cadence: ws2–ws7 each began as a root leaf whose planning session grilled then
  `leaf-decompose`d into a node (`spec-format-k16`, `semantic-model-k27`, …). This node follows it,
  with the twist that the format decision is spike-gated *inside* ws8 (mirroring how ws2 itself
  spike-gated the machine format at k17).
- Golden-invariance has held across every workstream (emit goldens unmoved). ws8 is tooling/schema
  — it should stay golden-neutral; a machine-IR format migration (if the spike passes) is
  golden-neutral **at the emit layer** (the generator must produce byte-identical output), which is
  the invariant `01`/its follow-on must hold.
- After ws8 retires, **ws9 (testing architecture)** is the last workstream, then the grove-finish
  cycle (this branch is ~236 commits ahead of main; the physical `APIAnyware-MacOS` → `APIAnyware`
  rename is a post-merge manual step per `MIGRATION.md`).
