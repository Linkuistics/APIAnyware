# The shared projection substrate lives under `targets/_shared/`, not `semantic/`

**Status:** accepted

The `structural-refactoring` grove's skeleton node must give the cross-cutting
`emit` crate — the shared projection substrate consumed by all four emitters
(`emit-racket`/`-chez`/`-gerbil`/`-sbcl`) and the generate CLI, and incorporating
the `naming` acronym table — a home in the five-domain tree. ADR-0043 distributed
the toolchain *by served-domain* but explicitly deferred `emit`'s exact home as a
skeleton-step detail, flagging a real tension: `CONTEXT.md` records the `naming`
acronym table as *"shared analysis-level data"* (pulling toward `semantic/`), while
`REFACTOR.md` §7.2 states *"projection lives in targets"* (pulling toward
`targets/`). We place `emit` (and, by the precedent it sets, `stub-launcher` and the
generate CLI) under a shared, clearly-non-target area **`targets/_shared/tools/`**.

## Context

The two candidate domains read the same crate differently:

- **`semantic/`** is the *shared language of meaning* (REFACTOR §8). The argument
  for it is `CONTEXT.md`'s "naming is shared analysis-level data" — identifier
  formation could be seen as a meaning-level concern.
- **`targets/`** is *target-language expression and proof* (REFACTOR §8, §7.2). The
  argument for it is that `emit` is projection machinery — `code_writer`,
  `doc_rendering`, `ffi_type_mapping`, `pattern_dispatch`, `target_emitter` — that
  turns the resolved semantic model into target-language source.

The deciding evidence is the dependency graph: `emit` is consumed by **all four
emitters plus the generate CLI and by zero analysis crates**. By "code lives with
its subject / consumers," it is target-domain expression machinery that merely
happens to be shared across targets.

## Decision

1. **`emit` → `targets/_shared/tools/emit/`.** The `_shared` area is a domain-placed
   home for cross-target machinery, *not* the central top-level `tools/` ADR-0043
   rejected. The leading underscore marks it as "not a target" so it sorts and reads
   distinctly from `racket/`, `sbcl/`, etc.
2. **Precedent for siblings.** `stub-launcher` (shared bundling) and the `generate`
   CLI (drives emission across targets, consumes `emit`) follow `emit` into
   `targets/_shared/tools/`.
3. **`CONTEXT.md`'s phrase is about the table *data*, not the crate.** The acronym
   table is consumed only by emitters; splitting the `naming` *code* from a *data*
   artifact under `semantic/` was considered and rejected as skeleton-stage
   over-engineering for a small table.

## Considered options

- **`semantic/tools/emit/`** (rejected). Honors `CONTEXT.md`'s literal wording, but
  `semantic/` is the language of *meaning*; `emit` is *expression*. No analysis crate
  consumes `emit`, so co-locating it with `types`/`resolve`/`enrich` misrepresents the
  dependency structure.
- **Split: emit code → `targets/_shared/`, acronym table → `semantic/`** (rejected).
  Honors `CONTEXT.md` most literally but fragments one crate across two domains for a
  small table — a path-dependency and cognitive cost unjustified at skeleton stage.

## Consequences

- Per-target hermetic isolation (ADR-0010/0011) is unaffected: it governs
  runtime/output, not emitter *code*, so a shared `emit` under `targets/_shared/` does
  not mean "duplicate emit per target" (ADR-0043 Consequences).
- `targets/_shared/` becomes the established home for any future cross-target
  *machinery* (as opposed to per-target expression). New shared projection code lands
  there by default.
- The `CONTEXT.md` ↔ ADR-0043 tension is resolved in favour of the dependency-graph
  reading; a future reader asking "why is shared `emit` under `targets/` not
  `semantic/`?" is answered here.
- This is mechanically a reversible `git mv`; the decision is recorded as an ADR
  because the *placement principle* (shared-but-target-domain machinery lives in
  `targets/_shared/`) is precedent-setting and surprising, not because the move is
  hard to undo.

See `REFACTOR.md` (§7.2, §8), ADR-0043, ADR-0010/0011, `CONTEXT.md` ("naming"
note), and the grove `structural-refactoring` skeleton node brief (`skeleton-k2`).
