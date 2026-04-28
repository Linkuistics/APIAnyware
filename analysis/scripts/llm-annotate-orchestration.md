# LLM Annotation Orchestration

This is the workflow the **main Claude Code agent** follows to drive LLM
annotation across the whole SDK using parallel subagents. The constraint
(see project memory `LLM annotation must run within Claude Code`) is that
LLM calls happen inside Claude Code subagents, not via an external API.

For the per-subagent prompt, see `llm-annotate-subagent.md`.
For step-by-step provenance and merge semantics, see
`../docs/annotation-workflow.md`.

## Pipeline shape

```
analysis/ir/resolved/*.json
        │
        │  apianyware-macos-analyze llm-extract
        ▼
analysis/ir/llm-summaries/{Framework}.methods.json   ← what subagents read
        │
        │  one Claude Code subagent per file
        ▼
analysis/ir/llm-annotations/{Framework}.llm.json     ← what subagents write
        │
        │  apianyware-macos-analyze annotate --llm-dir
        ▼
analysis/ir/annotated/{Framework}.json               ← merged with heuristics
```

## Step 1 — Extract

Produce per-framework `.methods.json` summaries containing only methods that
need LLM classification (block params, error out-params, delegate patterns):

```bash
cargo run -q -p apianyware-macos-analyze -- llm-extract
```

Output: `analysis/ir/llm-summaries/{Framework}.methods.json`. Frameworks with
no interesting methods are skipped.

To target a subset:

```bash
cargo run -q -p apianyware-macos-analyze -- llm-extract --only Foundation,AVFoundation
```

## Step 2 — Dispatch subagents in parallel

For each `.methods.json` file, dispatch a Claude Code subagent using the
`Agent` tool. **Send all dispatches in a single assistant message so they
run in parallel** — see CLAUDE.md / system prompt guidance on parallel
tool calls.

```python
# Pseudo-code for the orchestration loop
import os, glob

template = open("analysis/scripts/llm-annotate-subagent.md").read()
prompt_block = extract_prompt_block(template)  # text between the --- markers

for summary_file in sorted(glob.glob("analysis/ir/llm-summaries/*.methods.json")):
    framework = os.path.basename(summary_file).removesuffix(".methods.json")

    # Skip frameworks already annotated this run (incremental re-runs).
    if os.path.exists(f"analysis/ir/llm-annotations/{framework}.llm.json"):
        continue

    dispatch_subagent(
        subagent_type="general-purpose",
        description=f"Annotate {framework} ({methods_count} methods)",
        prompt=prompt_block.replace("{FRAMEWORK}", framework),
    )
```

Each subagent is self-contained: it reads one `.methods.json`, fetches
documentation, writes one `.llm.json`, and runs `llm-validate` before
returning. Subagents do not share state.

### Sizing the batch

Some frameworks have hundreds of flagged methods. Inspect summary sizes
before dispatching:

```bash
jq '.method_count' analysis/ir/llm-summaries/*.methods.json | sort -n | uniq -c
```

A reasonable strategy for the first run: dispatch the small
frameworks first to validate the loop, then the large ones.
For frameworks with > ~200 methods, the subagent may need to chunk its
own work — that is the subagent's call to make, not the orchestrator's.

## Step 3 — Merge

Once the relevant `.llm.json` files exist, merge them into the annotated
checkpoints:

```bash
cargo run -q -p apianyware-macos-analyze -- annotate \
    --llm-dir analysis/ir/llm-annotations
```

Read precedence (handled by `annotate`):
`human_reviewed` > `llm` > `heuristic`.

## Step 4 — Verify

Run enrichment to surface verification violations the new annotations
might trigger or resolve:

```bash
cargo run -q -p apianyware-macos-analyze -- enrich
jq '.verification' analysis/ir/enriched/{Framework}.json
```

A violation count that *drops* after the LLM pass is the headline
success signal. Annotation count alone is not enough — the merge could
produce annotations that disagree with reality.

## Re-running

The pipeline is idempotent at every step:

| To re-do … | Delete or pass `--only` … |
|---|---|
| One framework's LLM annotations | `rm analysis/ir/llm-annotations/{Framework}.llm.json` then re-dispatch its subagent |
| All LLM annotations | `rm -rf analysis/ir/llm-annotations/` then re-dispatch every subagent |
| Just the merge | `cargo run -q -p apianyware-macos-analyze -- annotate --llm-dir analysis/ir/llm-annotations` |

`.methods.json` summaries are derived from `analysis/ir/resolved/` and need
re-running only after the `resolve` step changes (i.e. SDK update or
collection logic change).

## Durability — `.llm.json` files are versioned

`analysis/ir/llm-annotations/*.llm.json` is **checked into the repo** (Option
A in the durability decision). Rationale, decided 2026-04-28 after the
EventKit calibration run:

- **Cost of regeneration is non-trivial.** Across the 154 frameworks with
  flagged methods (17,862 methods total), regenerating from scratch
  consumes millions of subagent tokens and a substantial wall-time budget.
