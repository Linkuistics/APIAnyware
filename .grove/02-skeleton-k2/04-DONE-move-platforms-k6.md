# move-platforms-k6

**Kind:** work

## Goal

`git mv` the platform-level producer crates into `platforms/macos/tools/`, and
relocate the LLM-annotation data + scripts to their platform home:

```text
collection/crates/extract-objc   → platforms/macos/tools/extract-objc
collection/crates/extract-swift  → platforms/macos/tools/extract-swift
analysis/crates/annotate         → platforms/macos/tools/annotate
collection/crates/cli            → platforms/macos/tools/collect-cli  (bin apianyware-collect)
analysis/ir/llm-annotations/     → platforms/macos/<annotation home>  (see note)
analysis/scripts/                → platforms/macos/<annotation home>/scripts (co-locate w/ annotate)
```

Update root `Cargo.toml` `members` + dep paths for the four crates. Fix path strings:
the extractors' synthetic-frameworks + test fixtures, annotate's annotation-dir
references, collect-cli output paths, and the annotation scripts
(`check-llm-annotation-drift.sh`, `audit-llm-redundancy.py`,
`regenerate-stale-pipeline.sh`, `config.example.toml`).

## Context

See node brief — SC2 (annotate co-locates with extractors as platform-level
producers; output lands under `platforms/macos/api/<f>/`), SC3 (`collect`-cli →
platforms). Names renamed (k4); semantic crates already moved (k5).

## Done when

The four crates + annotation data/scripts live under `platforms/macos/`; `cargo build`
green; the annotation-drift check (`check-llm-annotation-drift.sh --skip-regen`) runs
from its new home; committed as `move-platforms-k6`. After this, `collection/` is
empty (remove in k10).

## Notes

LLM-annotation home: §14 puts per-family `annotations.apiw` under
`platforms/macos/api/<family>/`, but those are the *future DSL* form (workstream 5).
For the skeleton, relocate the existing `*.llm.json` as-is to a single
`platforms/macos/api/_llm-annotations/` (or similar) staging dir with a `TODO:`
pointing at workstream 5's per-family/`.apiw` reshape — do **not** restructure the
data (SC6). Mind `gerbil gcc-15` drift if any build step shells out.
