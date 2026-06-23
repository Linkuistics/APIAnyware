---
description: Run LLM analysis on all frameworks that have resolved IR. Discovers frameworks automatically.
---

# Analyze All Frameworks

Discover all frameworks with resolved IR and produce semantic annotations for each.

## Process

1. List all `*.json` files in `analysis/ir/resolved/` to find available frameworks
2. For each framework, check if `analysis/ir/annotated/{Framework}.json` already has LLM annotations (check for non-empty `class_annotations` with `source: "llm"` entries)
3. For frameworks needing analysis, follow the per-framework process below
4. After all frameworks are processed, run the heuristic merge to re-merge

## Per-Framework Analysis

For each framework:

1. Read `analysis/ir/resolved/{Framework}.json` to get the class/method list
2. Identify methods needing LLM analysis: those with block parameters, delegate/weak patterns, error out-params, or ambiguous threading constraints
3. For those classes, fetch Apple documentation via WebFetch at `https://developer.apple.com/documentation/{framework}/{classname}` (lowercase)
4. Also consult Apple programming guides for pattern recognition (e.g., "Key-Value Observing Programming Guide", "Cocoa Drawing Guide")
5. Analyze each method's documentation to classify:
   - **block_invocation**: `synchronous` / `async_copied` / `stored`
   - **parameter_ownership**: `weak` / `copy` / `strong` (only annotate non-strong)
   - **threading**: `main_thread_only` / `any_thread` (only if determinable)
   - **error_pattern**: `error_out_param` / `nil_on_failure`
6. Write LLM annotations as a temporary `FrameworkAnnotations` JSON

## Output Format (Temporary LLM Annotations)

Write a temporary file at `analysis/ir/annotated/{Framework}.llm.json`:

```json
{
  "framework": "Foundation",
  "classes": [
    {
      "class_name": "NSArray",
      "methods": [
        {
          "selector": "enumerateObjectsUsingBlock:",
          "is_instance": true,
          "block_parameters": [{"param_index": 0, "invocation": "synchronous"}],
          "source": "llm"
        }
      ]
    }
  ]
}
```

Sort classes and methods alphabetically. Only include methods with interesting annotations. Set `source` to `"llm"`.

## After Analysis

Run the heuristic merge to combine heuristic + LLM annotations into the annotated checkpoint:
```bash
cargo run -p apianyware-analyze -- annotate
```

This reads `analysis/ir/resolved/`, runs heuristics on all methods, merges with any existing LLM annotations in `analysis/ir/annotated/`, and writes the final annotated checkpoint.

## Schema Reference

See `analysis/scripts/prompt-template.md` for the complete annotation schema and classification guidance.
