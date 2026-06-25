# llm-side-channel-k43 — brief

**Kind:** planning

## Goal

**Workstream 5** of the `structural-refactoring` grove: realize the **LLM analysis
side-channel** — the *workflow* over the per-family `annotations.apiw` overlay that
makes LLM-produced semantic facts **cached / regenerable / diffable / reviewable /
provenance-tracked / confidence-scored**, and realizes the **fact-precedence /
disagreement-audit** rules ws2 and ws3 deferred here (root brief decomposition #5).
This is a **planning leaf**: it opens with a grilling session to settle the
side-channel design, then **decomposes** the tree into build children (do the
**first child only** this session). Do not pre-author the mechanism — grill first.

## Context (inherited — see `grove-llm brief-chain`)

- **Spine ws1–ws4 complete.** The five-domain skeleton (ws1), the `.apiw` DSL +
  per-family triad (ws2), the first-class pattern-kind/instance semantic model
  (ws3), and the macOS platform model (ws4) all landed. ws2's `pipeline-cutover-k20`
  already **reshaped the flat `_llm-annotations/*.llm.json` staging side-channel into
  the per-family `annotations.apiw` overlay** — so the overlay (the workflow's
  subject) physically exists for all 153 families. ws5 builds the *workflow* around
  it; it does **not** reshape the side-channel again.
- **ws2 seam (k26 — "ws2 defines the carriage, ws5 builds the mechanism").** The
  convention facets *compute* a per-fact/per-index `convention:<rule>` stamp, but the
  cutover kept it **off-disk** (assembled convention annotations stay byte-identical,
  `source = Heuristic`, no provenance). The richer rollout is **ws5's**: per-fact
  stamps on `ParamOwnership`/`BlockParamAnnotation` + per-method threading/error, the
  `.apiw` schema/writer + machine serde for them, emit consumers, **and the ADR-0046
  §4 disagreement/precedence audit** (winner stamped, losers kept as `superseded-by`).
  Steer (user, k26): `annotate` runs *once per SDK update*, so **keep the carriage
  minimal** — annotate the canonical API, don't over-engineer prose-derived extras.
- **ws3 seam (D6).** ws3 defined only the pattern-*instance* provenance *carriage*
  (`source`/`confidence`/`provenance`; precedence `manual > llm > convention >
  extraction`). The per-fact **cache / regen / review-accept / diff** workflow + the
  disagreement-precedence audit is **ws5's** — same shape as the k26 convention-fact
  seam.
- **Superseded tooling to rework over `.apiw`** (TODO.md ws5 row — all currently
  carry a superseded→ws5 banner): `platforms/macos/docs/annotation-workflow.md`,
  `check-llm-annotation-drift.sh`, `audit-llm-redundancy.py`,
  `tools/scripts/llm-annotate-orchestration.md`, `tools/scripts/llm-annotate-subagent.md`,
  `config.example.toml`, `.claude/commands/analyze.md`, the `Makefile`
  `lint-annotations` target. Decide per-tool: reworked over `.apiw`, or retired.
- **LLM-annotation economic constraint** (memory `llm_annotation_constraint`): LLM
  annotation **must run within Claude Code** (subagents per framework), **not** an
  external paid API. The orchestration design must honour this — the
  `config.example.toml` provider-API flow is the *old* model.
- **Provenance/precedence vocab** already in `CONTEXT.md` ("Provenance stamp /
  precedence / confidence"): `source ∈ {extraction, convention:<rule>, llm, manual}`;
  authored facts add `confidence` (enum `high|medium|low`) + `provenance`. ws5 makes
  the *format-carried* record an *operable workflow*.
- **Glossary:** `CONTEXT.md` (read every session) — add side-channel-workflow terms
  as they resolve (cache key, staleness, propose/accept state, the precedence audit).

## Grilling agenda (open questions to settle — recommend, don't dictate)

- **Cache & staleness.** What is the cache unit and key — per-family, per-method, or
  per-fact, keyed on a content hash of the extracted shape (+ doc source)? When does an
  annotation regenerate (SDK shape change, doc-source change, explicit request)? How is
  staleness detected and surfaced (the old `check-llm-annotation-drift.sh` territory)?
- **Propose → review → accept.** How does a freshly-LLM-produced annotation move from
  *proposed* to *accepted* (committed `annotations.apiw`)? Is there a staging/proposed
  state distinct from accepted, and how does a human review a batch (diffable, per-fact
  provenance + confidence visible)?
- **Disagreement-precedence audit (ADR-0046 §4).** Build the mechanism: apply §28
  precedence (`manual > accepted-LLM > convention > extraction`) in resolve, stamp the
  winner, keep losers as a `superseded-by` record; a fact with no producer stays explicit
  `unknown`. What surfaces the audit to a reviewer?
- **Per-fact carriage rollout (the k26 deferral).** Which facts get per-fact
  `source`/`convention:<rule>` stamps on disk now (vs. staying minimal)? Does this extend
  the `.apiw` schema (ws2/ws8 boundary — ws2 owns the `.apiw` schema; ws8 owns machine
  JSON Schema) — confirm who edits what.
- **Crate home + orchestration.** Where does the workflow code live — a new crate under
  `platforms/macos/tools/` (annotations are *platform* knowledge — the domain rule), or
  elsewhere? How does the Claude-Code-subagent orchestration integrate (per-framework
  subagents, the economic constraint)?
- **Tooling disposition.** Per superseded artifact: reworked over `.apiw` or retired?
  What replaces `.claude/commands/analyze.md` + the `Makefile` `lint-annotations` target?

## Done when

- The side-channel-workflow design is **settled** (grilling complete; running decision
  log in this brief, terms in `CONTEXT.md`, ADRs raised *sparingly*, a PRD at a genuine
  agreement point if one is warranted).
- The leaf is **decomposed** into a node (`leaf-decompose`) with ordered, buildable,
  goldens-green build children — and the **first child** is authored and executed **this
  session** (the rest grow lazily as earlier ones retire).

## Notes (steers)

- **Planning task.** Grill one question at a time, propose a recommended answer for each,
  walk the design tree to shared understanding (`grilling.md`, `driving.md`). Commission a
  prior-art / fresh-context research leaf if a seam warrants it.
- **Honour the economic constraint:** annotation runs in Claude Code (subagents per
  framework), not external APIs. **Keep the carriage minimal** (k26 steer — annotate runs
  once per SDK update).
- **Goldens-as-truth** is the regression gate (the convention-equivalence guard ws2 left
  standing); a workflow change must not move emit goldens unless intended.
- **Lazy decomposition** — do **not** pre-spawn all of ws5's children. Skeleton-first
  (D4): every child buildable + goldens-green.
- **Seams to respect:** ws2 defined the carriage / ws5 builds the mechanism; ws3 defined
  the instance carriage / ws5 builds the workflow; **ws8** owns the machine-JSON schemas +
  validation tooling/CI; **ws6** *consumes* resolved facts (projection). Keep ws5 to the
  *side-channel workflow + precedence audit*. Annotations are **platform** knowledge — the
  workflow stays in the platforms domain, not `semantic/`.
- After ws5's last child retires, the retire-cascade asks before treating workstream 5
  done, then **ws6** (target model) grows next (root brief decomposition #6).

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).
