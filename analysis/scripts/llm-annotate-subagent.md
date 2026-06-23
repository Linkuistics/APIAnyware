# LLM Annotation Subagent Prompt

This file contains the prompt template that an orchestrator dispatches to a
Claude Code subagent (one subagent per framework). The subagent reads a
`.methods.json` summary, consults Apple documentation, writes a `.llm.json`
file, and validates it before returning.

For the orchestration loop that fans these subagents out, see
`llm-annotate-orchestration.md`.

## Subagent Prompt Template

Substitute `{FRAMEWORK}` with the target framework name (e.g. `Foundation`,
`AVFoundation`).

---

You are annotating macOS `{FRAMEWORK}` framework methods for a code generation
system. Your output drives how language emitters wrap blocks, error params,
delegates, and threading constraints in idiomatic per-language bindings.

## Input

Read the method summary at:

```
analysis/ir/llm-summaries/{FRAMEWORK}.methods.json
```

Each method has a `reasons` field naming why it was flagged
(`has_block_params`, `error_out_param`, `delegate_observer_pattern`).

## Annotations to produce

For each flagged method, decide as much as Apple's documentation supports.
Omit fields you cannot defend from documentation — partial annotation is
better than guessing.

1. **`block_parameters[]`** — for each block-typed param, set
   `param_index` (zero-based) and `invocation`:
   - `synchronous` — invoked during the call, NOT copied (caller frees)
   - `async_copied` — copied for later async invocation
   - `stored` — stored for repeated invocation (observers, handlers)

2. **`parameter_ownership[]`** — only for non-default ownership:
   - `weak` — receiver does NOT retain (delegates, data sources, targets)
   - `copy` — receiver copies the value
   - Omit `strong` — that's the default.

3. **`threading`** — only when documentation is explicit:
   - `main_thread_only` | `any_thread`

4. **`error_pattern`** — only when the method has an error out-param:
   - `error_out_param` — last param is `NSError**`, returns nil/NO on failure
   - `nil_on_failure` — returns nil on failure, no error param

## How to decide

Look up the framework headers at
`$SDKROOT/System/Library/Frameworks/{FRAMEWORK}.framework/Headers/`. They
are the authoritative source — they carry `weak`/`copy`/`assign`/`nullable`
attributes and `///` doc comments that the developer.apple.com web UI
strips. Use `WebFetch` on `developer.apple.com/documentation/` only as a
supplemental cross-check for prose/Discussion notes that may not appear in
the headers; the rendered web pages are JS-built SPAs and `WebFetch` often
returns only `<title>`, so do not rely on them as the primary source.

If neither headers nor documentation address a question, omit the field —
heuristics will fill the gap.

If a property getter and its corresponding setter are both flagged in the
summary, annotate the setter only and skip the getter — property getters
have no `parameter_ownership` or `block_parameters` surface (the setter
parameter is what carries the backing-storage reference type).

## Output

Write JSON to:

```
analysis/ir/llm-annotations/{FRAMEWORK}.llm.json
```

Schema (every field below is required where shown; the optional
arrays/objects may be omitted entirely if empty):

```json
{
  "framework": "{FRAMEWORK}",
  "classes": [
    {
      "class_name": "NSURLSession",
      "methods": [
        {
          "selector": "dataTaskWithURL:completionHandler:",
          "is_instance": true,
          "block_parameters": [
            {"param_index": 1, "invocation": "async_copied"}
          ],
          "threading": "any_thread",
          "source": "llm"
        }
      ]
    },
    {
      "class_name": "NSNotificationCenter",
      "methods": [
        {
          "selector": "addObserver:selector:name:object:",
          "is_instance": true,
          "parameter_ownership": [
            {"param_index": 0, "ownership": "weak"}
          ],
          "source": "llm"
        }
      ]
    }
  ]
}
```

Hard rules — the validator (next step) will reject violations:

- `framework` must equal `{FRAMEWORK}`.
- Every `class_name` must appear in the `.methods.json` summary.
- Every `selector` must appear under that class in the summary.
- `is_instance` must match the summary's value.
- `param_index` must be in `[0, params.len())`.
- `block_parameters[].param_index` must point at a param whose `type_kind`
  is `"block"`.
- `source` must be `"llm"` for every annotation.
- Skip methods you have no annotations for — do not emit empty
  `MethodAnnotation` shells.
- Skip classes whose methods all fall under the previous rule — omit
  the class from `classes` entirely rather than emitting it with an
  empty `methods: []` array.

## Self-report (recommended)

After writing all `classes`, append a `subagent_report` block to the
top-level object recording your aggregate counts. The validator
cross-checks these against the actual file content and emits a warning
on divergence — this catches cases where the narrative count you
report back disagrees with what you actually wrote (a real incident on
the CoreData run).

Include only the categories you tracked. Omit fields you did not count
— `null` and missing both mean "not tracked", and the validator will
silently skip them. `0` means "tracked, found none" and *is* checked.

```json
{
  "framework": "{FRAMEWORK}",
  "classes": [...],
  "subagent_report": {
    "block_synchronous": 4,
    "block_async_copied": 15,
    "block_stored": 11,
    "parameter_ownership": 5,
    "threading_main_thread_only": 0,
    "threading_any_thread": 0,
    "error_pattern": 58
  }
}
```

## Validate before returning

After writing the file, run:

```bash
cargo run -q -p apianyware-analyze -- llm-validate \
  --methods-file analysis/ir/llm-summaries/{FRAMEWORK}.methods.json \
  --llm-file    analysis/ir/llm-annotations/{FRAMEWORK}.llm.json
```

If it exits non-zero, fix the reported errors and re-run until it exits
zero. Do not return until validation passes.

Report back:
- path to the `.llm.json` you wrote
- count of annotated classes and methods
- any methods you deliberately left unannotated and why
- the same per-category counts you wrote into `subagent_report` (so the
  orchestrator can spot any drift between the narrative summary and the
  block before re-running `jq` to confirm — though `llm-validate` will
  also flag this as a warning)
