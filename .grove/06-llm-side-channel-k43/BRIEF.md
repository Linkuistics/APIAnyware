# llm-side-channel-k43 — brief

**Kind:** node (decomposed from the ws5 planning leaf; design settled 2026-06-25)

## Goal

**Workstream 5** of the `structural-refactoring` grove: realize the **LLM analysis
side-channel** — the *operating layer* over the per-family `annotations.apiw` overlay that
makes LLM-produced semantic facts cached / regenerable / diffable / reviewable /
provenance-tracked / confidence-scored, and realizes the ADR-0046 §4 fact-precedence /
disagreement audit that ws2 (k26) and ws3 (D6) deferred here (root brief decomposition #5).

The grilling settled the design (decisions log below; **ADR-0050**; glossary terms in
`CONTEXT.md` "LLM side-channel workflow"). The headline: **ws5 is a lean mechanism over git +
the existing pipeline, not a bespoke staging/cache subsystem** — the overlay is already a
git-committed `.apiw` text file, so *diffable / reviewable / accept* come from git; ws5 builds
only the provenance/precedence mechanism + staleness detection + reworked orchestration.

## Design (settled — see ADR-0050 + `CONTEXT.md`)

- **Git is the propose→review→accept boundary.** `accepted-LLM` (§28 tier) ≡ a *committed*
  `source llm` fact. No staging store, no `status` flag, no state machine.
- **Two source vocabularies, two homes.** Overlay (`annotations.apiw`, committed) =
  `{llm, manual}`. Resolved (`resolved.json`, derived + gitignored) = full ladder
  `{extraction, convention:<rule>, llm, manual, unknown}`. Per-fact provenance lives in
  `resolved.json`, not the overlay.
- **Disagreement audit at resolve time, golden-neutral.** Per fact-slot: precedence-stamp the
  winner's `source`, record disagreeing losers as `superseded-by`, leave no-producer slots
  explicit `unknown`. Stamps *provenance only* (winning value unchanged) → **emit-invisible →
  goldens cannot move**. This invariant is the gate for every child.
- **Staleness computed live** (set-diff overlay vs `extracted.json`: orphaned / new-surface /
  shape-changed) — no stored hash. **Regeneration** = Claude-Code subagents per stale family,
  each writing `.apiw` directly (economic constraint; annotate runs once per SDK update).
- **Tooling:** retire the bash/python/external-API scaffolding; replace the two analysis
  scripts with typed `apianyware-analyze` subcommands; rework the two canonical docs + the
  `analyze` command/skill over `.apiw`.
- **Crate home:** extend `platforms/macos/tools/annotate` + `apianyware-analyze` subcommands;
  no new crate unless warranted. Annotations are **platform** knowledge — never `semantic/`.

## Decomposition (skeleton-first; grown lazily — only the live frontier is materialized)

Each child is buildable + goldens-green (provenance is emit-invisible, so goldens are the
gate throughout). Intended sequence — **do not pre-spawn**; grow the next when the current
retires:

1. **`provenance-vocab-k44`** *(first child — this session)* — reconcile `AnnotationSource`
   to the §4 vocabulary (`Heuristic`→`Convention`, `HumanReviewed`→`Manual`; `Llm` kept),
   update the `.apiw` parser/writer + `annotations.kdl-schema` source tokens + all consumers.
   Foundational + golden-neutral (no value change). `Extraction`/`Unknown` + the
   `convention:<rule>` payload defer to the children that produce them.
2. **`precedence-audit`** — the resolve-time disagreement audit: gather producers per
   fact-slot, apply §28 precedence, stamp winner `source`, record `superseded-by` losers,
   explicit `unknown`. Lands per-fact `source` + `superseded-by` in `resolved.json`.
   Emit-invisible; goldens green. (Adds `Extraction`/`Unknown` + the `convention:<rule>`
   payload as it produces them.)
3. **`staleness-regen`** ✅ *(k46, complete)* — `apianyware-analyze annotations stale` (orphaned /
   new-surface / shape-changed set-diff vs the **resolved API surface** `resolved.json` — *not*
   `extracted.json`: the overlay mirrors the inheritance/conformance-flattened, Swift-renamed
   resolved surface, so pre-resolve `extracted.json` mis-reports ~⅓ as orphaned; k46 finding,
   user-confirmed) + the regeneration worklist. **Annotatable shape** pinned to the structural
   predicate (block param or `NSError **` out-param; selector-substring delegate/observer signal
   excluded as noise) → `apianyware_annotate::surface`. Clap `Subcommand` scaffold landed
   (`resolve` default + `annotations` group; k47 `audit` adds a variant). Replaces
   `check-llm-annotation-drift.sh` (retire deferred to #6). ADR-0050 §4 + CONTEXT amended.
4. **`disagreement-report`** — `apianyware-analyze annotations audit` (reads `superseded-by`
   + agreement/redundancy counts per family). Replaces `audit-llm-redundancy.py`.
5. **`orchestration-skill`** — rework the `analyze` command/skill + the subagent prompt +
   `platforms/macos/docs/annotation-workflow.md` over `.apiw`; wire staleness worklist →
   per-family subagent dispatch → write `.apiw` → verify. Honour the economic constraint.
6. **`retire-tooling`** *(last)* — retire the dead scaffolding (`check-llm-annotation-drift.sh`,
   `audit-llm-redundancy.py`, `llm-annotate.sh`, `config.example.toml`,
   `llm-annotate-orchestration.md`, `prompt-template.md`); rework the Makefile
   `lint-annotations` target to the new subcommands.

## Done when

All six children retire. The retire-cascade then asks before treating **workstream 5** done;
on confirmation, promote the durable seams upward (root brief) and **ws6** (target model)
grows next (root brief decomposition #6).

## Seams to respect

- **ws2/ws8 boundary:** ws5 extends the `.apiw` overlay schema (tighten `source` to
  `{llm, manual}`) + the `resolved.json` Rust serde (full ladder + `superseded-by`); the
  *machine JSON Schema* for `resolved.json` + validation tooling/CI stay **ws8's**.
- **ws6 seam:** ws6 *consumes* resolved provenance/confidence (projection / representability);
  ws5 only produces it. Emit stays provenance-blind.
- **Economic constraint** ([[llm_annotation_constraint]]): annotation runs in Claude Code
  subagents, never an external paid API. The `config.example.toml` provider flow is dead.
- **Goldens-as-truth** is the regression gate; provenance is emit-invisible, so a moved golden
  is a bug, not an intended change.

## Decisions (running log)

- **D1 — ws5 shape = lean mechanism (B), not a staging subsystem.** *Settled (user delegated:
  "you decide").* The overlay is already a git-committed `.apiw` text file → diff/review/accept
  come from git; the convention tier is pure datalog recomputed each run (nothing to cache);
  annotate runs once per SDK update (k26 minimal-carriage). So ws5 = the §4 audit + live
  staleness + reworked orchestration + tooling disposition, built over the existing pipeline +
  git. Rejected: a bespoke staging area / propose-accept state machine / content-hash cache.
  → ADR-0050; `CONTEXT.md` "Side-channel workflow".
- **D2 — Git is the propose→accept boundary; `accepted-LLM` ≡ committed `source llm`.** No
  separate on-disk `proposed`/`accepted` state; the `source` field already encodes the §28
  tier; a human accepts by committing the diff. → ADR-0050; `CONTEXT.md` "accepted-LLM".
- **D3 — Two source vocabularies, two homes.** Overlay `{llm, manual}` (authored, committed);
  resolved `{extraction, convention:<rule>, llm, manual, unknown}` (derived, gitignored).
  Per-fact provenance + `superseded-by` live in `resolved.json` only, never the overlay. The
  `AnnotationSource` enum reconciles to the §4 vocab (k44). → ADR-0050; `CONTEXT.md`
  "Authored-overlay source vs resolved source".
- **D4 — The disagreement audit is golden-neutral by construction.** It stamps *provenance*,
  not winning values (the winning value already matches today's `llm`-over-convention merge);
  emit is provenance-blind → goldens cannot move. Verified: `emit_class.rs`'s only `Heuristic`
  is a code comment; no emit crate branches on `source`. → ADR-0050 §3; `CONTEXT.md`
  "Disagreement audit".
- **D5 — Staleness live (no stored hash); regeneration explicit + in Claude Code.** Set-diff
  the committed overlay against the current **resolved API surface** (`resolved.json`) — *not*
  `extracted.json` (k46 correction, user-confirmed: the overlay is authored over the
  inheritance/conformance-flattened, Swift-renamed resolved surface; pre-resolve `extracted.json`
  mis-reports ~⅓ of facts as orphaned). `resolved.json` is self-contained, so the check is a pure
  file read (no resolve pass); dispatch subagents per stale family, each writing `.apiw` directly.
  → ADR-0050 §4 (amended); `CONTEXT.md` "Staleness / regeneration".
- **D6 — Retire scaffolding, replace scripts with Rust subcommands, rework canonical docs.**
  The bash/python/external-API artifacts encoded retired paths + a dead provider model → retire;
  the two analysis scripts → typed `apianyware-analyze annotations {stale,audit}` subcommands;
  rework `annotation-workflow.md` + the `analyze` command/skill + `lint-annotations`. → ADR-0050 §5.
- **D7 — Crate home: extend `platforms/macos/tools/annotate` + `apianyware-analyze` subcommands;
  no new crate unless warranted.** Annotations are platform knowledge → stays in `platforms/`.
  → ADR-0050 §6.
