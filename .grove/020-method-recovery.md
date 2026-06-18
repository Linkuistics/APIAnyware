# 020-method-recovery

**Kind:** work

## Goal

Land the **shared-pipeline** (`collect → analyse`) changes that surface Swift-native
methods + initializers as trampolinable decls. Done once, target-agnostic (ADR-0011:
analysis is the only shared layer); all three target nodes (030/040/050) block on it.

## Context

Planning decisions: root `BRIEF.md` + `010-plan` running log (D1–D7). Code map (from
the 010 grilling, cite-checked):
- `ir::Method` (`collection/crates/types/src/ir.rs:190-262`) has `objc_exposed` but
  **no `swift_fn`** (no async/throwing/generic) and hardcodes nothing for effects.
- `map_method` (`extract-swift/src/declaration_mapping.rs:453-483`) retains
  `objc_exposed == false` methods but **never applies `node_is_async`** (only
  `map_top_level_function` does, line 652) and **hardcodes `init_method: false`**
  (line 457) — initializers are not recovered as such.
- `node_is_async`/`mangled_is_async` exist (`declaration_mapping.rs:602-606`); the
  `Ya`-marker mangled scan is the toolchain-independent floor (digester emits no async
  field — spec §5b).

## Done when

- `ir::Method` gains `swift_fn: Option<SwiftFnInfo>` (`{throwing, is_async, is_generic}`),
  additive + `skip_serializing_if = Option::is_none` (ObjC golden JSON unchanged) —
  mirrors the `ir::Function` change (spec §0a).
- `map_method` populates it: `is_async = node.is_async || node_is_async(node)`,
  `throwing = node.throwing`, `is_generic = node.generic_sig.is_some()`.
- **Initializer recovery:** `init_method` reflects reality (digester `init` nodes →
  `init_method: true`); confirm Swift-native inits reach `map_method` (or wherever inits
  flow) and carry receiver-type + labels. This is the population-B root producer (D2).
- **Receiver-type exposure threading:** the owning type's name + `objc_exposed` are
  reachable at classification time for the soundness gate (D2) and the A/B split (D1).
- **Measure the whole IR first** (the §5a/b/c discipline) and record the residual
  shape: total Swift-native methods, async count, init count, A vs B receiver split,
  mutating-value-receiver count (D3 sizing), per-blocker deferred counts. This
  measurement feeds 030's exemplar pick (D7) and every target's done-bar.
- `cargo test --workspace` green (incl. updated snapshots); ObjC goldens unchanged.

## Notes

Recovery only — **no emitter/runtime/trampoline codegen here** (that's 030+). If
measurement reveals new structure (e.g. protocol-method or property recovery
sub-cases), kick back to grow leaves rather than guessing.
