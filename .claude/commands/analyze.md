---
description: Regenerate stale LLM annotation overlays (.apiw) for drifted framework families, in Claude Code subagents.
---

# Analyze — regenerate stale annotation overlays

Drive the LLM analysis side-channel (ADR-0050): find framework families whose
authored `annotations.apiw` overlay has drifted from the current resolved API
surface, dispatch one Claude Code subagent per stale family to re-author its
overlay, then re-resolve and review. This is the `regenerable` adjective made
operational — the loop runs **inside Claude Code**, never an external paid API
([[llm_annotation_constraint]]).

`annotate` runs **once per SDK update**, so keep the run lean: only stale
families need a subagent. The canonical reference is
[`platforms/macos/docs/annotation-workflow.md`](../../platforms/macos/docs/annotation-workflow.md).

## Precondition

`resolved.json` must be current (the staleness check reads it). After an SDK bump
or extraction change, run collect + resolve first:

```bash
cargo run -p apianyware-collect          # refresh extracted.json (optionally --only <F>)
cargo run -p apianyware-analyze          # resolve → resolved.json (the comparison surface)
```

## Process

1. **Find the stale families** — the regeneration worklist:

   ```bash
   cargo run -q -p apianyware-analyze -- annotations stale --json
   ```

   The `worklist` array names the families needing regeneration; each family
   record lists its `orphaned` / `new-surface` / `shape-changed` slots. If the
   worklist is empty, every overlay is current — stop, there is nothing to do.

2. **Dispatch one subagent per stale family.** Fan them out concurrently. Give
   each subagent the prompt at
   [`platforms/macos/docs/annotation-subagent-prompt.md`](../../platforms/macos/docs/annotation-subagent-prompt.md)
   with `{FRAMEWORK}` substituted, and hand it that family's stale slots. Each
   subagent reads `platforms/macos/api/<Framework>/resolved.json` + Apple
   headers/docs, classifies the four fact kinds (block invocation, parameter
   ownership, threading, error pattern) over the **structural annotatable shape**
   (a block param or an `NSError **` out-param — the `delegate`/`observer`
   selector-substring signal is excluded as noise), and writes
   `platforms/macos/api/<Framework>/annotations.apiw` **directly** with
   `source llm` (+ optional `confidence` / `provenance`). The subagent validates
   its own output by re-resolving + re-running `stale --only <Framework>`.

3. **Re-resolve** with the regenerated overlays:

   ```bash
   cargo run -p apianyware-analyze
   ```

4. **Review the disagreement audit** — the high-value review targets before you
   accept:

   ```bash
   cargo run -q -p apianyware-analyze -- annotations audit            # all families
   cargo run -q -p apianyware-analyze -- annotations audit --only Foundation --json
   ```

   It reports, per family, fact-slots where the LLM winner superseded a
   *disagreeing* lower tier, the per-§28-tier win distribution, and the
   carriage-faithful redundancy signals (`convention-won` / `uncontested-llm`).

5. **Confirm coverage** — no family should remain stale (beyond methods
   deliberately left unannotated):

   ```bash
   cargo run -q -p apianyware-analyze -- annotations stale
   ```

6. **Accept by committing.** Git is the propose → review → accept boundary
   (ADR-0050): a committed `source llm` fact *is* `accepted-LLM`. Review the diff
   and commit (accept) or discard (reject):

   ```bash
   git diff platforms/macos/api      # the review surface (the overlay is the only committed artifact)
   git add -p && git commit
   ```

## Notes

- **No staging store, no propose/accept flag** — the working tree holds proposals,
  a commit is acceptance. `extracted.json` / `resolved.json` are gitignored; only
  `annotations.apiw` is committed.
- **Two source vocabularies:** the overlay carries `{llm, manual}`; the full
  ladder (`extraction` / `convention:<rule>` / `llm` / `manual` / `unknown`, with
  `superseded-by` losers) lives only in the derived `resolved.json` provenance.
- **Provenance is emit-invisible** — the audit stamps `source`, never the winning
  value, so regenerating annotations cannot move the emit goldens.
