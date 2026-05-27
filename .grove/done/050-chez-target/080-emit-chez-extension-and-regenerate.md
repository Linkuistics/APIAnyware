# 080-emit-chez-extension-and-regenerate

**Kind:** work

## Goal
Bring `emit-chez` to feature parity with `emit-racket`:
- enums (`enums.sls`)
- constants (`constants.sls`)
- C functions (`functions.sls`, skip inline + variadic per emit-racket's
  filter)
- protocols (`protocols/<proto>.sls`)
- per-framework `main.sls` re-export

Then **regenerate every framework** the racket target currently emits,
into `generation/targets/chez/generated/`. Surface and fix emitter bugs
that show up at scale.

## Context
- Design spec §4 + §5.
- `generation/crates/emit-racket/src/{emit_enums.rs,emit_constants.rs,emit_functions.rs,emit_protocol.rs,shared_signatures.rs}`
  — reference shape only.
- The full enriched-IR set under `generation/output/` (or wherever the
  pipeline puts it on the dev host).
- [[feedback-regenerate-pipeline-aggressively]] — rerun the full
  pipeline after any change in this leaf.

## Done when
- `apianyware-macos-generate --lang chez --all` emits every framework
  racket emits, with all five file types.
- The chez generated tree under `generation/targets/chez/generated/`
  matches the racket tree structurally (same framework dirs, same
  per-class file count, same `enums.sls`/`constants.sls`/`functions.sls`/
  `protocols/`/`main.sls` presence pattern).
- A spot-check `chez --script` of `(import (apianyware appkit))` and
  `(import (apianyware webkit))` loads without errors.
- Snapshot tests cover at least one representative file of each kind
  (enum, constant, function, protocol) plus a `main.sls`.

## Notes
- Some racket emitter quirks (e.g. specific selector-name escaping for
  Scheme identifier rules) may have direct chez analogs and others may
  not. Audit during this leaf — racket's identifier rules are a
  superset of chez's in some areas and a subset in others (#%
  identifier prefix, hashes in symbols).
- Variadic function filtering: confirm the existing
  `emit/src/ffi_type_mapping.rs` predicates cover chez `foreign-procedure`'s
  variadic story without bespoke handling.
