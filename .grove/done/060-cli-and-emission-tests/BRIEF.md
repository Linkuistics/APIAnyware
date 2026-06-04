# 060-cli-and-emission-tests — brief

## Goal

Register `gerbil` as a CLI target and add emission (golden) tests for `emit-gerbil`,
so `apianyware-macos-generate --target gerbil` resolves end-to-end and the emitted
Gerbil is pinned by goldens.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §1, §8. The CLI knows only
targets (one binding style per target, no paradigm axis — ADR-0004). Reference: how
`chez` is registered in the generate CLI (`generation/crates/cli/src/registry.rs`,
`generate.rs`) + chez's emission/golden tests, and racket's whole-program
`run_racket_native_dispatch` pre/post-pass precedent (a target-specific cross-
framework pass living in `generate.rs`, run outside the per-framework `emit_framework`
loop).

Keep the gerbil target hermetically separate (ADR-0011) — no shared substrate with
racket/chez beyond the IR.

## Decomposition

Two of the three concerns below are escalations carried in from sibling leaves; the
class graph (ADR-0020) and generic unification are inherently **cross-framework**,
but `TargetEmitter::emit_framework` runs **per framework** — so both are wired in the
CLI pre-pass (`generate.rs`), the racket-native-dispatch pattern.

- **010** CLI target registration + cross-framework `ClassRegistry` wiring
- **020** shared global generics module (cross-module generic unification fix)
- **030** emission/golden test suite (representative framework subset)

## Node done when

- `apianyware-macos-generate --target gerbil` resolves and drives `emit-gerbil`.
- Emission tests assert the generated Gerbil is well-formed and matches goldens for a
  representative framework subset (goldens-as-truth, per racket/chez; enriched IR may
  be gitignored — snapshot tests skip-as-pass without local IR).
- `cargo test` green for `emit-gerbil` + the CLI.

## Escalation notes (consumed by the children)

### → 010 — wire the global `ClassRegistry` (from leaf 040/020/030)

The manifest `defclass` graph (ADR-0020) needs a **cross-framework class→owning-
framework registry** to place a parent that lives in another framework (e.g. AppKit's
`NSTextStorage : NSMutableAttributedString`, owned by Foundation). The per-framework
`TargetEmitter::emit_framework` cannot see other frameworks, so the emitter takes a
`ClassRegistry` (`emit-gerbil/src/class_graph.rs`):

- Build it **once** over all loaded frameworks with
  `ClassRegistry::from_frameworks(&ordered_frameworks)` (in the generate pipeline,
  `generation/crates/cli/src/generate.rs` — the `ordered_frameworks` already loaded
  there), then run the emitter constructed with `GerbilEmitter::with_registry(reg)`
  instead of `GerbilEmitter::new()`/`default()`.
- Default-constructed (`GerbilEmitter::new()`), the registry is **empty**: same-
  framework parents still resolve, but a cross-framework parent degrades to the
  runtime `NSObject` root (the true ObjC super is still recorded in
  `register-objc-class!`, so runtime wrap stays correct — but the static Gerbil
  inheritance link is lost). **Wiring the registry in the CLI closes that gap.**
- A golden/integration test over a 2-framework subset (a dependent framework with a
  class whose super lives in the base framework) should assert the cross-framework
  `:gerbil-bindings/<owner>/<parent>` import appears — exercising the wired registry
  end-to-end.

### → 020 — cross-module generic unification (from leaf 050/040, escalated)

The dual-surface emission (ADR-0020, leaf 040/020/040) has each class module declare
its **own** `(g:defgeneric <bare-sel>)` for every instance selector it exposes. Two
**unrelated** classes that share a selector name (`count`, `title`, `name`, …)
therefore export the **same** generic identifier from **different** modules; when
`emit_framework.rs` builds the framework facade that re-exports them, those
coincidental collisions clash/collapse. This is **unsound for coincidentally-shared
selectors** and surfaces only at the full emitted-framework build (the runtime smokes
each declare one class, so they cannot see it — confirmed at 050/040: every smoke is
single-class and green).

**Sound fix (the BRIEF's stated direction):** a **shared generics-declaration
module** — the global selector set declared once (`(g:defgeneric count)` …) and
imported everywhere — the exact analogue of the cross-framework `ClassRegistry` above.
Build it in the same CLI pre-pass that builds the registry (it has all loaded
frameworks in scope), have `emit_class` import it instead of declaring per-module
`g:defgeneric`s, and have the facade re-export from it. A golden test over two
unrelated classes sharing a selector should assert a single generic declaration site.
(ADR-0019's illustrative `wrap-objc-obj` spelling also wants reconciling to `wrap` —
cosmetic, do alongside.)

## Pointers

- Build-config escalations that came in with the original leaf (the `native_block.c`
  clang companion + the ADR-0021 default-compiler resolution) are **bundler/070
  concerns**, not CLI/test concerns — relocated to `070-bundle-gerbil-and-hello-
  window.md`.
