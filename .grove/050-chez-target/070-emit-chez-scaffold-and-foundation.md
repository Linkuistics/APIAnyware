# 070-emit-chez-scaffold-and-foundation

**Kind:** work

## Goal
Stand up `generation/crates/emit-chez/` and get end-to-end emission of
**Foundation classes** (not the auxiliary files yet — enums, constants,
functions, protocols, main.sls are leaf 080). The Foundation framework
is the right first because (a) it's heavily exercised by every other
framework, (b) it's the same target the racket emitter started against.

## Context
- ADR-0008 (standalone sibling, not a fork).
- Design spec §4 (file layout) and §3 (emitted-class form).
- `generation/crates/emit-racket/src/{lib.rs,emit_framework.rs,emit_class.rs}`
  — *reference shape only*; do not copy.
- `generation/crates/emit/src/binding_style.rs` — the trait this crate
  implements.
- `generation/crates/emit/src/{naming.rs,code_writer.rs,ffi_type_mapping.rs,framework_ordering.rs}`
  — language-agnostic utilities to reuse.
- `generation/crates/cli/` — register `ChezEmitter` so `--lang chez`
  dispatches correctly. `--list-languages` should show both.

## Done when
- `generation/crates/emit-chez/Cargo.toml` and `src/` exist with the
  module structure from spec §4.
- `ChezEmitter` impls `LanguageEmitter`; `language_info()` returns
  `{id: "chez", display_name: "Chez Scheme"}`.
- The cli (`apianyware-macos-generate --lang chez foundation`)
  produces `generation/targets/chez/generated/foundation/<class>.sls`
  files — one per Foundation class.
- A smoke test loads a couple of emitted Foundation classes alongside
  the runtime under `chez --script` and constructs an `NSString` /
  `NSArray` end-to-end (assuming the runtime leaves 030/040/050/060
  are done).
- `--list-languages` shows both `racket` and `chez`.

## Notes
- The 020/030 sample emit code in design spec §3 is a sketch. Settle
  the actual macro-vs-raw-procedure mix during this leaf; record the
  choice in `knowledge/targets/chez.md` later.
- Snapshot tests via `emit/src/snapshot_testing.rs` should be set up for
  a couple of representative Foundation classes (`NSString`, `NSArray`,
  `NSDictionary`, `NSDate`) so future emitter changes have regression
  coverage.
