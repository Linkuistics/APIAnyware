# orchestration-skill-k48

**Kind:** work

## Goal

Rework the **live LLM-annotation workflow surface over `.apiw`** (node BRIEF decomposition
#5): the `analyze` command/skill, the per-family **subagent prompt**, and the canonical
`platforms/macos/docs/annotation-workflow.md`. Wire the regeneration loop end-to-end —
`annotations stale` worklist → per-family **Claude-Code subagent** dispatch → each writes its
`annotations.apiw` **directly** → `resolve` → `annotations audit` review → `git` accept —
honouring the economic constraint. This is the **`regenerable`** adjective made operational.

## Context (see node `BRIEF.md` + ADR-0050 §5 / D6 + `CONTEXT.md` "Side-channel workflow")

- **k48 is an operator-playbook rework, not new Rust.** The two subcommands the workflow now
  drives already exist: `annotations stale` (k46) produces the worklist; `annotations audit`
  (k47) reports disagreements + per-tier win distribution for review. k48 ties them together in
  markdown (command + skill + subagent prompt + doc) — no new crate, no resolve/emit change.
- **Three live artifacts to rework** — all currently carry a `superseded → ws5` banner
  describing the dead `analysis/ir/{resolved,annotated,enriched}/*.json` + `.llm.json`
  side-channel:
  - `.claude/commands/analyze.md` — the `analyze` command/skill.
  - `platforms/macos/docs/annotation-workflow.md` — the canonical doc (its rewrite is the
    `doc-resync` TODO the platform-model node flagged).
  - `platforms/macos/tools/scripts/llm-annotate-subagent.md` — the per-family subagent prompt
    (decide whether to rework in place or rehome under `platforms/macos/`).
- **The new flow** (post-SDK-bump order): `collect` → `resolve` → `annotations stale` (worklist
  of drifted families) → dispatch one subagent **per stale family** (reads that family's
  **resolved surface** + Apple docs, classifies the four fact kinds, writes `annotations.apiw`
  with `source llm` + optional `confidence`/`provenance`) → `resolve` → `annotations audit` to
  review disagreements → **`git diff` + commit = accept** (ADR-0050 D2: git is the accept
  boundary; no staging store).
- **Economic constraint** ([[llm_annotation_constraint]]): dispatch is **Claude-Code
  subagents** — the orchestration-skill itself fans out per framework — never the dead
  external-provider flow (`config.example.toml`/`llm-annotate.sh`). `annotate` runs once per SDK
  update, so keep the playbook lean.
- **Two source vocab, annotatable shape.** Subagents author `source llm` only; `manual` is a
  human hand-edit (overlay = `{llm, manual}`, ADR-0050 D3). Target the subagent at the
  **structural** annotatable predicate (block param or `NSError **` out-param —
  `apianyware_annotate::surface`), the same shape `stale`'s new-surface uses; the legacy
  `delegate`/`observer` selector-substring signal is excluded as noise (k46 finding).

## Done when

- `.claude/commands/analyze.md` describes the `.apiw` regeneration loop (stale → subagent
  dispatch → write `.apiw` → resolve → audit → git-accept), naming the real subcommands/flags
  ([[cli-tool-design]]); the superseded banner is gone; no path-drift to retired `analysis/ir/*`.
- `annotation-workflow.md` reworked over `.apiw`: new pipeline diagram (mermaid, not ASCII —
  [[no_ascii_diagrams]]: `extracted.json` → in-process `linked`→annotate→enrich → `resolved.json`),
  the `stale`/`audit` subcommands, git-as-accept, the once-per-SDK-update cadence; banner gone.
- The subagent prompt reworked to: read a stale family's resolved surface + Apple docs, classify
  the four fact kinds, and **write `annotations.apiw` directly** with `source llm` +
  confidence/provenance, scoped to the structural annotatable shape.
- **Golden-neutral / no pipeline change:** docs + prompt only (plus, at most, minimal Rust glue
  if a genuine gap surfaces — the `stale --json` worklist a skill consumes already exists).
  `resolve` byte-identical; emit goldens green; `cargo build --workspace` clean if any Rust
  touched.
- Committed in one focused commit named by the `orchestration-skill-k48` handle.

## Notes

- **Retire nothing here.** Deleting the dead scaffolding (`check-llm-annotation-drift.sh`,
  `audit-llm-redundancy.py`, `llm-annotate.sh`, `config.example.toml`,
  `llm-annotate-orchestration.md`, `prompt-template.md`, `regenerate-stale-pipeline.sh`) **and**
  the Makefile `lint-annotations` rework are the **`retire-tooling`** child's job (ws5 #6, last).
  k48 reworks the **live** surface; #6 removes whatever the rework leaves dead (e.g. the old
  `prompt-template.md` / `llm-annotate-orchestration.md` if the subagent prompt rehomes).
- The `stale` sibling reads the resolved surface vs the overlay; `audit` reads the resolved-only
  `fact_provenance` — both are *inputs the skill orchestrates*, not things k48 reimplements.
- On retire, grow the last frontier child `retire-tooling` (node BRIEF sequence #6). After that
  retires, the node has no live leaf → the retire-cascade asks before treating **workstream 5**
  done (promote seams upward; ws6 grows next).
