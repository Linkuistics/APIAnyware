# Retire the paradigm / BindingStyle dimension; one binding style per target

The `BindingStyle` enum (`ObjectOriented | Functional | Procedural`) and the
machinery threading it through `LanguageEmitter::emit_framework` and
`LanguageInfo` (`supported_styles`, `default_style`) are retired. The dimension
was YAGNI made concrete: only `ObjectOriented` has ever been emitted, and the
`Functional` / `Procedural` variants are speculative scaffolding inferred from
hypothetical Common Lisp / OCaml / Zig targets that do not exist. Each target
now binds exactly one style by construction; the style is implicit in the
target, never reified as a parameter or CLI flag.

## Consequences

- Each target produces exactly one binding style. The style is a property of
  the target, not a selection at the call site.
- **Escape hatch for a future two-flavour target** (e.g. both class-based and
  procedural Chez bindings): register **two targets** — `chez-class` and
  `chez-functional` — each with its own emitter crate, runtime, and sample
  apps. Do **not** reintroduce a paradigm dimension to share one emitter
  across both.
- `EmitResult`'s counters (`classes_emitted`, `protocols_emitted`,
  `enums_emitted`, `functions_emitted`, `constants_emitted`) are **not**
  paradigm-coded — every target's emitter populates them as appropriate. The
  struct shape stays.
- Snapshot output paths flatten: `generated/oo/<framework>/` becomes
  `generated/<framework>/` and `tests/golden/<target>/oo/<framework>/`
  becomes `tests/golden/<target>/<framework>/`.

See `CONTEXT.md` (the `Paradigm (retired)` glossary entry) for the canonical
vocabulary. The mechanical code purge follows in a separate commit.
