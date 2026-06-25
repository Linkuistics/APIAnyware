# retire-tooling-k49

**Kind:** work

## Goal

The **last** ws5 child (node BRIEF decomposition #6, ADR-0050 §5 / D6): retire the
dead bash/python/external-API scaffolding the side-channel rework left behind, and
rework the Makefile `lint-annotations` target onto the typed `apianyware-analyze
annotations` subcommands (k46/k47). k48 reworked the **live** surface; this child
removes whatever is now dead and re-points the one build target that still calls it.

## Context (see node `BRIEF.md` #6 + ADR-0050 §5 + `CONTEXT.md` "Side-channel workflow")

- **The two analysis scripts already became Rust subcommands** — `annotations stale`
  (k46) replaced `check-llm-annotation-drift.sh`; `annotations audit` (k47) replaced
  `audit-llm-redundancy.py`. The orchestration moved into `.claude/commands/analyze.md`
  + `platforms/macos/docs/annotation-{workflow,subagent-prompt}.md` (k48). So every
  file below is now **unreferenced by any live artifact** — this child deletes them,
  it does not port them.
- **Dead scaffolding to delete** (all under `platforms/macos/tools/scripts/`):
  - `check-llm-annotation-drift.sh` (→ `annotations stale`)
  - `audit-llm-redundancy.py` (→ `annotations audit`)
  - `regenerate-stale-pipeline.sh` (→ the `/analyze` orchestration loop)
  - `llm-annotate.sh` + `config.example.toml` (the dead external-provider flow —
    economic constraint: annotation runs in Claude-Code subagents, [[llm_annotation_constraint]])
  - `llm-annotate-orchestration.md` (→ `.claude/commands/analyze.md`)
  - `prompt-template.md` (→ `platforms/macos/docs/annotation-subagent-prompt.md`)
  - k48 already rehomed `llm-annotate-subagent.md` out of `scripts/`, so after these
    deletes the `scripts/` directory is **empty → remove it**.
- **Makefile `lint-annotations`** currently shells the two deleted scripts (and a
  stale `apianyware-analyze -- annotate --llm-dir` invocation that no longer exists).
  Rework it to gate on the real subcommands: `cargo run -p apianyware-analyze --
  annotations stale` (exit 1 iff any family stale → it gates CI/Make) and, optionally,
  an informational `annotations audit` (always exit 0). Name real flags ([[cli-tool-design]]).
- **Resync the trackers:** `TODO.md`'s ws5 tooling row (the superseded-banner file
  list) is discharged by this child — update it. Leave purely-historical "replaces
  `check-llm-annotation-drift.sh`" mentions in `CONTEXT.md`/ADR-0050 as history.

## Done when

- Every file listed above is deleted (`git rm`); `platforms/macos/tools/scripts/` no
  longer exists.
- `Makefile` `lint-annotations` runs `apianyware-analyze annotations stale` (gating)
  + optionally `annotations audit`; no reference to the deleted scripts or the dead
  `annotate --llm-dir` form. `make lint-annotations` runs clean (or fails *only* on a
  genuinely-stale family, which is the gate working).
- No live file references any deleted path (grep clean across the repo, excluding
  `.grove/` and git history).
- `TODO.md` ws5 row reflects the tooling retirement.
- Golden-neutral: no Rust/pipeline change (`annotations {stale,audit}` already exist);
  `resolve` byte-identical; emit goldens green.
- Committed in one focused commit named by the `retire-tooling-k49` handle.

## Notes

- **This is the last ws5 leaf.** On retire, the node `06-llm-side-channel-k43` has no
  live leaf → the retire-cascade **asks the user before treating workstream 5 done**.
  On confirmation: promote the durable ws5 seams from the node BRIEF upward to the root
  BRIEF ("LLM analysis side-channel" decomposition #5 → an outcomes section), then the
  root BRIEF's **ws6** (target model, decomposition #6 — `targets/<t>/`: capability
  profiles, idiom catalogues, adapter specs, bindings, conformance) grows next.
- Sanity-check before deleting each script that nothing *outside* the known set (a CI
  workflow, a git hook, another Makefile target) invokes it.
