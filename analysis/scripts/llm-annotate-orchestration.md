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

## Cost & wall-time tracking

After each real run, append a row to the table below so future runs can
budget against measured numbers, not guesses.

| Date | Framework(s) | Methods | Subagent tokens (total) | Wall time | Notes |
|---|---|---|---|---|---|
| 2026-04-27 | PushKit | 2 (1 annotated, 1 skipped) | 54,327 | ~2m 9s | First real subagent run. `setDelegate:` annotated `weak`; `delegate` getter deliberately skipped (no schema field applies to a property getter). WebFetch on `developer.apple.com` returned only `<title>`; subagent fell back to SDK header at `MacOSX.sdk/.../PushKit.framework/Headers/PKPushRegistry.h` and used the `weak` declaration there. `llm-validate` and `enrich` verification both passed. |
