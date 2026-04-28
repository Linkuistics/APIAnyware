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
| 2026-04-28 | WebKit (refresh) | 86 (re-merged with existing `WebKit.llm.json`) | 0 (no LLM calls — merge-only re-run) | ~10s | Refresh after `parameter_ownership` merge-clobber fix landed. Deleted stale `analysis/ir/annotated/WebKit.json` (had 15 ownership entries from buggy clone-clobber merge), re-ran `annotate --only WebKit --llm-dir analysis/ir/llm-annotations/`. **Result: 67 ownership entries** — exactly the post-fix calibration figure and ≥66 acceptance threshold. `enrich --only WebKit` verification passed; downstream relations unchanged (sync=1, async=51, stored=2, error=6, main_thread_classes=13). Confirms the merge fix is empirically sound on a real-world checkpoint with both heuristic and LLM input. |
| 2026-04-28 | Foundation | 546 (483 annotated across 121 classes, 63 skipped — paired getters + 24 delegate setters/inits where header documents the delegate as retained, e.g. `NSURLSession.setDelegate:`, `NSXPCConnection.setDelegate:`, `URLSession.{bytes,data,download,upload}(_:delegate:)`) | 131,228 | ~7m 35s | First full-scale (post-calibration) run, dispatched as a single subagent. **Cost came in 60% under the 326,564-token projection** — driver was the subagent's choice to build the output JSON in a single Python pass after establishing per-pattern rules from a sample of headers, rather than per-method `WebFetch`/header lookups. 52 tool uses. **Heuristic-only baseline:** 293 ownership / 250 block / 0 threading / 204 error_pattern. **Post-merge (heuristic + LLM):** 302 ownership / 250 block / 0 threading / 204 error_pattern. **LLM additive contribution: +9 `parameter_ownership` annotations** (KVO `addObserver:forKeyPath:options:context:` observer params + `NSNotificationCenter addObserver:` family observer params — heuristics didn't classify these as weak because the methods aren't named `setDelegate:`/`setDataSource:`). **Block-invocation breakdown** (250 entries): 120 synchronous (NS_NOESCAPE enumerations, comparators, file-coordinator accessors), 83 async_copied (completion handlers, run-loop / op-queue scheduled blocks), 47 stored (timer blocks, op completion blocks, `setReadabilityHandler:`, XPC interruption/invalidation handlers, `NSPredicate predicateWithBlock:`, sort-descriptor comparators, item-provider register-handlers). 0 threading annotations — Foundation has no class-wide `NS_SWIFT_UI_ACTOR` markers; thread-flexibility is the documented norm. Block invocation and error patterns: 0 LLM-vs-heuristic delta — heuristics already classify Foundation's pervasive completion-handler / `:error:` patterns identically. **Notable subagent decisions:** treated `NSSortDescriptor` comparator block as `stored` (descriptor caches the block until later application) rather than synchronous; treated `NSXPCConnection.{remoteObjectProxyWithErrorHandler:, …}` error handlers as `stored` on the returned proxy. **Verification:** `llm-validate` passed first run; `enrich` verification passed; sync(120)+async(83)+stored(47)=250 = block_parameters count, round-trips correctly. **Implication for downstream Racket binding generation:** the +9 KVO/notification-observer weak annotations matter for delegate-pattern code-gen on observer registrations; otherwise heuristics are doing the heavy lifting on Foundation. The 326k projection methodology over-estimated by ~60% for this run; future budget projections should use 35k + N × ~250 tokens/method as a refined estimate (vs. the 534/method WebKit calibration figure). |
| 2026-04-28 | AppKit | 524 (437 annotated across 138 classes, 87 skipped — 78 paired getters + 9 modal-completion-callback selectors where Apple headers carry no explicit retention attribute on the modal-callback target) | 119,969 | ~10m 51s | Single-subagent run, came in **28% under the 35k + 524×250 = 166k projection**. 101 tool uses. **Heuristic-only baseline:** 367 ownership / 189 block-methods (14 sync + 184 async + 0 stored = 198 invocation entries) / 15605 threading=main_thread_only / 73 error_pattern. **Post-merge (heuristic + LLM):** 368 ownership / 189 block-methods (36 sync + 137 async + 25 stored = 198 invocation entries) / 15883 threading (15875 main + 8 any_thread) / 73 error_pattern. **LLM additive contribution:** **(1) +278 `threading` annotations** (heuristic: 15605 → merged: 15883) — net of LLM expanding main_thread coverage on additional documented main-thread classes plus 8 `any_thread` overrides on documented thread-safe APIs (NSImage 10.6+, NSSpellChecker). Smaller threading delta than the WebKit-calibrated expectation because heuristics now propagate class-level `NS_SWIFT_UI_ACTOR` to methods, so the LLM is supplementing rather than discovering. **(2) Block-invocation re-classification on the same 189 methods:** heuristics had 0 `stored`; LLM identified **25 `stored` handlers** (`setHandler:`, NSCollectionViewDiffableDataSource section/supplementary providers, NSEvent global/local monitor handlers, NSStoryboard `creator:` cache, NSSliderAccessoryBehavior, NSWritingToolsCoordinatorAnimationParameters, etc.) and **demoted 47 async → 22 sync + 25 stored** (NS_NOESCAPE-verified `enumerate*UsingBlock:`, `withBlock:`, `usingBlock:`, NSDocument `continueActivityUsingBlock:`/`performAsynchronousFileAccessUsingBlock:`/`relinquishPresentedItemTo*:`, NSAnimationContext `changes:`, NSEvent `trackSwipeEvent...:`). **(3) Ownership virtually unchanged (+1 method)** — heuristics already cover the `setDelegate:`/`setDataSource:` naming patterns AppKit overwhelmingly uses; LLM added a single header-verified weak init (`NSWritingToolsCoordinator initWithDelegate:` family). **Notable subagent decisions:** declined to assert weak on 9 legacy modal-callback selectors (`commitEditingWithDelegate:didCommitSelector:contextInfo:`, `runOperationModalForWindow:delegate:didRunSelector:contextInfo:`) because Apple headers carry no explicit retention attribute on the modal-callback target; left to heuristics. **Verification:** `llm-validate` passed first run; `enrich --only AppKit` verification passed (0 violations); enrich totals went sync 14→36, async 184→137, stored 0→**25**, main_thread_classes 73→142, error_methods 73 (unchanged). **Implication for downstream Racket binding generation:** the 25 `stored` block annotations are the most consequential — `stored` blocks need GC-prevention pinning that `async_copied` blocks don't, so any AppKit binding emitter that previously labeled `setHandler:`-family setters as `async_copied` would have under-pinned them. Threading delta improves per-class main-thread enforcement coverage from 73 → 142 classes. **Refined budget rule:** the 35k + N × 250 model held — AppKit's 119,969 actual vs 166k projected = 28% under, similar magnitude to Foundation's 60% under. |
| 2026-04-28 | CoreData | 90 (89 annotated across 20 classes, 1 skipped — `NSFetchedResultsController.delegate` getter under the property-getter skip rule) | 71,384 | ~3m 29s | Single-subagent run, came in **22% over the 35k + 90×250 = 57.5k projection** (a small absolute miss on a small framework — 27 tool uses dominated by per-class header inspection rather than batched Python-style synthesis). **Heuristic-only baseline:** 31 ownership / 30 block-methods (0 sync + 30 async + 0 stored) / 0 threading / 58 error_pattern. **Post-merge (heuristic + LLM):** 31 ownership / 30 block-methods (4 sync + 15 async + 11 stored) / 0 threading / 58 error_pattern. **LLM additive contribution:** **Block-invocation re-classification is the headline.** Heuristics put all 30 blocks into `async_copied`; LLM split them into 4 `synchronous` (`performBlockAndWait:` / `performAndWait(_:)` on `NSManagedObjectContext` and `NSPersistentStoreCoordinator` — `NS_NOESCAPE` confirmed in headers), 15 `async_copied` (`performBlock:` / `perform(_:)` / `performBackgroundTask*` / `loadPersistentStores…CompletionHandler:` / `addPersistentStoreWithDescription:completionHandler:` / the three `NSCoreDataCoreSpotlightDelegate` completion handlers), and 11 `stored` (NSBatchInsertRequest `dictionaryHandler` / `managedObjectHandler` factories+setters — invoked once per generated row until returning `YES`; NSCustomMigrationStage `set{Will,Did}MigrateHandler:`; NSFetchRequestExpression `expressionForBlock:arguments:`). **Ownership unchanged (+0 net new)** — the 5 LLM ownership entries (`NSFetchedResultsController.setDelegate:` weak; NSBatchInsertRequest+NSCustomMigrationStage handler setters as `copy`) all overlapped with heuristic ownership coverage; merge bug fix held — heuristic count of 31 was preserved end-to-end. **Threading: 0 annotations** — correct for CoreData's queue-flexibility model (per-context queue binding is implicit in `performBlock:` semantics, not a per-method `main_thread_only` constraint); this is the right answer, not a gap. **Notable subagent decisions:** classed `NSAsynchronousFetchRequest.initWithFetchRequest:completionBlock:` as `async_copied` (fires exactly once when async fetch finishes) rather than `stored`, even though the property is `(strong, readonly)`; classed `NSBatchInsertRequest` row-handlers as `stored` (called repeatedly per row until returning `YES`) rather than `async_copied`. **Verification:** `llm-validate` passed first run; `enrich --only CoreData` verification passed (0 violations); enrich totals: sync=4, async=15, stored=11, error_methods=58, main_thread_classes=0, scoped_resources=3, iterables=2. **Implication for downstream Racket binding generation:** the 11 `stored` block annotations on NSBatchInsertRequest / NSCustomMigrationStage handlers are the consequential codegen signal — these need GC-prevention pinning that `async_copied` blocks don't. Heuristics treating all CoreData blocks as `async_copied` would have under-pinned the batch-insert handlers, leading to GC-collection of in-flight per-row callbacks under load. **Subagent self-reporting note:** subagent's report claimed `async_copied: 18 / stored: 8 / ownership: 7`, but the actual `.llm.json` written contains `15 / 11 / 5`. The validator is the source of truth (it passed both counts internally), but future runs should cross-check the report against `jq` of the file before recording in this table. |
| 2026-04-28 | AVFoundation | 266 (198 annotated across 68 classes, 68 skipped — paired getters + 9 capture-delegate setters where headers don't carry an explicit `weak` attribute, plus a handful of recording/photo-capture delegates that headers document as retained-for-duration rather than weak) | 93,699 | ~4m 43s | Single-subagent run, came in **8% under the 35k + 266×250 = 101.5k projection**. 35 tool uses. **First run after the `subagent_report` reconciliation check landed — written counts and file aggregates matched exactly across all seven categories on the first write; `llm-validate` reported `warnings=0`**, validating the new tooling on a real run. **Heuristic-only baseline:** 162 ownership / 122 block-methods (0 sync + 118 async_copied + 6 stored) / 12 threading=main_thread_only / 58 error_pattern. **Post-merge (heuristic + LLM):** 162 ownership / 122 block-methods (0 sync + 103 async_copied + 21 stored) / 12 threading / 58 error_pattern. **LLM additive contribution:** the headline is **+15 `stored` block reclassifications** (heuristic: 6 → merged: 21) — long-lived AVPlayer time observers (`addPeriodicTimeObserverForInterval:queue:usingBlock:`, `addBoundaryTimeObserverForTimes:queue:usingBlock:`), `requestMediaDataWhenReadyOnQueue:usingBlock:`-style pull-callback handlers, `videoCompositionWithAsset:applyingCIFiltersWithHandler:`'s per-frame applier block (with the companion completion variant correctly split into block 1 = `stored` applier + block 2 = `async_copied` one-shot), and capture slider/picker action blocks. Ownership: 18 LLM ownership entries all overlapped with heuristic coverage — net +0. Threading: **0 net additions** — subagent intentionally declined to claim `main_thread_only` on `NS_SWIFT_UI_ACTOR` classes (`AVPlayer`, `AVPlayerItem`, `AVSynchronizedLayer`, `AVPlayerItemTrack`) because the flagged async/observer methods on those classes are `NS_SWIFT_NONISOLATED` in headers and explicitly contradict a blanket main-thread claim; this is a correctness call, not a gap. **Hypothesis check:** prior expectation was that AVFoundation would have the highest `stored` count of any framework so far; result was **21 stored, third behind Foundation (47) and AppKit (25)**, so the hypothesis is directionally right (AVFoundation is in the high-stored cohort) but Foundation's NSPredicate/NSXPC/NSTimer breadth keeps it ahead. **Verification:** `llm-validate` passed first run with `warnings=0`; `enrich --only AVFoundation` verification passed (0 violations); enrich totals: sync_blocks=0, async_blocks=102, stored_blocks=21, main_thread_classes=4, error_methods=57, iterables=0, scoped_resources=0. **Subagent left a one-off Python helper** (`scripts/avfoundation_annotate.py`) that encoded the per-selector classification rules; deleted post-run because the `.llm.json` is the durable artifact (per Option A in the durability decision). **Implication for downstream Racket binding generation:** the 15 newly-classified `stored` blocks (time observers, pull-callbacks, per-frame appliers) need GC-prevention pinning that `async_copied` blocks don't — emitters that previously labeled `addPeriodicTimeObserverForInterval:` callbacks as `async_copied` would have under-pinned them, causing intermittent observer disappearance under GC pressure. **Refined budget rule continues to hold:** 35k + N × 250 came in 8% under for AVFoundation (similar magnitude to Foundation's 60% under and AppKit's 28% under). |
