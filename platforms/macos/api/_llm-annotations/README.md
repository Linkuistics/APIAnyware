# platforms/macos/api/_llm-annotations/ — LLM annotation staging (transitional)

The git-tracked per-framework LLM annotation side-channel (`<Framework>.llm.json`),
relocated here from `analysis/ir/llm-annotations/` by `move-platforms-k6` **as-is**
(skeleton SC6 — relocate, do not restructure). These are the reviewable LLM-derived
semantic annotations (threading, parameter ownership, block/error patterns) that
`apianyware-analyze annotate --llm-dir …` merges with heuristics; regenerating them
from scratch costs millions of tokens, so they are versioned in git.

The leading `_` marks this as a staging directory that is **not** an API family — it
sits beside the real `<Family>/` directories without colliding with them.

TODO (workstream 5 — LLM analysis side-channel): reshape this flat `*.llm.json` set
into the per-family `annotations.apiw` DSL form under each `api/<Family>/` (REFACTOR.md
§14), with caching / regeneration / diffability / provenance / confidence and
fact-precedence rules. The operational machinery that produces and validates these
files lives at `platforms/macos/tools/scripts/` (alongside the `annotate` crate).
