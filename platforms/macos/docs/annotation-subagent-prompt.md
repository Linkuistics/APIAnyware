# LLM Annotation Subagent Prompt

This is the prompt the `/analyze` orchestration skill dispatches to a Claude Code
subagent — **one subagent per stale framework family**. The subagent reads the
family's *resolved surface* + the stale worklist, classifies the annotatable
methods against Apple's headers/docs, and writes the family's authored overlay
`platforms/macos/api/<Framework>/annotations.apiw` **directly** (KDL — the `.apiw`
DSL), then validates it. For the loop that fans these out, see
[`annotation-workflow.md`](annotation-workflow.md) and
`.claude/commands/analyze.md`.

## Subagent prompt template

Substitute `{FRAMEWORK}` with the target family name (e.g. `Foundation`,
`AVFoundation`).

---

You are annotating macOS `{FRAMEWORK}` framework methods for a code-generation
system. Your output drives how language emitters wrap blocks, error params, and
threading constraints into idiomatic per-language bindings. You author the
committed semantic overlay `platforms/macos/api/{FRAMEWORK}/annotations.apiw`.

## Inputs

1. **The stale worklist** for this family (handed to you by the orchestrator, or
   regenerate it yourself):

   ```bash
   cargo run -q -p apianyware-analyze -- annotations stale --only {FRAMEWORK} --json
   ```

   Three signal lists tell you exactly what to change — **only address these**;
   leave every other existing fact untouched (the economic constraint: `annotate`
   runs once per SDK update, so do not re-derive the whole family):
   - **orphaned** — delete this fact from the overlay (the method is gone).
   - **new-surface** — add a fact for this method (`detail` is `"block"` or
     `"error"`, the structural reason).
   - **shape-changed** — the targeted `param_index` moved; fix it or re-evaluate.

2. **The resolved surface** — full method signatures, inheritance-flattened and
   Swift-renamed (this is the surface the overlay is keyed against):

   ```
   platforms/macos/api/{FRAMEWORK}/resolved.json
   ```

   Each class's `all_methods` carries the cross-framework closure; key a fact
   under the receiver name (class/protocol) the method resolves on.

3. **The existing overlay** (if present) — apply your deltas on top of it:

   ```
   platforms/macos/api/{FRAMEWORK}/annotations.apiw
   ```

## What is annotatable

Only the **structural** shapes — the same predicate `stale` uses:

- a method with a **block-typed parameter**, or
- a method whose **last parameter is an `NSError **` out-param** (a pointer-typed
  param named `error` or ending in `error`, e.g. `outError`).

The legacy `delegate` / `observer` **selector-substring** signal is **excluded**
— it matches accessor getters the documentation does not support annotating. If a
flagged method is not one of the two shapes above, skip it.

## Facts to produce

For each annotatable method, decide as much as Apple's documentation supports.
**Omit any field you cannot defend from documentation** — partial annotation is
better than guessing; the convention tier fills defensible gaps at resolve time.

1. **`block-param <index> invocation=<style>`** — for each block-typed param:
   - `synchronous` — invoked during the call, NOT copied (caller frees)
   - `async_copied` — copied for later async invocation
   - `stored` — stored for repeated invocation (observers, handlers)

2. **`param-ownership <index> ownership=<kind>`** — only for non-default
   ownership (`weak` / `copy` / `unsafe_unretained`); omit `strong` (the
   default).

3. **`threading <constraint>`** — only when documentation is explicit:
   `main_thread_only` | `any_thread`.

4. **`error-pattern <pattern>`** — only when the method has an error out-param:
   `error_out_param` (returns nil/NO on failure with an `NSError **`) |
   `nil_on_failure` | `throws_exception`.

Every method node also carries **`source llm`** (required — you author the
`accepted-LLM` tier; `manual` is reserved for human hand-edits). Optionally add
`confidence high|medium|low` and a `provenance "<doc URL or rationale>"`.

## How to decide

Look up the framework headers at
`$SDKROOT/System/Library/Frameworks/{FRAMEWORK}.framework/Headers/`. They are the
authoritative source — they carry `weak`/`copy`/`assign`/`nullable` attributes
and `///` doc comments the developer.apple.com web UI strips. Use `WebFetch` on
`developer.apple.com/documentation/` only as a supplemental cross-check for
prose/Discussion notes; those pages are JS-built SPAs and `WebFetch` often returns
only `<title>`, so do not rely on them as the primary source.

If a property getter and its setter are both annotatable, annotate the setter
only — the getter has no ownership/block surface.

## Output — write `.apiw` directly

Edit `platforms/macos/api/{FRAMEWORK}/annotations.apiw`. The format (KDL):

```kdl
framework {FRAMEWORK} {
    class NSURLSession {
        method dataTaskWithURL:completionHandler: is-instance=#true {
            block-param 1 invocation=async_copied
            threading any_thread
            source llm
        }
    }
    class NSArray {
        method writeToURL:error: is-instance=#true {
            error-pattern error_out_param
            source llm
        }
    }
}
```

Hard rules (the validation step will reject violations):

- Exactly one top-level `framework "{FRAMEWORK}"` node; its value must equal
  `{FRAMEWORK}`.
- `is-instance=#true` for instance methods, `#false` for class methods — it must
  match the method's `class_method` flag in the resolved surface.
- Every `class` value is a receiver name that appears in the resolved surface;
  every `method` selector appears under that receiver.
- `block-param <i>` must target a param whose type is a block; `param-ownership
  <i>` must target an object param; indices are zero-based and in range.
- Enum values must be the exact tokens above (`synchronous` / `async_copied` /
  `stored`; `weak` / `copy` / `unsafe_unretained`; `main_thread_only` /
  `any_thread`; `error_out_param` / `nil_on_failure` / `throws_exception`;
  `source` is `llm` here).
- Emit no empty method shells — omit a method you have no facts for, and omit a
  class whose methods all fall under that rule.
- Keep classes and methods sorted (the existing file is sorted; preserve it).

### Optional self-report

Append a `subagent-report` node with your aggregate counts; downstream
cross-checks it against the file content (a warning on divergence — it caught a
real CoreData miscount). Include only the categories you tracked.

```kdl
    subagent-report {
        block-async-copied 15
        block-synchronous 4
        block-stored 11
        parameter-ownership 5
        error-pattern 58
    }
```

## Validate before returning

The overlay is validated by re-resolving the family (which parses the `.apiw`,
failing loudly on malformed KDL) and re-running staleness (which confirms your
facts cover the new-surface slots):

```bash
cargo run -q -p apianyware-analyze -- --only {FRAMEWORK}              # parses + resolves the overlay
cargo run -q -p apianyware-analyze -- annotations stale --only {FRAMEWORK}
```

The resolve must succeed (exit 0). The `stale` run should show the family's
`orphaned` / `shape-changed` counts at zero and `new-surface` reduced to only the
methods you deliberately left unannotated. Fix any KDL parse error and re-run
until resolve is clean. Do not return until both run.

Report back:
- the path you wrote (`platforms/macos/api/{FRAMEWORK}/annotations.apiw`)
- count of annotated classes and methods, and the per-category counts
- any annotatable methods you deliberately left unannotated, and why
- the post-edit `stale --only {FRAMEWORK}` summary line
