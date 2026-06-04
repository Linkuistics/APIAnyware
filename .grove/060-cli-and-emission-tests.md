# 060-cli-and-emission-tests

**Kind:** work

## Goal

Register `gerbil` as a CLI target and add emission (golden) tests for `emit-gerbil`.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §1, §8. The CLI knows only
targets (one binding style per target, no paradigm axis — ADR-0004). Reference:
how `chez` is registered in the generate CLI + chez's emission/golden tests.

## Done when

- `apianyware-macos-generate --target gerbil` resolves and drives `emit-gerbil`.
- Emission tests assert the generated Gerbil is well-formed and matches goldens
  for a representative framework subset (goldens-as-truth, per the racket/chez
  precedent; enriched IR may be gitignored — snapshot tests skip-as-pass without
  local IR).
- `cargo test` green for `emit-gerbil`.

## Notes

Keep the gerbil target hermetically separate (ADR-0011) — no shared substrate with
racket/chez beyond the IR.

### From leaf 050/020 (native bridges) — the `native_block.c` companion build step

The runtime ships a clang companion `lib/runtime/native_block.c` (the ObjC block
literals `make-objc-block` builds; gcc-15 cannot parse `^`). The build config this
node bakes MUST: (1) compile it once with
`clang -fblocks -isysroot $SDKROOT -c lib/runtime/native_block.c -o native_block.o`;
(2) add `native_block.o` to **every** `-ld-options` link line — both the `gxc -O`
runtime-module compile (native-core's loadable object references `aw_make_block_*`)
AND each app exe link. Module compile order: `ffi.ss → native-core.ss → objc.ss`.
This is SEPARATE from the 055 umbrella-header gcc-15-vs-clang decision (that is about
emitted `constants`/`functions` modules; this is the runtime's own block literals).
The companion is self-contained (dispatcher passed as an opaque fn-pointer → no
external symbols) so it links cleanly anywhere. Full recipe in `runtime/README.md`
"Building".

### From leaf 040/020/030 (manifest class graph) — wire the global `ClassRegistry`

The manifest `defclass` graph (ADR-0020) needs a **cross-framework class→owning-
framework registry** to place a parent that lives in another framework (e.g.
AppKit's `NSTextStorage : NSMutableAttributedString`, owned by Foundation). The
per-framework `TargetEmitter::emit_framework` cannot see other frameworks, so the
emitter takes a `ClassRegistry` (in `emit-gerbil/src/class_graph.rs`):

- Build it **once** over all loaded frameworks with
  `ClassRegistry::from_frameworks(&ordered_frameworks)` (in the generate pipeline,
  `generation/crates/cli/src/generate.rs` — the `ordered_frameworks` already loaded
  there), then construct the emitter with `GerbilEmitter::with_registry(reg)`
  instead of `GerbilEmitter::new()`/`default()`.
- Default-constructed (`GerbilEmitter::new()`), the registry is **empty**:
  same-framework parents still resolve, but a cross-framework parent degrades to
  the runtime `NSObject` root (the true ObjC super is still recorded in
  `register-objc-class!`, so runtime wrap stays correct — but the static Gerbil
  inheritance link is lost). **Wiring the registry in the CLI closes that gap** and
  is required for the cross-framework `defclass` parents + sibling imports to be
  precise in production.
- A golden test over a 2-framework subset (a dependent framework with a class whose
  super lives in the base framework) should assert the cross-framework
  `:gerbil-bindings/<owner>/<parent>` import appears — exercising the wired
  registry end-to-end.

### From leaf 050/040 (smoke-suite) — cross-module generic unification (escalated)

The dual-surface emission (ADR-0020, leaf 040/020/040) has each class module
declare its **own** `(g:defgeneric <bare-sel>)` for every instance selector it
exposes. Two **unrelated** classes that share a selector name (`count`, `title`,
`name`, …) therefore export the **same** generic identifier from **different**
modules; when `emit_framework.rs` builds the framework facade that re-exports
them, those coincidental collisions clash/collapse. This is **unsound for
coincidentally-shared selectors** and surfaces only at the full
emitted-framework build (the runtime smokes each declare one class, so they
cannot see it — confirmed at 050/040: every smoke is single-class and green).

**Sound fix (the BRIEF's stated direction):** a **shared generics-declaration
module** — the global selector set declared once (`(g:defgeneric count)` …) and
imported everywhere — the exact analogue of the cross-framework `ClassRegistry`
above. Build it in the same CLI pre-pass that builds the registry (it has all
loaded frameworks in scope), have `emit_class` import it instead of declaring
per-module `g:defgeneric`s, and have the facade re-export from it. A golden test
over two unrelated classes sharing a selector should assert a single generic
declaration site. (ADR-0019's illustrative `wrap-objc-obj` spelling also wants
reconciling to `wrap` — cosmetic, do alongside.)
