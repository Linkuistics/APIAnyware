# The LLM analysis side-channel is a lean mechanism over git + the pipeline, not a staging subsystem

**Status:** accepted

**Raised by:** `structural-refactoring` grove, workstream 5 (`llm-side-channel-k43`).

**Builds on:** ADR-0046 §4 (the provenance/precedence *carriage* model — `source ∈
{extraction, convention:<rule>, llm, manual}`, `confidence` enum, `provenance`, precedence
`manual > accepted-LLM > convention > extraction > unknown`, winner stamped + losers
`superseded-by`). ADR-0046 §4 line 54 explicitly scoped *"the workflow over this
(caching/regeneration/review-accept/diff)"* to workstream 5; this ADR is that workflow.
ADR-0047 (convention tier as `ascent` datalog). The economic constraint that LLM annotation
runs **within Claude Code subagents**, not an external paid API.

## Context

Workstream 5's mandate (root brief decomposition #5) is to make the per-family
`annotations.apiw` overlay *cached / regenerable / diffable / reviewable / provenance-tracked
/ confidence-scored*, and to realize the §4 fact-precedence / disagreement audit that ws2
(k26) and ws3 (D6) deferred here. Read naively, those six adjectives suggest a new subsystem:
a staging area, a propose→accept state machine, a content-hash cache, a bespoke diff/review
surface. Three facts surfaced during the design session reframe the scope:

1. **The overlay is already a git-committed `.apiw` text file.** ws2's `pipeline-cutover-k20`
   reshaped the flat `_llm-annotations/*.llm.json` staging side-channel into the committed
   per-family `annotations.apiw` overlay. So *diffable* (`git diff`), *reviewable* (read the
   KDL in a PR), and *accept* (commit it) are already delivered by git + the human-readable
   format. The overlay **is** the cache.
2. **The convention tier is pure datalog derivation** (ADR-0047) recomputed every pipeline
   run from `extracted.json`. There is nothing to cache on that tier — recomputation *is*
   regeneration; the only expensive producer is the LLM tier, whose output is the committed
   overlay.
3. **`annotate` runs once per SDK update** (k26 steer) → *keep the carriage minimal*. A
   heavyweight staging/cache/state-machine subsystem is over-engineering for an
   once-per-update task whose review surface is already a `git diff`.

On disk today: 152 `annotations.apiw` files, **17,171 facts, every one `source llm`** — zero
`manual`, `convention`, `confidence`, `provenance`, or `superseded-by` anywhere. The
`AnnotationSource` Rust enum (`{Heuristic, Llm, HumanReviewed}`) and the
`annotations.kdl-schema` source-token list both still carry the *legacy* spellings, drifting
from the decided §4 vocabulary. Emit is **provenance-blind** — it projects the *facts*
(ownership/threading/…), never their `source`.

## Decision

**ws5 is a lean mechanism over git + the existing pipeline, not a bespoke staging subsystem.**

1. **Git is the propose → review → accept boundary.** A freshly-dispatched subagent writes
   `source llm` facts into the working tree; the human reviews the `git diff` and commits
   (accept) or discards (reject). The §28 tier **`accepted-LLM` ≡ a committed `source llm`
   fact** — there is **no separate proposed/accepted on-disk state**, no `status` flag, no
   staging store. The `source` field already encodes the precedence tier.

2. **Two source vocabularies, two homes.** The **authored overlay** (`annotations.apiw`,
   committed) carries only authored tiers — `source ∈ {llm, manual}`. The **resolved graph**
   (`resolved.json`, derived + gitignored) carries the full ladder — `source ∈ {extraction,
   convention:<rule>, llm, manual, unknown}` — after the audit. Per-fact provenance lives in
   `resolved.json`, **not** the overlay. The `AnnotationSource` enum reconciles to the §4
   vocabulary (`Heuristic`→`Convention` with a `<rule>` payload, `HumanReviewed`→`Manual`,
   `Extraction`/`Unknown` added by the children that produce them).

