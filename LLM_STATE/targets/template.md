# Target: {target}

{Language} ({paradigm}) bindings for macOS APIs. See `LLM_STATE/new-language-guide.md`
for the step-by-step guide to adding a new target.

This template is for `backlog.md` only. Each target plan directory also needs:
- `session-log.md` — append-only session records (start with `# Session Log` header)
- `memory.md` — distilled learnings (start with `# Memory` header)
- `phase.md` — current phase (`work`, `reflect`, or `triage`)
- `prompt-work.md`, `prompt-reflect.md`, `prompt-triage.md` — phase prompts
- `run.sh` — generic cycle driver (identical across all plans)

See `../Ravel-Lite/README.md` for the full plan directory structure and phase cycle.

```
Language: {display name}
Implementations: {runtime/compiler list}
Binding styles: {list, e.g., "OO, Functional, C-API"}
Swift dylib: libAPIAnyware{Lang}.dylib
Emitter crate: emit-{target}
Runtime location: generation/targets/{target}/runtime/
```

## Task Backlog

{Initial tasks — adapt from the categories below based on what's already done
for this target. Not all targets start from zero.}

### Create emitter crate `[foundation]`
- **Status:** not_started
- **Dependencies:** none
- **Description:** Create `generation/crates/emit-{target}/` with naming conventions,
  dispatch strategy, class/protocol/enum emission, and framework orchestration.
  See `LLM_STATE/new-language-guide.md` Step 2 for structure. Use the Racket emitter
  as reference: `generation/crates/emit-racket-oo/`.
- **Results:** _pending_

### Create runtime library `[foundation]`
- **Status:** not_started
- **Dependencies:** none (can develop in parallel with emitter)
- **Description:** Create `generation/targets/{target}/runtime/` with object wrapping,
  memory management, block/delegate bridging, type conversions, struct types, variadic
  helpers, and Swift dylib loading. See `LLM_STATE/new-language-guide.md` Step 3.
- **Results:** _pending_

### Swift dylib integration `[foundation]`
- **Status:** not_started
- **Dependencies:** runtime library
- **Description:** Wire up `libAPIAnyware{Lang}.dylib`. Verify FFI round-trip, block
  creation, delegate creation. See `LLM_STATE/new-language-guide.md` Step 4.
- **Results:** _pending_

### Register with generation CLI `[foundation]`
- **Status:** not_started
- **Dependencies:** emitter crate
- **Description:** Add `--lang {target}` to the generation CLI. See
  `LLM_STATE/new-language-guide.md` Step 5.
- **Results:** _pending_

### Snapshot tests `[testing]`
- **Status:** not_started
- **Dependencies:** emitter crate, CLI wiring
- **Description:** Golden-file regression tests for all binding styles. See
  `LLM_STATE/new-language-guide.md` Step 6.
- **Results:** _pending_

### Smoke tests `[testing]`
- **Status:** not_started
- **Dependencies:** runtime, generated bindings
- **Description:** Non-GUI tests in the target language verifying bindings work.
  See `LLM_STATE/new-language-guide.md` Step 7.
- **Results:** _pending_

### C-API style emission `[coverage]`
- **Status:** not_started
- **Dependencies:** core pipeline C function/enum/constant extraction
- **Description:** Emit bindings for C functions, enums, constants, and callback types.
  This is a new binding style within the target, sharing the runtime and dylib.
- **Results:** _pending_

### Sample apps `[apps]`
- **Status:** not_started
- **Dependencies:** smoke tests passing, runtime working
- **Description:** Implement the 7 standard sample apps. See `knowledge/apps/_index.md`
  for the catalogue and `knowledge/apps/{app}/spec.md` for each spec. Validate each
  with TestAnyware (see `knowledge/testanyware/general.md`).
- **Results:** _pending_