- **Storage cost is trivial.** Each `.llm.json` is <5 KB; the full set is
  well under 1 MB of versioned JSON.
- **Co-evolution is clean.** Annotations are keyed to `(class, selector)`
  pairs, so SDK or extractor changes that rename or remove methods produce
  ordinary diffs rather than orphan data.
- **Fresh-clone workflow is fully offline.** A clone runs:
  `analyze llm-extract` (cheap, deterministic) → `analyze annotate --llm-dir
  analysis/ir/llm-annotations` (free, no LLM calls) → `analyze enrich`. No
  Claude Code session required to reproduce annotated IR.

Re-running a subagent is required only when (a) the framework's resolved
IR changed in a way that invalidates the existing annotations (renamed
selectors, new flagged methods), or (b) the subagent prompt is revised
and the existing annotations need to be re-derived.

Options not chosen:

- **(B) Versioning `analysis/ir/annotated/`** — the merged checkpoints
  are 100×–1000× larger than the `.llm.json` source files and contain
  redundant heuristic annotations that would conflict on every extractor
  change. The `.llm.json` files are the load-bearing source-of-truth;
  the annotated checkpoint is derived.
- **(C) Accepting ephemerality** — only viable if total regeneration cost
  is <$0.10. With ~14M tokens estimated for the full 154-framework run,
  this is decisively non-viable.

## Cost & wall-time tracking

After each real run, append a row to the table below so future runs can
budget against measured numbers, not guesses.

| Date | Framework(s) | Methods | Subagent tokens (total) | Wall time | Notes |
|---|---|---|---|---|---|
| 2026-04-27 | PushKit | 2 (1 annotated, 1 skipped) | 54,327 | ~2m 9s | First real subagent run. `setDelegate:` annotated `weak`; `delegate` getter deliberately skipped (no schema field applies to a property getter). WebFetch on `developer.apple.com` returned only `<title>`; subagent fell back to SDK header at `MacOSX.sdk/.../PushKit.framework/Headers/PKPushRegistry.h` and used the `weak` declaration there. `llm-validate` and `enrich` verification both passed. |
| 2026-04-28 | EventKit | 19 (17 annotated, 2 getters skipped) | 38,971 | ~73s | Calibration run for mixed annotation reasons (8 `has_block_params` + 9 `error_out_param` + 2 `delegate_observer_pattern`). 12 tool uses. All 8 block params classified (1 synchronous on `enumerateEventsMatchingPredicate:usingBlock:`, 7 async_copied for completion handlers and `request*Access*` permission prompts). All 9 `error_out_param` annotations emitted. 0 `parameter_ownership` and 0 `threading` annotations — no flagged methods take a delegate parameter, and headers don't carry explicit threading prose. **Heuristic vs LLM:** for EventKit, the heuristic pass already classifies block invocation styles and error patterns identically; the LLM pass was confirmatory rather than additive. **Prompt-clarity feedback:** explicitly state that classes with zero annotated methods should be omitted from `classes` (rather than emitted with empty `methods: []`). |
| 2026-04-28 | WebKit | 86 (72 annotated across 13 classes, 14 skipped — getters + 2 `WebDownload` inits where header didn't support `weak`) | 80,907 | ~3m | Naming-pattern-defeating calibration: 54 `has_block_params` + 26 `delegate_observer_pattern` + 6 `error_out_param`. 24 tool uses. **Marginal cost = (80,907 − 35,000) / 86 ≈ 534 tokens/method**, consistent with the prior ~500/method estimate from the 21-method data points. Foundation (546 methods) projects to ~35k + 546 × 534 ≈ 326k tokens. **LLM additive contribution (vs heuristic-only baseline on the 86 flagged methods):** **+63 `threading: main_thread_only` annotations** (heuristic: 0) sourced from class-level `WK_SWIFT_UI_ACTOR` decorations on all 13 `WK*` classes — heuristics had no way to read these; this is the headline LLM win. **+2 newly-annotated methods** (LLM annotated `WebView`'s legacy `assign`-pre-ARC delegate setters as `weak`, which heuristics missed because they don't look at `assign` attribute). Block invocation and error patterns: 0 LLM-vs-heuristic delta — heuristics already nail completion-handler and `NSError**` patterns. **Merge bug surfaced (independent of calibration):** `validate::merge_annotations` clones LLM `parameter_ownership` whole-list and never falls back to heuristic, so 52 heuristic ownership annotations on flagged methods were silently dropped (66 → 15). Block/threading/error fields use per-field fallback and don't have this issue. Worth fixing before Foundation. **Annotate code observation:** when run without `--llm-dir`, `annotate` re-uses the prior annotated checkpoint as fallback "LLM" source and re-tags every annotation as `source = Llm`, which makes a stale checkpoint look LLM-derived. Wipe `analysis/ir/annotated/{Framework}.json` before running heuristic-only baselines. **Decision: proceed to Foundation annotation** — 326k-token budget is acceptable, threading additive contribution justifies the spend on AppKit-adjacent frameworks, and the merge bug should be fixed first so heuristic ownership is preserved. |