3. **The disagreement audit runs at resolve time and is golden-neutral by construction.**
   Per `(receiver, selector)` fact-slot, gather every producing tier, apply §28 precedence,
   **stamp the winner's `source`**, record each *disagreeing* loser as `superseded-by
   { source; value }`, and leave a no-producer slot **explicit `unknown`**. This only stamps
   *provenance* — the winning *value* already matches today's `llm`-over-convention merge — so
   per-fact provenance is **emit-invisible** and goldens-as-truth cannot move. That invariant
   is the regression gate for the whole rollout.

4. **Staleness is computed live; regeneration is explicit, in Claude Code.** Staleness =
   set-diffing a family's committed overlay against the current **resolved API surface**
   (`resolved.json`) — *orphaned* (a fact's `(receiver, selector)` is gone), *new-surface* (a
   current method of *annotatable shape* with no fact), *shape-changed* (a fact's targeted
   `param_index` no longer holds its kind) — with **no stored content hash**
   (artifacts-not-state). The comparison surface is the **resolved** graph, *not* raw
   `extracted.json`: the overlay is authored over the inheritance-flattened,
   protocol-conformance-flattened, Swift-renamed surface (the LLM is dispatched over
   `all_methods`), so a naive diff against pre-resolve `extracted.json` mis-reports ~⅓ of facts
   as orphaned (inherited methods keyed under a subclass; `FileManager` vs `NSFileManager`).
   `resolved.json` is self-contained — its `all_methods` already carry the cross-framework
   closure — so the check stays a pure file read: **no resolve pass and no dependency loading**
   inside the command, only the requirement that `resolved.json` be current (the natural
   post-SDK-bump order: collect → resolve → `annotations stale`). *Annotatable shape* is the
   **structural** predicate — a **block parameter** or an **`NSError **` out-param** — the two
   shapes the LLM reliably annotates; the legacy `delegate`/`observer` **selector-substring**
   signal is excluded (it surfaces accessor getters the LLM declines, ~75% steady-state noise).
   *(This corrects the design as first written — k46 implementation found "extracted.json" was
   the wrong surface; the rest of §4 stands.)* Regeneration dispatches Claude-Code subagents for
   the stale families only; each writes that family's `annotations.apiw` **directly** (the
   `.llm.json` side-channel is gone). The external-provider flow (`config.example.toml`,
   `llm-annotate.sh`) is dead.

5. **Tooling: retire the scaffolding, replace analysis scripts with typed Rust subcommands,
   rework the canonical docs.** The bash/python/external-API artifacts encoded retired paths
   and a dead provider model — they are **retired**, not ported. The two analysis scripts
   (`check-llm-annotation-drift.sh`, `audit-llm-redundancy.py`) become **typed subcommands of
   `apianyware-analyze`** (`annotations stale`, `annotations audit`) — same serde types, no
   path-drift, testable. The two canonical docs (`annotation-workflow.md`, the `analyze`
   command/skill) are **reworked over `.apiw`**; the Makefile `lint-annotations` target is
   reworked to call the new subcommands.

6. **Crate home: extend, don't add.** The mechanism extends `platforms/macos/tools/annotate`
   (it already performs the convention+llm merge — it just doesn't *stamp* the result); the
   workflow commands are subcommands of the existing `apianyware-analyze` CLI. No new crate
   unless the surface warrants one (crate-home convention: a new one would be
   `platforms/macos/tools/<crate>`). Annotations are **platform** knowledge → the workflow
   stays in `platforms/`, never `semantic/`.

## Consequences

- **The six adjectives resolve to a small new surface.** *Diffable/reviewable/accept/cached*
  ← git + the committed KDL overlay (no new code). *Provenance-tracked/confidence-scored/
  fact-precedence* ← the resolve-time audit (the genuine new mechanism). *Regenerable* ← the
  live staleness detector + subagent dispatch.
- **Goldens-as-truth stays the gate**, and the emit-invisibility of provenance makes every
  child golden-neutral by construction — a moved golden signals a *bug*, not an intended change.
- **No `proposed`/`accepted` state to maintain** anywhere; the cost is that "accepted" is only
  as granular as a git commit (you accept a family's diff, not an individual fact) — acceptable
  for an once-per-SDK-update cadence, and a human can still hand-edit a single fact to `manual`.
- **The schema tightens** (overlay `source` enum → `{llm, manual}`, dropping the never-used
  `heuristic`/`human_reviewed` tokens); the machine `resolved.json` JSON Schema for the
  full ladder + `superseded-by` remains **ws8's** (this ADR only extends the Rust serde).
- **Decomposition** (skeleton-first; grown lazily, not pre-spawned): `provenance-vocab-k44`
  (reconcile the enum/schema to §4 vocab — foundational, golden-neutral) → `precedence-audit`
  (the resolve-time disagreement audit → per-fact `source` + `superseded-by` in
  `resolved.json`) → `staleness-regen` (the `annotations stale` subcommand) →
  `disagreement-report` (the `annotations audit` subcommand) → `orchestration-skill` (rework
  the `analyze` command/skill + subagent prompt + `annotation-workflow.md` over `.apiw`) →
  `retire-tooling` (retire the dead scaffolding; rework `lint-annotations`).

## Why this clears the ADR bar

- **Hard to reverse:** the workflow *shape* (git-as-accept-boundary, two-vocab/two-home
  provenance, audit-in-resolved.json) is load-bearing for every ws5 child and for ws6's
  eventual consumption of provenance; choosing it wrong means rebuilding the data model.
- **Surprising without context:** the brief's six adjectives read as "build a subsystem"; the
  decision is "build almost nothing new — git already does most of it." A future reader will
  ask why there is no staging area.
- **A real trade-off:** a staging/state-machine subsystem (per-fact accept granularity,
  explicit propose/accept lifecycle) was the genuine alternative, rejected for the
  once-per-update cadence and the committed-text review surface.
