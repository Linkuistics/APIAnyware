# add-gerbil-scheme-target — brief

## Goal

Add **Gerbil Scheme** as a third language target (`racket`, `chez`, → `gerbil`),
following `docs/adding-a-language-target.md` and the project north star: the
per-target native (Swift) library *is* the binding (ADR-0010), targets are
hermetically isolated — no shared native substrate (ADR-0011), and the emitter
writes maximally-idiomatic Gerbil, not a portable Scheme subset (ADR-0005).

Gerbil is the closest sibling to the just-completed **chez** target (both are
Schemes; both want self-contained standalone distribution). But Gerbil's
compile-to-C model (Gerbil → Gambit → C), its native object/module system
(`defclass`/`defmethod`/`defstruct`, `:std/foreign`), and its Gambit GC change
the FFI / dispatch / lifetime calculus enough that the design is decided fresh,
borrowing chez *patterns* (ADRs 0005–0009, 0015–0016) only where they earn it.

## Done when

The 9-step checklist in `docs/adding-a-language-target.md` is satisfied for
`gerbil`: emitter crate, runtime, Swift dylib (if needed), CLI registration,
emission tests, all 7 sample apps built **and TestAnyware/VM-verified**, bundler
integration, `knowledge/targets/gerbil.md`, and README status updated.

## Decomposition

_To be grown by the 010-plan grilling session — leaves are added lazily as the
design tree is walked._

## Pointers

- Guide: `docs/adding-a-language-target.md`
- Closest reference target: **chez** — `generation/crates/emit-chez/`,
  `generation/targets/chez/`, `knowledge/targets/chez.md`
- Idiom posture: `docs/adr/0005-chez-target-emits-idiomatic-chez.md`
- Chez design specs: `docs/specs/2026-05-27-chez-target-design.md`,
  `docs/specs/2026-05-29-chez-standalone-distribution-design.md`,
  `docs/specs/2026-06-02-chez-native-binding-design.md`
- Lifetime / errors / dispatch / callbacks ADRs: 0006, 0007, 0009, 0013, 0014,
  0015, 0016
- Glossary: `CONTEXT.md`

## Notes

Memory: targets are maximally idiomatic + performance-maximising (LLM makes
per-target richness affordable); every sample-app port carries a dedicated
VM-verify leaf (CLI smoke never satisfies the done-bar).
